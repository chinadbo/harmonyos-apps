
@Component
export struct EmptyState {
  @Prop message: string;
  @Prop icon: string = '📭';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 12 })

      Text(this.message)
        .fontSize(16)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
