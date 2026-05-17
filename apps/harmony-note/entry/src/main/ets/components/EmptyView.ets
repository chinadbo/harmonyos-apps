@Component
export struct EmptyView {
  @Prop title: string = '暂无内容';
  @Prop description: string = '请先创建数据';
  @Prop buttonText: string = '';
  onAction?: () => void;

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')

      Text(this.description)
        .fontSize(14)
        .fontColor('#6B7280')
        .textAlign(TextAlign.Center)
        .lineHeight(22)

      if (this.buttonText.length > 0) {
        Button(this.buttonText)
          .type(ButtonType.Capsule)
          .backgroundColor('#2563EB')
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
