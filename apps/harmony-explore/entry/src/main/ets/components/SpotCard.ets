import { SpotModel } from '../model/SpotModel'

@Component
export struct SpotCard {
  @Prop spot: SpotModel

  build() {
    Row({ space: 12 }) {
      if (this.spot.coverUri.length > 0) {
        Image(this.spot.coverUri)
          .width(72)
          .height(72)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
      } else {
        Stack() {
          Text(this.spot.name.length > 0 ? this.spot.name.substring(0, 1) : '📍')
            .fontSize(28)
        }
        .width(72)
        .height(72)
        .backgroundColor('#E8F3FF')
        .borderRadius(16)
      }
      Column({ space: 6 }) {
        Text(this.spot.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
        Text(`${this.spot.city} · ${this.spot.category}`)
          .fontSize(14)
          .fontColor('#666666')
        Text(this.spot.address)
          .fontSize(13)
          .fontColor('#8A8A8A')
          .maxLines(2)
        Row() {
          Text('已打卡 ' + this.spot.checkInCount + ' 次')
            .fontSize(12)
            .fontColor('#0A59F7')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#EAF1FF')
            .borderRadius(12)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
