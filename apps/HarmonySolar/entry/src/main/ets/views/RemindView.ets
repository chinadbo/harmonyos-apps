import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { SolarTerm } from '../model/SolarTerm';
import { SolarTermData } from '../engine/SolarTermData';
import { ReminderPrefs } from '../common/DbHelper';
import { ReminderService } from '../common/ReminderService';
import { Palette, Utils } from '../common/Constants';

@Component
export struct RemindView {
  @State enabled: boolean = false;
  @State advance: number = 0;
  @State nextName: string = '';
  @State nextMoment: string = '';
  @State nextDistance: string = '';

  aboutToAppear(): void {
    this.loadSettings();
  }

  private async loadSettings(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      this.enabled = await ReminderPrefs.isEnabled(context);
      this.advance = await ReminderPrefs.getAdvanceDays(context);
    } catch (err) {
      console.error('load reminder settings failed: ' + String(err));
    }
    this.refreshNext();
  }

  private refreshNext(): void {
    const now: Date = new Date();
    const next: SolarTerm | undefined = SolarTermData.getNext(now);
    if (next !== undefined) {
      this.nextName = next.name;
      this.nextMoment = Utils.shortMoment(next);
      this.nextDistance = Utils.daysText(SolarTermData.getDaysToNext(now, next));
    }
  }

  private async changeEnabled(isOn: boolean): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.enabled = isOn;
    if (isOn) {
      const granted: boolean = await ReminderService.requestPermission(context);
      if (!granted) {
        this.enabled = false;
        try {
          await ReminderPrefs.setEnabled(context, false);
        } catch (err) {
          console.error('save reminder state failed: ' + String(err));
        }
        promptAction.showToast({ message: '未获得通知权限，请在系统设置中允许通知', duration: 2200 });
        return;
      }
    }
    try {
      await ReminderPrefs.setEnabled(context, isOn);
      if (isOn) {
        try {
          await ReminderService.publishPreview();
        } catch (err) {
          console.error('publish preview failed: ' + String(err));
        }
        promptAction.showToast({ message: '节气提醒已开启', duration: 1500 });
      } else {
        promptAction.showToast({ message: '节气提醒已关闭', duration: 1500 });
      }
    } catch (err) {
      this.enabled = !isOn;
      promptAction.showToast({ message: '保存提醒设置失败', duration: 1800 });
    }
  }

  private async chooseAdvance(days: number): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      await ReminderPrefs.setAdvanceDays(context, days);
      this.advance = days;
    } catch (err) {
      console.error('save advance days failed: ' + String(err));
      promptAction.showToast({ message: '保存提醒时机失败', duration: 1500 });
    }
  }

  private async sendTest(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const granted: boolean = await ReminderService.requestPermission(context);
    if (!granted) {
      promptAction.showToast({ message: '请先在系统设置中允许通知', duration: 2000 });
      return;
    }
    try {
      await ReminderService.publishPreview();
      promptAction.showToast({ message: '测试通知已发送', duration: 1500 });
    } catch (err) {
      promptAction.showToast({ message: '通知发送失败，请检查系统设置', duration: 2000 });
    }
  }

  @Builder
  AdvanceChip(days: number) {
    Text(days === 0 ? '当天' : ('提前 ' + days + ' 天'))
      .fontSize(11)
      .fontWeight(this.advance === days ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.advance === days ? Color.White : Palette.INK_SOFT)
      .backgroundColor(this.advance === days ? Utils.seasonColor('夏') : '#F5EEE1')
      .borderRadius(12)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .margin({ right: 8 })
      .onClick(() => {
        this.chooseAdvance(days);
      })
  }

  build() {
    Column({ space: 13 }) {
      Row() {
        Column({ space: 3 }) {
          Text('节气提醒')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.INK)
          Text('应用启动时检查节气日并发送本地通知')
            .fontSize(10)
            .fontColor(Palette.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.enabled })
          .selectedColor(Utils.seasonColor('夏'))
          .onChange((isOn: boolean) => {
            this.changeEnabled(isOn);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0E7D8')

      Column({ space: 7 }) {
        Text('提醒时机')
          .fontSize(10)
          .letterSpacing(1)
          .fontColor(Palette.INK_FAINT)
        Row() {
          this.AdvanceChip(0)
          this.AdvanceChip(1)
          this.AdvanceChip(3)
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row({ space: 10 }) {
        Column({ space: 2 }) {
          Text('下一节气')
            .fontSize(9)
            .letterSpacing(1)
            .fontColor(Palette.INK_FAINT)
          Text(this.nextName)
            .fontSize(19)
            .fontWeight(FontWeight.Medium)
            .fontColor(Palette.INK)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 2 }) {
          Text(this.nextMoment)
            .fontSize(11)
            .fontColor(Palette.INK_SOFT)
          Text(this.nextDistance)
            .fontSize(10)
            .fontColor(Utils.seasonColor('秋'))
        }
        .alignItems(HorizontalAlign.End)

        Text('铃')
          .fontSize(15)
          .fontColor(Palette.SEAL_RED)
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .border({ width: 1.5, color: Palette.SEAL_RED })
          .borderRadius(18)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FBF4E7')
      .borderRadius(14)

      Row() {
        Text('发送测试通知')
          .fontSize(11)
          .fontColor(Palette.GOLD)
          .border({ width: 1, color: Palette.GOLD })
          .borderRadius(13)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .onClick(() => {
            this.sendTest();
          })
        Blank()
        Text('本地通知 · 无网络上传')
          .fontSize(9)
          .fontColor(Palette.INK_FAINT)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Palette.CARD_BG)
    .borderRadius(22)
    .border({ width: 1, color: '#F2EBDD' })
  }
}
