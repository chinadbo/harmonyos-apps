@Component
export struct EmptyState {
  @Prop title: string = '暂无数据';
  @Prop description: string = '添加一个快递单号后，这里会展示追踪记录。';

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
      Text(this.description)
        .fontSize(14)
        .fontColor('#667085')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#F8FAFC')
    .borderRadius(24)
  }
}
