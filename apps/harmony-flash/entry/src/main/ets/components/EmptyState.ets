@Component
export struct EmptyState {
  @Prop emoji: string = '📭';
  @Prop title: string = '暂无内容';
  @Prop subtitle: string = '';
  @BuilderParam actionBuilder?: () => void;

  build() {
    Column() {
      Text(this.emoji)
        .fontSize(56)
        .margin({ bottom: 16 })
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .margin({ bottom: 8 })
      if (this.subtitle) {
        Text(this.subtitle)
          .fontSize(14)
          .fontColor('#9CA3AF')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
      }
      if (this.actionBuilder) {
        this.actionBuilder()
      }
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
