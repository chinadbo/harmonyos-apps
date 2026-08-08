import { TimezoneModel } from '../models/TimezoneModel'
import { TimeUtils } from '../utils/TimeUtils'

@Component
export struct WorldClockPage {
  @Prop zones: Array<TimezoneModel> = []
  @Prop currentTime: Date = new Date()

  build() {
    Column({ space: 12 }) {
      Text('World Clock')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      if (this.zones.length === 0) {
        Text('No world clocks configured')
          .fontSize(15)
          .fontColor('#666666')
          .width('100%')
      } else {
        ForEach(this.zones, (zone: TimezoneModel) => {
          Row() {
            Column({ space: 4 }) {
              Text(zone.city)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
              Text(zone.country)
                .fontSize(13)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(TimeUtils.getWorldClockTime(zone, this.currentTime))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Text(zone.getOffsetLabel())
                .fontSize(13)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }, (zone: TimezoneModel) => zone.id)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
