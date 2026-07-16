import { Constants } from '../utils/Constants';
import { TabItem } from '../model/TabItem';

@Component
export struct TabCard {
  @Prop tab: TabItem;
  onSelect: () => void = () => {};
  onClose: () => void = () => {};

  build() {
    Row() {
      Column() {
        Text(this.tab.title || this.tab.url)
          .fontSize(14)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('80%')
        Text(this.tab.url)
          .fontSize(11)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('80%')
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
      .onClick(() => this.onClose())
    }
    .width('100%')
    .height(60)
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => this.onSelect())
  }
}
