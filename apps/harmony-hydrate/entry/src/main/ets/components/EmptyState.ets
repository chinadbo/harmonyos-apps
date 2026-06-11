@Component
export struct EmptyState {
  @Prop title: string = '暂无记录'
  @Prop subtitle: string = '先喝一杯水开始记录吧'

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text(this.subtitle)
        .fontSize(14)
        .fontColor('#888888')
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
  }
}
