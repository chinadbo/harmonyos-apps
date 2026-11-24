import { Theme } from '../common/Theme';

/** 空状态占位 */
@Component
export struct EmptyView {
  @Prop title: string = '暂无内容';
  @Prop subtitle: string = '';

  build() {
    Column() {
      Stack() {
      }
      .width(64)
      .height(64)
      .borderRadius(32)
      .backgroundColor('#EEF1F7')
      .margin({ bottom: 14 })

      Text(this.title)
        .fontSize(15)
        .fontColor(Theme.text)
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(12)
          .fontColor(Theme.subText)
          .margin({ top: 6 })
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding({ top: 60, bottom: 60, left: 32, right: 32 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
