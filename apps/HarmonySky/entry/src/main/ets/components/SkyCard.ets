// 数据卡片组件
@Component
export struct SkyCard {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @BuilderParam content: () => void = this.emptyContent;

  @Builder
  emptyContent() {
  }

  build() {
    Column({ space: 10 }) {
      if (this.title !== '') {
        Row({ space: 8 }) {
          Text(this.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F2F5FF')
          if (this.subtitle !== '') {
            Text(this.subtitle)
              .fontSize(12)
              .fontColor('#9AA3C7')
          }
        }
        .width('100%')
      }
      this.content()
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor('#161B3A')
    .alignItems(HorizontalAlign.Start)
  }
}
