import type { FeedLog } from '../model/FeedLog'
import { DateUtils } from '../common/DateUtils'

@Component
export struct FeedItem {
  @Prop item: FeedLog

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.item.foodType)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(`${this.item.amount}${this.item.unit}`)
          .fontSize(13)
          .fontColor('#666666')
        if (this.item.note) {
          Text(this.item.note)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(DateUtils.formatDisplayDateTime(this.item.feedTime))
        .fontSize(12)
        .fontColor('#888888')
    }
    .padding(14)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
  }
}
