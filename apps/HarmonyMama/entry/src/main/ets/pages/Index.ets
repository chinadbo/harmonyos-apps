import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { DbHelper } from '../database/DbHelper';
import { HomeView } from '../components/HomeView';
import { ProfileView, DueDateDialog } from '../components/ProfileView';
import { KickCounterView } from '../components/KickCounterView';
import { CheckupView } from '../components/CheckupView';
import { WeightView } from '../components/WeightView';

const DOMAIN: number = 0x0000;
const TAG: string = 'Index';
const PREF_NAME: string = 'harmony_mama_profile';
const KEY_DUE_DATE: string = 'due_date';
const KEY_LMP: string = 'lmp_date';
const KEY_MODE: string = 'input_mode';
const PINK: string = '#F062A3';
const TAB_GREY: string = '#B9A3AE';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State dueDate: string = '';
  @State refreshTick: number = 0;

  private setupDialog: CustomDialogController | null = null;
  private rootAppeared: boolean = false;
  private setupChecked: boolean = false;
  private pendingSetup: boolean = false;

  aboutToAppear(): void {
    this.initApp();
  }

  private async initApp(): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      await DbHelper.getInstance().init(context);
      const pref: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
      const stored: preferences.ValueType = await pref.get(KEY_DUE_DATE, '');
      let due: string = '';
      if (typeof stored === 'string') {
        due = stored;
      }
      if (due.length > 0) {
        this.dueDate = due;
      } else {
        this.pendingSetup = true;
      }
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'initApp failed: %{public}d %{public}s', error.code, error.message);
      this.pendingSetup = true;
    }
    this.setupChecked = true;
    this.tryOpenSetupDialog();
  }

  private tryOpenSetupDialog(): void {
    if (!this.rootAppeared || !this.setupChecked || !this.pendingSetup || this.setupDialog !== null) {
      return;
    }
    this.pendingSetup = false;
    this.openSetupDialog();
  }

  private openSetupDialog(): void {
    this.setupDialog = new CustomDialogController({
      builder: DueDateDialog({
        allowCancel: false,
        onConfirm: (dueDate: string, lmp: string, mode: number) => {
          this.saveProfile(dueDate, lmp, mode);
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.setupDialog.open();
  }

  private async saveProfile(dueDate: string, lmp: string, mode: number): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const pref: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
      await pref.put(KEY_DUE_DATE, dueDate);
      await pref.put(KEY_LMP, lmp);
      await pref.put(KEY_MODE, mode);
      await pref.flush();
      this.dueDate = dueDate;
      this.refreshTick = this.refreshTick + 1;
      await DbHelper.getInstance().importCheckupTemplate(dueDate);
      promptAction.showToast({ message: '预产期已保存' });
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'saveProfile failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  @Builder
  tabBuilder(index: number, title: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(19)
        .opacity(this.currentTab === index ? 1 : 0.6)
      Text(title)
        .fontSize(11)
        .fontColor(this.currentTab === index ? PINK : TAB_GREY)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 3 })
    }
    .width('100%')
    .height(58)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
        TabContent() {
          HomeView({ dueDate: this.dueDate, refreshTick: this.refreshTick })
        }
        .tabBar(this.tabBuilder(0, '首页', '🏠'))

        TabContent() {
          KickCounterView({ refreshTick: this.refreshTick })
        }
        .tabBar(this.tabBuilder(1, '胎动', '👣'))

        TabContent() {
          CheckupView({ dueDate: this.dueDate, refreshTick: this.refreshTick })
        }
        .tabBar(this.tabBuilder(2, '产检', '🩺'))

        TabContent() {
          WeightView({ dueDate: this.dueDate, refreshTick: this.refreshTick })
        }
        .tabBar(this.tabBuilder(3, '体重', '⚖️'))

        TabContent() {
          ProfileView({
            dueDate: this.dueDate,
            refreshTick: this.refreshTick,
            onDueDateChange: (dueDate: string, lmp: string, mode: number) => {
              this.saveProfile(dueDate, lmp, mode);
            }
          })
        }
        .tabBar(this.tabBuilder(4, '我的', '👤'))
      }
      .width('100%')
      .height('100%')
      .scrollable(false)
      .barHeight(58)
      .barBackgroundColor('#FFFFFF')
      .divider({ strokeWidth: 0.5, color: '#F0DCE6' })
      .onChange((index: number) => {
        this.currentTab = index;
        this.refreshTick = this.refreshTick + 1;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF6FA')
    .onAppear(() => {
      this.rootAppeared = true;
      this.tryOpenSetupDialog();
    })
  }
}
