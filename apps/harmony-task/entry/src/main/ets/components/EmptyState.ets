@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';
  @Prop icon: string = '📋';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(64)
        .margin({ bottom: 16 })

      Text(this.message)
        .fontSize(16)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(48)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
