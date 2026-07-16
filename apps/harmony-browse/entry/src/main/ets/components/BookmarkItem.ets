import { Bookmark } from '../model/Bookmark';

@Component
export struct BookmarkItem {
  @Prop bookmark: Bookmark;
  onSelect: () => void = () => {};
  onDelete: () => void = () => {};

  build() {
    Row() {
      Column() {
        Text(this.bookmark.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.bookmark.url)
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button() {
        Text('×')
          .fontSize(18)
          .fontColor('#666666')
      }
      .width(32)
      .height(32)
      .backgroundColor(Color.Transparent)
      .onClick(() => this.onDelete())
    }
    .width('100%')
    .height(56)
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .margin({ bottom: 6 })
    .onClick(() => this.onSelect())
  }
}
