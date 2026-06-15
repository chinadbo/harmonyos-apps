@Component
export struct EmptyView {
  @Prop title: string = '暂无文档';
  @Prop message: string = '点击右下角按钮开始第一次扫描';

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')
      Text(this.message)
        .fontSize(15)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 48, bottom: 48 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
