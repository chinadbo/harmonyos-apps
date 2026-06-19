@Component
export struct EmptyState {
  @Prop title: string;
  @Prop description: string;

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text(this.description)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(20)
  }
}
