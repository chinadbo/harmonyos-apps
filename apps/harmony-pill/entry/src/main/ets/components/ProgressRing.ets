@Component
export struct ProgressRing {
  @Prop progress: number = 0
  @Prop size: number = 80
  @Prop strokeWidth: number = 8
  @Prop trackColor: ResourceColor = '#E8E8E8'
  @Prop progressColor: ResourceColor = '#4CAF50'

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Shape() {
        Arc()
          .width(this.size)
          .height(this.size)
          .startAngle(0)
          .endAngle(360)
          .stroke(this.trackColor)
          .strokeWidth(this.strokeWidth)
          .fill(Color.Transparent)
      }

      Shape() {
        Arc()
          .width(this.size)
          .height(this.size)
          .startAngle(-90)
          .endAngle(-90 + this.progress * 360 / 100)
          .stroke(this.progressColor)
          .strokeWidth(this.strokeWidth)
          .fill(Color.Transparent)
          .strokeLineCap(LineCapStyle.Round)
      }

      Column() {
        Text(`${this.progress}%`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
    }
    .width(this.size)
    .height(this.size)
  }
}
