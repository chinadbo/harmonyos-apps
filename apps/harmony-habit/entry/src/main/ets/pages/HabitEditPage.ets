import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { HabitRepository } from '../database/HabitRepository';
import { CheckInRepository } from '../database/CheckInRepository';
import { HabitModel, createDefaultHabit } from '../model/HabitModel';
import { ICON_SET, COLOR_PALETTE, WEEKDAY_LABELS } from '../common/Constants';
import { ReminderService } from '../service/ReminderService';
import { WidgetBridgeService } from '../service/WidgetBridgeService';
import { StatsService } from '../service/StatsService';

@Entry
@Component
struct HabitEditPage {
  @State habit: HabitModel = createDefaultHabit();
  @State selectedDays: boolean[] = [true, true, true, true, true, true, true];
  @State pageTitle: string = '创建习惯';
  private habitId: number = 0;
  private context: common.Context = getContext(this) as common.Context;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>;
    this.habitId = Number(params?.habitId ?? 0);
    if (this.habitId > 0) {
      this.pageTitle = '编辑习惯';
      this.loadHabit();
    }
  }

  private async loadHabit(): Promise<void> {
    const found = await new HabitRepository(this.context as common.UIAbilityContext).findById(this.habitId);
    if (!found) {
      return;
    }
    this.habit = found;
    this.selectedDays = found.targetDays.split('').map((item) => item === '1');
  }

  private buildTargetDays(): string {
    return this.selectedDays.map((item) => item ? '1' : '0').join('');
  }

  private async saveHabit(): Promise<void> {
    if (!this.habit.name.trim()) {
      promptAction.showToast({ message: '请输入习惯名称' });
      return;
    }
    if (!this.selectedDays.some((item) => item)) {
      promptAction.showToast({ message: '至少选择一天' });
      return;
    }
    const abilityContext = this.context as common.UIAbilityContext;
    const repository = new HabitRepository(abilityContext);
    const oldHabit = this.habitId > 0 ? await repository.findById(this.habitId) : null;
    if (oldHabit && oldHabit.reminderId >= 0) {
      await ReminderService.cancelReminder(oldHabit.reminderId);
    }
    this.habit.targetDays = this.buildTargetDays();
    this.habit.reminderId = this.habit.reminderTime
      ? await ReminderService.publishDailyReminder(this.habit.name, this.habit.reminderTime)
      : -1;
    if (this.habitId > 0) {
      await repository.update(this.habit);
    } else {
      this.habit.createdAt = Date.now();
      this.habit.id = await repository.insert(this.habit);
    }
    await this.syncWidget();
    promptAction.showToast({ message: '保存成功' });
    router.back();
  }

  private async syncWidget(): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    const habits = await new HabitRepository(abilityContext).findAll(false);
    const checkins = await new CheckInRepository(abilityContext).findAll();
    const dashboard = StatsService.buildDashboard(habits, checkins);
    await WidgetBridgeService.writeSummary(this.context, dashboard.todayTotal, dashboard.todayDone);
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 10 }) {
            Text('习惯名称')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)
            TextInput({ text: this.habit.name, placeholder: '例如：晨跑 20 分钟' })
              .backgroundColor('#FFFFFF')
              .borderRadius(18)
              .height(48)
              .onChange((value: string) => this.habit.name = value)
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('图标')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(ICON_SET, (icon: string, index: number) => {
                Text(icon)
                  .fontSize(28)
                  .width(52)
                  .height(52)
                  .textAlign(TextAlign.Center)
                  .borderRadius(16)
                  .margin({ right: 10, bottom: 10 })
                  .backgroundColor(this.habit.icon === icon ? '#EEF2FF' : '#FFFFFF')
                  .onClick(() => this.habit.icon = icon)
              })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('主题色')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)
            Row({ space: 10 }) {
              ForEach(COLOR_PALETTE, (color: string, index: number) => {
                Row()
                  .width(30)
                  .height(30)
                  .borderRadius(15)
                  .backgroundColor(color)
                  .border({ width: this.habit.colorIndex === index ? 3 : 0, color: '#111827' })
                  .onClick(() => this.habit.colorIndex = index)
              })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('打卡频率')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)
            Row({ space: 8 }) {
              ForEach(WEEKDAY_LABELS, (label: string, index: number) => {
                Button(label)
                  .height(36)
                  .backgroundColor(this.selectedDays[index] ? '#4F46E5' : '#FFFFFF')
                  .fontColor(this.selectedDays[index] ? '#FFFFFF' : '#344054')
                  .onClick(() => {
                    const days = this.selectedDays.slice();
                    days[index] = !days[index];
                    this.selectedDays = days;
                  })
              })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('提醒时间')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .textAlign(TextAlign.Start)
            TextInput({ text: this.habit.reminderTime, placeholder: 'HH:mm，例如 08:00' })
              .backgroundColor('#FFFFFF')
              .borderRadius(18)
              .height(48)
              .onChange((value: string) => this.habit.reminderTime = value)
          }
          .alignItems(HorizontalAlign.Start)

          Row({ space: 12 }) {
            Toggle({ type: ToggleType.Switch, isOn: this.habit.isActive === 1 })
              .onChange((value: boolean) => this.habit.isActive = value ? 1 : 0)
            Text(this.habit.isActive === 1 ? '启用习惯' : '停用习惯')
              .fontSize(14)
              .fontColor('#344054')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)

          Button('保存习惯')
            .width('100%')
            .height(48)
            .backgroundColor('#111827')
            .fontColor('#FFFFFF')
            .onClick(() => this.saveHabit())
        }
        .padding(18)
        .backgroundColor('#F8FAFC')
      }
    }
    .title(this.pageTitle)
  }
}

export default HabitEditPage;
