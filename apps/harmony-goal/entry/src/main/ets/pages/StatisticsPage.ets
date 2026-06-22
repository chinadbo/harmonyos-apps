import router from '@ohos.router';
import { ChartPoint, GoalStatistics } from '../model/GoalModel';
import { LineChart } from '../components/LineChart';

@Entry
@Component
struct StatisticsPage {
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
  @StorageProp('chartPoints') chartPoints: ChartPoint[] = [];

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .height(36)
            .backgroundColor('#F3F5F8')
            .fontColor('#18202A')
            .onClick(() => router.back())
          Text('统计分析')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        LineChart({ points: this.chartPoints, color: '#4C7DFF', heightValue: 220 })

        Row({ space: 12 }) {
          this.metric('目标完成率', `${this.statistics.completionRate}%`, '#4C7DFF')
          this.metric('平均目标进度', `${this.statistics.averageProgress}%`, '#20C997')
        }
        .width('100%')

        Row({ space: 12 }) {
          this.metric('平均 KR 达成', `${this.statistics.averageKrCompletion}%`, '#8E6CFF')
          this.metric('累计回顾次数', `${this.statistics.totalCheckIns}`, '#FF9F43')
        }
        .width('100%')

        Row({ space: 12 }) {
          this.metric('活跃目标', `${this.statistics.activeGoals}`, '#4C7DFF')
          this.metric('暂停目标', `${this.statistics.pausedGoals}`, '#FF6B6B')
        }
        .width('100%')
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }

  @Builder
  private metric(title: string, value: string, color: string) {
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
