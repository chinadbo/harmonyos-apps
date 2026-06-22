@Component
export struct EmptyState {
  @Prop title: string = '还没有内容';
  @Prop description: string = '从创建第一个目标开始，积累每一天的进展。';
  @Prop actionText: string = '立即创建';
  @Prop onAction?: () => void;

  build() {
    Column({ space: 12 }) {
      Text('◌')
        .fontSize(42)
        .fontColor('#C3CDDA')
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18202A')
      Text(this.description)
        .fontSize(14)
        .fontColor('#5E6B7A')
        .textAlign(TextAlign.Center)
      Button(this.actionText)
        .height(40)
        .backgroundColor('#4C7DFF')
        .onClick(() => {
          if (this.onAction) {
            this.onAction();
          }
        })
    }
    .width('100%')
    .padding({ top: 36, bottom: 36, left: 24, right: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
