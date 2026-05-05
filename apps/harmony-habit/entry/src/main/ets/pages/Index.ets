import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { HabitCard } from '../components/HabitCard';
import { HabitRepository } from '../database/HabitRepository';
import { CheckInRepository } from '../database/CheckInRepository';
import { HabitModel } from '../model/HabitModel';
import { CheckInModel, createCheckIn } from '../model/CheckInModel';
import { StatsService, HabitSummaryItem } from '../service/StatsService';
import { DateUtils } from '../common/DateUtils';
import { WidgetBridgeService } from '../service/WidgetBridgeService';

@Entry
@Component
struct Index {
  @State habits: HabitModel[] = [];
  @State checkins: CheckInModel[] = [];
  @State todayItems: HabitSummaryItem[] = [];
  @State loading: boolean = true;
  private context: common.Context = getContext(this) as common.Context;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.loading = true;
    const abilityContext = this.context as common.UIAbilityContext;
    const habitRepository = new HabitRepository(abilityContext);
    const checkinRepository = new CheckInRepository(abilityContext);
    this.habits = await habitRepository.findAll(false);
    this.checkins = await checkinRepository.findAll();
    this.todayItems = this.habits
      .filter((item) => DateUtils.isHabitScheduled(item.targetDays, DateUtils.today()))
      .map((habit) => StatsService.buildHabitSummary(habit, this.checkins.filter((checkin) => checkin.habitId === habit.id)));
    const dashboard = StatsService.buildDashboard(this.habits, this.checkins);
    await WidgetBridgeService.writeSummary(this.context, dashboard.todayTotal, dashboard.todayDone);
    this.loading = false;
  }

  private async toggleCheckin(habitId: number): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    const repository = new CheckInRepository(abilityContext);
    const today = DateUtils.today();
    const existing = await repository.findByHabitAndDate(habitId, today);
    if (existing) {
      await repository.deleteByHabitAndDate(habitId, today);
      promptAction.showToast({ message: '已撤销今日打卡' });
    } else {
      await repository.upsert(createCheckIn(habitId, today));
      promptAction.showToast({ message: '打卡成功' });
    }
    await this.loadData();
  }

  private goStatistics(): void {
    router.pushUrl({ url: 'pages/StatisticsPage' });
  }

  private goEdit(id: number = 0): void {
    router.pushUrl({
      url: 'pages/HabitEditPage',
      params: { habitId: id }
    });
  }

  private goDetail(id: number): void {
    router.pushUrl({
      url: 'pages/HabitDetailPage',
      params: { habitId: id }
    });
  }

  build() {
    Navigation() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyHabit')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
            Text(`今天 ${DateUtils.today()}`)
              .fontSize(14)
              .fontColor('#667085')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button('统计')
            .height(38)
            .backgroundColor('#111827')
            .fontColor('#FFFFFF')
            .onClick(() => this.goStatistics())
        }

        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text(`${this.todayItems.filter((item) => item.completedToday).length}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
            Text('今日已完成')
              .fontSize(12)
              .fontColor('#667085')
          }
          .layoutWeight(1)
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(22)

          Column({ space: 6 }) {
            Text(`${this.todayItems.length}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
            Text('今日待完成')
              .fontSize(12)
              .fontColor('#667085')
          }
          .layoutWeight(1)
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(22)
        }

        Button('新建习惯')
          .width('100%')
          .height(46)
          .backgroundColor('#4F46E5')
          .fontColor('#FFFFFF')
          .onClick(() => this.goEdit())

        if (this.loading) {
          LoadingProgress()
            .width(32)
            .height(32)
        } else if (this.todayItems.length === 0) {
          Column({ space: 10 }) {
            Text('今天没有需要打卡的习惯')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#344054')
            Text('创建一个习惯，或者给现有习惯设置今天的频率。')
              .fontSize(13)
              .fontColor('#98A2B3')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
        } else {
          List({ space: 14 }) {
            ForEach(this.todayItems, (item: HabitSummaryItem) => {
              ListItem() {
                HabitCard({
                  habit: item.habit,
                  completed: item.completedToday,
                  streak: item.currentStreak,
                  onToggle: (id: number) => this.toggleCheckin(id),
                  onEdit: (id: number) => this.goEdit(id),
                  onView: (id: number) => this.goDetail(id)
                })
              }
            }, (item: HabitSummaryItem) => `${item.habit.id}`)
          }
          .divider({ strokeWidth: 0 })
          .width('100%')
          .layoutWeight(1)
        }
      }
      .padding(18)
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FAFC')
    }
    .title('今日打卡')
    .hideBackButton(true)
  }
}

export default Index;
