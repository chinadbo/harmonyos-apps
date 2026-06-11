@Component
export struct WaterWidgetCard {
  @Prop total: number = 0
  @Prop goal: number = 2000

  build() {
    Column({ space: 8 }) {
      Text('今日饮水')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Text(`${this.total} / ${this.goal} ml`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0A7BFF')
      Text('记得及时补水')
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
