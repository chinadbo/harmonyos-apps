import { Clothing, toFileUri, categoryEmoji } from '../model/WardrobeModels'

@Component
export struct WardrobeCard {
  @Prop clothing: Clothing
  onCardClick: (id: number) => void = (id: number) => {
  }

  build() {
    Column() {
      if (this.clothing.imagePath !== '') {
        Image(toFileUri(this.clothing.imagePath))
          .width('100%')
          .height(110)
          .borderRadius(10)
          .objectFit(ImageFit.Cover)
      } else {
        Text(categoryEmoji(this.clothing.category))
          .width('100%')
          .height(110)
          .fontSize(48)
          .textAlign(TextAlign.Center)
          .backgroundColor('#EEF1F5')
          .borderRadius(10)
      }
      Text(this.clothing.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2B3A4A')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 6 })
      Row() {
        Text(this.clothing.category)
          .fontSize(11)
          .fontColor('#6B7684')
          .backgroundColor('#F0F2F5')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        Text(this.clothing.season)
          .fontSize(11)
          .fontColor('#6B7684')
          .margin({ left: 6 })
        Blank()
        Text(this.clothing.colorName)
          .fontSize(11)
          .fontColor('#6B7684')
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .padding(8)
    .borderRadius(12)
    .backgroundColor(Color.White)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.onCardClick(this.clothing.id))
  }
}
