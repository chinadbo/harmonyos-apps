/**
 * PageHeader.ets — 页面标题栏（支持返回、右侧动作）
 */
import { C_TEXT, C_SUB, C_BRAND } from '../common/Constants';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  @Prop showBack: boolean = true;
  @Prop actionEnabled: boolean = true;
  onAction: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Row() {
      if (this.showBack) {
        Text('‹')
          .fontSize(32)
          .fontColor(C_TEXT)
          .width(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onBack())
      }
      Column() {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_TEXT)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(C_SUB)
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.actionText.length > 0) {
        Button(this.actionText)
          .fontSize(15)
          .fontColor(0xFFFFFF)
          .backgroundColor(this.actionEnabled ? C_BRAND : C_SUB)
          .height(36)
          .padding({ left: 18, right: 18 })
          .enabled(this.actionEnabled)
          .borderRadius(18)
          .onClick(() => {
            if (this.actionEnabled) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }
}
