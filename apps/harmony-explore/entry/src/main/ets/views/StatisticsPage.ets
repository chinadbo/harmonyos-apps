import { DatabaseService } from '../service/DatabaseService'
import { DateUtils } from '../utils/DateUtils'
import { StatsChart, StatisticsBarItem } from '../components/StatsChart'

@Component
export struct StatisticsPage {
  @Watch('onRefreshChanged') @StorageLink('refreshToken') refreshToken: number = 0
  @State private totalCheckIns: number = 0
  @State private totalCities: number = 0
  @State private bars: StatisticsBarItem[] = []
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()

  aboutToAppear(): void {
    this.loadStatistics()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text($r('app.string.title_statistics'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text($r('app.string.label_total_checkins'))
              .fontSize(14)
              .fontColor('#666666')
            Text(`${this.totalCheckIns}`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          Column({ space: 8 }) {
            Text($r('app.string.label_total_cities'))
              .fontSize(14)
              .fontColor('#666666')
            Text(`${this.totalCities}`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        Column({ space: 12 }) {
          Text($r('app.string.label_recent_activity'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          StatsChart({ bars: this.bars })
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private onRefreshChanged(): void {
    this.loadStatistics()
  }

  private async loadStatistics(): Promise<void> {
    const summary = await this.databaseService.getStatisticsSummary()
    this.totalCheckIns = summary.totalCheckIns
    this.totalCities = summary.totalCities
    this.bars = summary.recent.map((item) => ({
      label: DateUtils.formatMonthDay(item.date),
      value: item.count
    }))
  }
}
