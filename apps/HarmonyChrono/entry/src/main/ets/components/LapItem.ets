import { AppConstants, LapRecord } from '../common/constants'
import { formatStopwatchTime } from '../common/utils'

@Component
export struct LapItem {
  @Prop lap: LapRecord = { id: 0, sessionId: 0, lapNumber: 0, lapTime: 0, totalTime: 0, createdAt: 0 }
  @Prop isFastest: boolean = false
  @Prop isSlowest: boolean = false

  private getBackgroundColor(): string {
    if (this.isFastest) {
      return AppConstants.FASTEST_LAP_COLOR
    }
    if (this.isSlowest) {
      return AppConstants.SLOWEST_LAP_COLOR
    }
    return AppConstants.SURFACE_COLOR
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(`Lap ${this.lap.lapNumber}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppConstants.TEXT_PRIMARY)
        Text(`Total ${formatStopwatchTime(this.lap.totalTime)}`)
          .fontSize(12)
          .fontColor(AppConstants.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text(formatStopwatchTime(this.lap.lapTime))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppConstants.TEXT_PRIMARY)
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor(this.getBackgroundColor())
  }
}
