import { Deck } from '../model/Deck';

@Component
export struct DeckCard {
  @Prop deck: Deck = {} as Deck;
  onTap?: () => void;

  build() {
    Row() {
      // 图标
      Column() {
        Text('📚')
          .fontSize(28)
      }
      .width(56)
      .height(56)
      .backgroundColor('#EFF6FF')
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 16 })

      // 信息
      Column() {
        Row() {
          Text(this.deck.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A2E')
            .layoutWeight(1)
          if (this.deck.isBuiltIn === 1) {
            Text('内置')
              .fontSize(11)
              .fontColor('#3B82F6')
              .backgroundColor('#EFF6FF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .width('100%')
        .margin({ bottom: 6 })

        Text(this.deck.description)
          .fontSize(13)
          .fontColor('#9CA3AF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        // 进度条
        Row() {
          Text(`${this.deck.masteredCount}/${this.deck.cardCount}`)
            .fontSize(12)
            .fontColor('#6B7280')
          Blank()
          Text(`${this.deck.cardCount > 0 ? Math.round(this.deck.masteredCount / this.deck.cardCount * 100) : 0}%`)
            .fontSize(12)
            .fontColor('#3B82F6')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .margin({ bottom: 4 })

        Progress({
          value: this.deck.cardCount > 0 ? this.deck.masteredCount / this.deck.cardCount * 100 : 0,
          total: 100,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(4)
          .color('#3B82F6')
          .backgroundColor('#E5E7EB')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}
