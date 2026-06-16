@Component
export struct EmptyState {
  @Prop title: string = '暂无内容';
  @Prop description: string = '先添加一些数据吧';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
      Text(this.description)
        .fontSize(14)
        .fontColor('#6B7280')
        .textAlign(TextAlign.Center)
      if (this.actionText.length > 0) {
        Button(this.actionText)
          .height(40)
          .backgroundColor('#FF7A59')
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
