/**
 * EmptyView.ets — 空态占位
 */
import { C_SUB, C_BRAND, C_LINE } from '../common/Constants';

@Component
export struct EmptyView {
  @Prop icon: string = '◇';
  @Prop title: string = '暂无内容';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  onAction: () => void = () => {};

  build() {
    Column() {
      Text(this.icon)
        .fontSize(64)
        .fontColor(C_LINE)
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(C_SUB)
        .margin({ top: 14 })
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(13)
          .fontColor(C_SUB)
          .margin({ top: 6 })
          .textAlign(TextAlign.Center)
          .padding({ left: 30, right: 30 })
      }
      if (this.actionText.length > 0) {
        Button(this.actionText)
          .fontSize(15)
          .fontColor(0xFFFFFF)
          .backgroundColor(C_BRAND)
          .height(40)
          .padding({ left: 24, right: 24 })
          .borderRadius(20)
          .margin({ top: 20 })
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
