@Component
export struct TrendLineChart {
  @Prop values: number[] = []

  private maxValue(): number {
    let currentMax = 1
    this.values.forEach((value: number) => {
      if (value > currentMax) {
        currentMax = value
      }
    })
    return currentMax
  }

  build() {
    let max = this.maxValue()
    Column({ space: 12 }) {
      Text('7-day calorie trend')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 10 }) {
        ForEach(this.values, (value: number, index: number) => {
          Column({ space: 6 }) {
            Blank()
              .width(24)
              .height(`${Math.max(20, (value / max) * 140)}vp`)
              .borderRadius(12)
              .backgroundColor(index === this.values.length - 1 ? $r('app.color.primary') : '#664A8BFF')
            Text(`${index + 1}`)
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
          }
          .justifyContent(FlexAlign.End)
        })
      }
      .height(180)
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
    }
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
  }
}
