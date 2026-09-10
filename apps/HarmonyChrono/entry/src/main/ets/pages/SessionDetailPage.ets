import router from '@ohos.router'
import { LapItem } from '../components/LapItem'
import { LapRecord, SessionDetail } from '../common/constants'
import { AppStyles } from '../common/styles'
import { formatDuration, formatStopwatchTime, getLapStats } from '../common/utils'
import { sessionModel } from '../model/SessionModel'

@Component
export struct SessionDetailPage {
  @State private detail: SessionDetail | null = null

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Object
    const sessionId = Number((params as Record<string, Object>)['sessionId'] ?? 0)
    this.detail = await sessionModel.getSessionDetail(sessionId)
  }

  build() {
    const laps: LapRecord[] = this.detail ? this.detail.laps : []
    const lapStats = getLapStats(laps)
    Column({ space: 16 }) {
      Row() {
        Button('Back')
          .backgroundColor('#FFFFFF')
          .fontColor('#1F2937')
          .onClick(() => router.back())
        Blank()
        Text(this.detail ? this.detail.name : 'Session detail')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
      }
      .width('100%')

      if (this.detail) {
        Scroll() {
          Column({ space: 12 }) {
            Column({ space: 8 }) {
              Text(`Total ${formatDuration(this.detail ? this.detail.duration : 0)}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
              Text(`${laps.length} laps recorded`)
                .fontSize(14)
                .fontColor('#6B7280')
              Text(`Average ${formatStopwatchTime(lapStats.averageLap)}`)
                .fontSize(14)
                .fontColor('#6B7280')
              Text(`Fastest ${formatStopwatchTime(lapStats.fastestLap)} · Slowest ${formatStopwatchTime(lapStats.slowestLap)}`)
                .fontSize(14)
                .fontColor('#6B7280')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .alignItems(HorizontalAlign.Start)

            ForEach(laps, (lap: LapRecord) => {
              LapItem({
                lap,
                isFastest: laps.length > 1 && lap.lapNumber === lapStats.fastestLapNumber,
                isSlowest: laps.length > 1 && lap.lapNumber === lapStats.slowestLapNumber
              })
            }, (lap: LapRecord) => `${lap.id}`)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Text('Session not found')
            .fontSize(16)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .padding(AppStyles.PAGE_HORIZONTAL_PADDING)
    .backgroundColor(AppStyles.BACKGROUND_COLOR)
  }
}
