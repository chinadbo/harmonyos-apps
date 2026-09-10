import { SessionRecord } from '../common/constants'
import { formatDuration, formatSessionDate } from '../common/utils'

@Component
export struct SessionCard {
  @Prop session: SessionRecord = { id: 0, name: '', startTime: 0, endTime: 0, duration: 0, createdAt: 0 }
  @Prop lapCount: number = 0

  build() {
    Column({ space: 8 }) {
      Text(this.session.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(formatSessionDate(this.session.startTime))
        .fontSize(13)
        .fontColor('#6B7280')
        .width('100%')
        .textAlign(TextAlign.Start)
      Row() {
        Text(`Duration ${formatDuration(this.session.duration)}`)
          .fontSize(14)
          .fontColor('#1F2937')
        Blank()
        Text(`${this.lapCount} laps`)
          .fontSize(14)
          .fontColor('#6B7280')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }
}
