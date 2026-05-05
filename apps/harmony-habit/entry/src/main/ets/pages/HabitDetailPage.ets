import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { HabitRepository } from '../database/HabitRepository';
import { CheckInRepository } from '../database/CheckInRepository';
import { HabitModel, createDefaultHabit } from '../model/HabitModel';
import { CheckInModel, createCheckIn } from '../model/CheckInModel';
import { HeatMapCanvas, HeatMapPoint } from '../components/HeatMapCanvas';
import { COLOR_PALETTE } from '../common/Constants';
import { DateUtils } from '../common/DateUtils';
import { ReminderService } from '../service/ReminderService';
import { WidgetBridgeService } from '../service/WidgetBridgeService';
import { StatsService } from '../service/StatsService';

@Entry
@Component
struct HabitDetailPage {
  @State habit: HabitModel = createDefaultHabit();
  @State checkins: CheckInModel[] = [];
  @State points: HeatMapPoint[] = [];
  private context: common.Context = getContext(this) as common.Context;
  private habitId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>;
    this.habitId = Number(params?.habitId ?? 0);
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    const habitRepository = new HabitRepository(abilityContext);
    const checkinRepository = new CheckInRepository(abilityContext);
    const habit = await habitRepository.findById(this.habitId);
    if (!habit) {
      return;
    }
    this.habit = habit;
    this.checkins = await checkinRepository.findByHabitId(this.habitId);
    this.points = this.buildHeatMapPoints();
  }

  private buildHeatMapPoints(): HeatMapPoint[] {
    const dates = DateUtils.recentDates(84);
    return dates.map((date) => {
      const count = this.checkins.filter((item) => item.checkDate === date).length;
      return {
        date,
        level: Math.min(3, count)
      };
    });
  }

  private async toggleToday(): Promise<void> {
    const repository = new CheckInRepository(this.context as common.UIAbilityContext);
    const today = DateUtils.today();
    const existing = await repository.findByHabitAndDate(this.habitId, today);
    if (existing) {
      await repository.deleteByHabitAndDate(this.habitId, today);
      promptAction.showToast({ message: '已撤销今日打卡' });
    } else {
      await repository.upsert(createCheckIn(this.habitId, today));
      promptAction.showToast({ message: '今日已打卡' });
    }
    await this.syncWidget();
    await this.loadData();
  }

  private async syncWidget(): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    const habits = await new HabitRepository(abilityContext).findAll(false);
    const checkins = await new CheckInRepository(abilityContext).findAll();
    const dashboard = StatsService.buildDashboard(habits, checkins);
    await WidgetBridgeService.writeSummary(this.context, dashboard.todayTotal, dashboard.todayDone);
  }

  private async removeHabit(): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    await ReminderService.cancelReminder(this.habit.reminderId);
    await new CheckInRepository(abilityContext).deleteByHabitId(this.habit.id);
    await new HabitRepository(abilityContext).delete(this.habit.id);
    await this.syncWidget();
    promptAction.showToast({ message: '习惯已删除' });
    router.back();
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 10 }) {
            Text(`${this.habit.icon} ${this.habit.name}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text(this.habit.reminderTime ? `提醒时间 ${this.habit.reminderTime}` : '未设置提醒')
              .fontSize(13)
              .fontColor('#FFFFFFCC')
            Row({ space: 10 }) {
              Button('今天打卡')
                .backgroundColor('#FFFFFF')
                .fontColor(COLOR_PALETTE[this.habit.colorIndex % COLOR_PALETTE.length])
                .onClick(() => this.toggleToday())
              Button('编辑')
                .backgroundColor('#FFFFFF22')
                .fontColor('#FFFFFF')
                .onClick(() => router.pushUrl({ url: 'pages/HabitEditPage', params: { habitId: this.habit.id } }))
              Button('删除')
                .backgroundColor('#7F1D1D55')
                .fontColor('#FFFFFF')
                .onClick(() => this.removeHabit())
            }
          }
          .alignItems(HorizontalAlign.Start)
          .padding(20)
          .width('100%')
          .backgroundColor(COLOR_PALETTE[this.habit.colorIndex % COLOR_PALETTE.length])
          .borderRadius(28)

          HeatMapCanvas({
            points: this.points,
            title: '近 84 天热力图',
            colorIndex: this.habit.colorIndex
          })

          Column({ space: 10 }) {
            Text('打卡历史')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
              .width('100%')
              .textAlign(TextAlign.Start)
            ForEach(this.checkins, (item: CheckInModel) => {
              Row() {
                Text(item.checkDate)
                  .layoutWeight(1)
                  .fontSize(14)
                  .fontColor('#344054')
                Text(item.note ? item.note : '已完成')
                  .fontSize(13)
                  .fontColor('#667085')
              }
              .padding({ top: 8, bottom: 8 })
            }, (item: CheckInModel) => `${item.id}-${item.checkDate}`)
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
        }
        .padding(18)
        .backgroundColor('#F8FAFC')
      }
    }
    .title('习惯详情')
  }
}

export default HabitDetailPage;
