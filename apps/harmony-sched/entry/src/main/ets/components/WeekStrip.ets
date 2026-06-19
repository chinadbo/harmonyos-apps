@Component
export struct WeekStrip {
  @Link currentWeek: number;
  @Prop maxWeeks: number;

  build() {
    Row({ space: 8 }) {
      Button('-')
        .width(36)
        .height(36)
        .onClick(() => {
          if (this.currentWeek > 1) {
            this.currentWeek -= 1;
          }
        })
      Text(`第 ${this.currentWeek} 周`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Button('+')
        .width(36)
        .height(36)
        .onClick(() => {
          if (this.currentWeek < this.maxWeeks) {
            this.currentWeek += 1;
          }
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(18)
  }
}
