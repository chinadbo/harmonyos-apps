import promptAction from '@ohos.promptAction'
import { WeeklyBarChart } from '../components/WeeklyBarChart'
import { DayStats, WeekStats } from '../model/WeekStats'
import { WaterService } from '../service/WaterService'
import { StatsService } from '../service/StatsService'

@Component
export struct StatsPage {
  @State weekStats: WeekStats = new WeekStats()
  @State chartSeed: number = 0
  private waterService: WaterService = WaterService.getInstance()
  private statsService: StatsService = StatsService.getInstance()

  async aboutToAppear(): Promise<void> {
    try {
      const goal = await this.waterService.getGoal()
      this.weekStats = await this.statsService.getWeekStats(goal.amount)
      this.chartSeed++
    } catch (error) {
      promptAction.showToast({ message: '统计加载失败' })
    }
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Text('近 7 天饮水统计')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        WeeklyBarChart({ items: this.weekStats.items, chartSeed: this.chartSeed })

        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('周平均')
              .fontSize(14)
              .fontColor('#666666')
            Text(`${this.weekStats.weeklyAverage} ml`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)

          Column({ space: 6 }) {
            Text('达标率')
              .fontSize(14)
              .fontColor('#666666')
            Text(`${this.weekStats.completionRate}%`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
        }
        .width('100%')

        Column({ space: 8 }) {
          Text('每日详情')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          ForEach(this.weekStats.items, (item: DayStats) => {
            Row() {
              Text(item.date)
                .fontSize(14)
              Blank()
              Text(`${item.total} ml`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
          }, (item: DayStats) => item.date)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
    }
  }
}
