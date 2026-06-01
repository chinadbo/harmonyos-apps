import common from '@ohos.app.ability.common'
import TripDao from '../database/TripDao'
import ItemDao, { MissedItemStat } from '../database/ItemDao'
import { TripSummary } from '../model/Trip'
import StatsChart from '../components/StatsChart'

@Component
export struct StatsPage {
  @State chartValues: number[] = []
  @State chartLabels: string[] = []
  @State missedItems: MissedItemStat[] = []
  @State monthTripCount: number = 0
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    const summaries = await TripDao.listRecentSummaries(this.context, 6)
    this.chartValues = summaries.map((item: TripSummary) => item.progress)
    this.chartLabels = summaries.map((item: TripSummary) => {
      const date = new Date(item.trip.startDate)
      return `${date.getMonth() + 1}/${date.getDate()}`
    })
    this.missedItems = await ItemDao.listMissedTop5(this.context)
    const now = new Date()
    this.monthTripCount = await TripDao.getMonthTripCount(this.context, now.getFullYear(), now.getMonth() + 1)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('统计分析')
          .width('100%')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')

        Column({ space: 10 }) {
          Text('近 6 次出行打包完成率')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          StatsChart({ values: this.chartValues, labels: this.chartLabels })
        }
        .width('100%')

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('本月出行次数')
              .fontSize(14)
              .fontColor('#64748B')
            Text(`${this.monthTripCount}`)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2563EB')
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)

          Column({ space: 8 }) {
            Text('漏带统计')
              .fontSize(14)
              .fontColor('#64748B')
            Text(`${this.missedItems.length} 项上榜`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F97316')
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('最常漏带 Top5')
            .width('100%')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          if (this.missedItems.length === 0) {
            Text('暂无漏带记录，继续保持。')
              .width('100%')
              .padding(16)
              .fontSize(14)
              .fontColor('#94A3B8')
              .backgroundColor('#FFFFFF')
              .borderRadius(18)
          } else {
            ForEach(this.missedItems, (item: MissedItemStat, index?: number) => {
              Row() {
                Text(`${(index || 0) + 1}. ${item.name}`)
                  .fontSize(16)
                  .fontColor('#0F172A')
                Blank()
                Text(`${item.missedCount} 次`)
                  .fontSize(14)
                  .fontColor('#EF4444')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
            }, (item: MissedItemStat) => item.name)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .padding({ bottom: 28 })
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F8FAFC')
  }
}
