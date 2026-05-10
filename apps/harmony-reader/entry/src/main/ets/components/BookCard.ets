import { BookInfo } from '../model/BookInfo';

@Component
export struct BookCard {
  @Prop book: BookInfo;
  @Prop onClick: (book: BookInfo) => void;
  @Prop onLongPress: (book: BookInfo) => void;

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column()
          .width('100%')
          .height(150)
          .borderRadius(16)
          .backgroundColor(this.book.coverColor);
        Text(`${this.book.progressPercent}%`)
          .fontSize(12)
          .fontColor(Color.White)
          .margin({ left: 12, bottom: 12 })
      }
      .width('100%')

      Text(this.book.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`共 ${this.book.chapterCount} 章`)
        .fontSize(12)
        .fontColor('#666666')
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(18)
    .shadow({ radius: 12, color: '#1A000000', offsetX: 0, offsetY: 6 })
    .onClick(() => this.onClick(this.book))
    .gesture(LongPressGesture({ repeat: false }).onAction(() => {
      this.onLongPress(this.book);
    }))
  }
}
