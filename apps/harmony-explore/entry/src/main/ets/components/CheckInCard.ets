import { CheckInDetailModel } from '../model/CheckInModel'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct CheckInCard {
  @Prop item: CheckInDetailModel

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.item.spotName)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Text(`${this.item.city} · ${this.item.category}`)
            .fontSize(13)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(DateUtils.formatDateTime(this.item.checkInAt))
          .fontSize(12)
          .fontColor('#8A8A8A')
      }
      Text(this.item.note.length > 0 ? this.item.note : $r('app.string.label_empty_note_card'))
        .fontSize(14)
        .fontColor('#333333')
        .maxLines(3)
      Row({ space: 8 }) {
        Text('心情：' + (this.item.mood || '未记录'))
          .fontSize(12)
          .fontColor('#0A59F7')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#EAF1FF')
          .borderRadius(12)
        Text('天气：' + (this.item.weather || '未记录'))
          .fontSize(12)
          .fontColor('#FF7A00')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#FFF1E6')
          .borderRadius(12)
      }
      if (this.item.photoUris.length > 0) {
        Text(`照片 ${this.item.photoUris.length} 张`)
          .fontSize(12)
          .fontColor('#8A8A8A')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
