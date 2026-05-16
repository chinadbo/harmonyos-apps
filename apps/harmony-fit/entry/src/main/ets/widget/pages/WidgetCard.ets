@Entry
@Component
export struct WidgetCard {
  @State steps: number = 0
  @State goal: number = 8000
  @State progress: string = '0%'

  build() {
    Column({ space: 10 }) {
      Text('HarmonyFit')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text('今日步数')
        .fontSize(14)
        .fontColor('#D1D5DB')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(`${this.steps}`)
        .fontSize(44)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row() {
        Text(`目标 ${this.goal}`)
          .fontSize(14)
          .fontColor('#D1D5DB')
        Blank()
        Text(this.progress)
          .fontSize(14)
          .fontColor('#8BFCB5')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#111827')
  }
}
