@Component
export struct EmptyView {
  @Prop title: string = '暂无数据';
  @Prop message: string = '去添加一些内容吧';

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#233321')
      Text(this.message)
        .fontSize(14)
        .fontColor('#6B7E68')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
