import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { HabitRepository } from '../database/HabitRepository';
import { CheckInRepository } from '../database/CheckInRepository';
import { HabitModel } from '../model/HabitModel';
import { CheckInModel } from '../model/CheckInModel';
import { StatsService, DashboardStats } from '../service/StatsService';
import { DateUtils } from '../common/DateUtils';

@Entry
@Component
struct StatisticsPage {
  @State habits: HabitModel[] = [];
  @State checkins: CheckInModel[] = [];
  @State dashboard: DashboardStats = {
    totalHabits: 0,
    activeHabits: 0,
    todayTotal: 0,
    todayDone: 0,
    completionRate: 0,
    longestStreak: 0,
    recent7Days: []
  };
  private context: common.Context = getContext(this) as common.Context;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const abilityContext = this.context as common.UIAbilityContext;
    this.habits = await new HabitRepository(abilityContext).findAll(true);
    this.checkins = await new CheckInRepository(abilityContext).findAll();
    this.dashboard = StatsService.buildDashboard(this.habits, this.checkins);
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 16 }) {
          Text(`统计日期：${DateUtils.today()}`)
            .fontSize(13)
            .fontColor('#667085')
            .width('100%')
            .textAlign(TextAlign.Start)

          GridRow() {
            GridCol({ span: 6 }) {
              this.metricCard('总习惯数', `${this.dashboard.totalHabits}`, '#EEF2FF');
            }
            GridCol({ span: 6 }) {
              this.metricCard('激活习惯', `${this.dashboard.activeHabits}`, '#ECFDF3');
            }
            GridCol({ span: 6 }) {
              this.metricCard('今日完成率', `${this.dashboard.completionRate}%`, '#FFF7ED');
            }
            GridCol({ span: 6 }) {
              this.metricCard('最长连击', `${this.dashboard.longestStreak}天`, '#FDF2F8');
            }
          }

          Column({ space: 10 }) {
            Text('最近 7 天打卡次数')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
              .width('100%')
              .textAlign(TextAlign.Start)

            ForEach(this.dashboard.recent7Days, (value: number, index: number) => {
              Row({ space: 12 }) {
                Text(DateUtils.recentDates(7)[index])
                  .width(96)
                  .fontSize(12)
                  .fontColor('#475467')
                Stack({ alignContent: Alignment.Start }) {
                  Row()
                    .width('100%')
                    .height(14)
                    .backgroundColor('#E5E7EB')
                    .borderRadius(7)
                  Row()
                    .width(`${Math.max(8, value * 22)}vp`)
                    .height(14)
                    .backgroundColor('#4F46E5')
                    .borderRadius(7)
                }
                .layoutWeight(1)
                Text(`${value}`)
                  .fontSize(12)
                  .fontColor('#667085')
              }
            })
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)

          Column({ space: 10 }) {
            Text('习惯完成快照')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
              .width('100%')
              .textAlign(TextAlign.Start)

            ForEach(this.habits, (habit: HabitModel) => {
              Row() {
                Text(`${habit.icon} ${habit.name}`)
                  .layoutWeight(1)
                  .fontSize(14)
                  .fontColor('#344054')
                Text(`${this.checkins.filter((item) => item.habitId === habit.id).length} 次`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111827')
                Button('查看')
                  .margin({ left: 10 })
                  .height(30)
                  .fontSize(12)
                  .backgroundColor('#EEF2FF')
                  .fontColor('#3730A3')
                  .onClick(() => router.pushUrl({ url: 'pages/HabitDetailPage', params: { habitId: habit.id } }))
              }
              .padding({ top: 6, bottom: 6 })
            }, (habit: HabitModel) => `${habit.id}`)
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
        }
        .padding(18)
        .width('100%')
        .backgroundColor('#F8FAFC')
      }
    }
    .title('统计概览')
  }

  @Builder
  private metricCard(title: string, value: string, bgColor: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#667085')
      Text(value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .margin({ right: 8, bottom: 8 })
    .backgroundColor(bgColor)
    .borderRadius(22)
  }
}

export default StatisticsPage;
