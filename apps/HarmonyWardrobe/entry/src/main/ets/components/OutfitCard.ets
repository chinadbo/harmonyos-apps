import { Clothing, OutfitView, toFileUri, categoryEmoji } from '../model/WardrobeModels'

@Component
export struct OutfitCard {
  @Prop data: OutfitView
  onCardClick: (outfitId: number) => void = (outfitId: number) => {
  }

  build() {
    Column() {
      Row() {
        Text(this.data.outfit.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2B3A4A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Text(`穿过 ${this.data.wearCount} 次`)
          .fontSize(12)
          .fontColor('#8A97A5')
      }
      .width('100%')

      Row({ space: 10 }) {
        ForEach(this.data.items, (c: Clothing) => {
          Column() {
            if (c.imagePath !== '') {
              Image(toFileUri(c.imagePath))
                .width(52)
                .height(52)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            } else {
              Text(categoryEmoji(c.category))
                .width(52)
                .height(52)
                .fontSize(26)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F2F5')
                .borderRadius(8)
            }
            Text(c.name)
              .fontSize(11)
              .fontColor('#6B7684')
              .maxLines(1)
          }
          .alignItems(HorizontalAlign.Center)
          .constraintSize({ maxWidth: 64 })
        }, (c: Clothing) => c.id.toString())
      }
      .width('100%')
      .margin({ top: 10 })
      .alignItems(VerticalAlign.Center)

      if (this.data.items.length === 0) {
        Text('（该搭配的单品已被删除）')
          .fontSize(12)
          .fontColor('#B0B9C4')
          .margin({ top: 6 })
      }
    }
    .padding(12)
    .borderRadius(12)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => this.onCardClick(this.data.outfit.id))
  }
}
