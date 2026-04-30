/**
 * 空状态通用组件
 * 当列表无数据时展示图标、文案和可选操作按钮
 */
@Component
export struct EmptyState {
  @Prop icon: ResourceStr = $r('sys.media.ohos_ic_public_empty');
  @Prop message: string = '暂无内容';
  @Prop actionText: string = '';
  onAction: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Image(this.icon)
        .width(80)
        .height(80)
        .opacity(0.3)

      Text(this.message)
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })

      if (this.actionText) {
        Button(this.actionText)
          .fontSize(14)
          .fontColor($r('app.color.primary_color'))
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: $r('app.color.primary_color'), radius: 20 })
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
