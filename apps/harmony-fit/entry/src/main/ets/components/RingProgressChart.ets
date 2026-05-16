@Component
export struct RingProgressChart {
  @Prop progress: number
  @Prop currentValue: number
  @Prop targetValue: number
  @Prop unit: string
  @Prop primaryColor: string
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width(260)
        .height(260)
        .onReady(() => {
          this.drawChart()
        })

      Column({ space: 6 }) {
        Text(`${this.currentValue}`)
          .fontSize(42)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(`${this.unit} / 目标 ${this.targetValue}`)
          .fontSize(14)
          .fontColor('#D3DAE6')
      }
    }
    .width('100%')
    .height(280)
  }

  private drawChart(): void {
    const centerX = 130
    const centerY = 130
    const radius = 92
    const lineWidth = 16
    const endAngle = -Math.PI / 2 + Math.PI * 2 * Math.min(1, Math.max(0, this.progress))

    this.context.clearRect(0, 0, 260, 260)
    this.context.lineWidth = lineWidth
    this.context.lineCap = 'round'

    // 背景圆弧
    this.context.beginPath()
    this.context.strokeStyle = '#2C3446'
    this.context.arc(centerX, centerY, radius, -Math.PI / 2, Math.PI * 1.5, false)
    this.context.stroke()

    // 进度圆弧
    if (this.progress > 0) {
      this.context.beginPath()
      this.context.strokeStyle = this.primaryColor
      this.context.arc(centerX, centerY, radius, -Math.PI / 2, endAngle, false)
      this.context.stroke()
    }
  }
}
