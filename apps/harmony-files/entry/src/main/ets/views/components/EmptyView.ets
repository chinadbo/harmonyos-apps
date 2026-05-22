@Component
export struct EmptyView {
  @Prop message: string;

  build() {
    Column() {
      Text('📂')
        .fontSize(48)
        .margin({ bottom: 12 })

      Text(this.message)
        .fontSize(15)
        .fontColor('#999')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
