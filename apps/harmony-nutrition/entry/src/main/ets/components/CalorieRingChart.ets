@Component
export struct CalorieRingChart {
  @Prop progress: number = 0
  @Prop consumed: number = 0
  @Prop target: number = 1800

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({
        value: Math.min(100, this.progress * 100),
        total: 100,
        type: ProgressType.Ring
      })
        .width(180)
        .height(180)
        .color($r('app.color.primary'))
        .backgroundColor($r('app.color.primary_light'))
        .strokeWidth(16)

      Column({ space: 6 }) {
        Text(`${Math.round(this.consumed)}`)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(`/ ${Math.round(this.target)} kcal`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(this.progress >= 1 ? 'Goal reached' : `${Math.round((1 - this.progress) * this.target)} kcal left`)
          .fontSize(12)
          .fontColor(this.progress >= 1 ? $r('app.color.success') : $r('app.color.warning'))
      }
    }
  }
}
