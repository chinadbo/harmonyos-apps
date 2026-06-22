import router from '@ohos.router';
import { Goal, GoalStatistics } from '../model/GoalModel';
import { GoalCard } from '../components/GoalCard';
import { EmptyState } from '../components/EmptyState';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct HomePage {
  @StorageProp('goals') goals: Goal[] = [];
  @StorageProp('statistics') statistics: GoalStatistics = {
    totalGoals: 0,
    activeGoals: 0,
    completedGoals: 0,
    pausedGoals: 0,
    averageProgress: 0,
    averageKrCompletion: 0,
    completionRate: 0,
    totalCheckIns: 0
  };

  private goCreateGoal(goalId?: number): void {
    router.pushUrl({
      url: 'pages/CreateGoalPage',
      params: goalId ? { goalId } : {}
    });
  }

  private goCheckIn(goalId: number): void {
    router.pushUrl({
      url: 'pages/CheckInPage',
      params: { goalId }
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyGoal')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#18202A')
            Text('把长期目标拆成每天都能完成的一小步。')
              .fontSize(14)
              .fontColor('#5E6B7A')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Row({ space: 8 }) {
            Button('统计')
              .height(38)
              .backgroundColor('#EDF2FF')
              .fontColor('#4C7DFF')
              .onClick(() => router.pushUrl({ url: 'pages/StatisticsPage' }))
            Button('设置')
              .height(38)
              .backgroundColor('#F3F5F8')
              .fontColor('#18202A')
              .onClick(() => router.pushUrl({ url: 'pages/SettingsPage' }))
          }
        }
        .width('100%')

        Row({ space: 12 }) {
          this.statCard('目标总数', `${this.statistics.totalGoals}`, '#4C7DFF')
          this.statCard('进行中', `${this.statistics.activeGoals}`, '#20C997')
        }
        .width('100%')

        Row({ space: 12 }) {
          this.statCard('已完成', `${this.statistics.completedGoals}`, '#8E6CFF')
          this.statCard('平均进度', `${this.statistics.averageProgress}%`, '#FF9F43')
        }
        .width('100%')

        Row() {
          Text('目标清单')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Button('新建目标')
            .height(40)
            .backgroundColor('#4C7DFF')
            .onClick(() => this.goCreateGoal())
        }
        .width('100%')

        if (this.goals.length === 0) {
          EmptyState({
            title: '还没有目标',
            description: '创建你的第一个目标，把愿望变成可追踪的关键结果。',
            actionText: '创建目标',
            onAction: () => this.goCreateGoal()
          })
        } else {
          Column({ space: 12 }) {
            ForEach(this.goals, (goal: Goal) => {
              GoalCard({
                goal: goal,
                onCheckIn: (goalId: number) => this.goCheckIn(goalId),
                onEdit: (goalId: number) => this.goCreateGoal(goalId)
              })
            }, (goal: Goal) => `${goal.id}`)
          }
          .width('100%')
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
    .onAppear(async () => {
      await goalViewModel.refreshAll();
    })
  }

  @Builder
  private statCard(title: string, value: string, color: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#5E6B7A')
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
