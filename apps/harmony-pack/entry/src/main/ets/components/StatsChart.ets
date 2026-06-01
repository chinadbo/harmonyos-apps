@Component
export struct StatsChart {
  @Prop values: number[] = []
  @Prop labels: string[] = []

  private chartContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  private drawChart(): void {
    this.chartContext.clearRect(0, 0, 640, 320)
    this.chartContext.strokeStyle = '#E5E7EB'
    this.chartContext.lineWidth = 1

    for (let index = 0; index < 4; index += 1) {
      const y = 40 + index * 70
      this.chartContext.beginPath()
      this.chartContext.moveTo(40, y)
      this.chartContext.lineTo(600, y)
      this.chartContext.stroke()
    }

    if (this.values.length === 0) {
      return
    }

    const points = this.values.map((value: number, index: number) => {
      const safeValue = Math.max(0, Math.min(100, value))
      const stepX = this.values.length === 1 ? 0 : 520 / (this.values.length - 1)
      return {
        x: 60 + index * stepX,
        y: 260 - safeValue * 2
      }
    })

    this.chartContext.strokeStyle = '#2563EB'
    this.chartContext.lineWidth = 3
    this.chartContext.beginPath()
    points.forEach((point: { x: number; y: number }, index: number) => {
      if (index === 0) {
        this.chartContext.moveTo(point.x, point.y)
      } else {
        this.chartContext.lineTo(point.x, point.y)
      }
    })
    this.chartContext.stroke()

    this.chartContext.fillStyle = '#2563EB'
    points.forEach((point: { x: number; y: number }) => {
      this.chartContext.beginPath()
      this.chartContext.arc(point.x, point.y, 5, 0, Math.PI * 2)
      this.chartContext.fill()
    })
  }

  build() {
    Column({ space: 10 }) {
      Canvas(this.chartContext)
        .width('100%')
        .height(220)
        .onReady(() => {
          this.drawChart()
        })

      Row() {
        ForEach(this.labels, (label: string) => {
          Text(label)
            .fontSize(11)
            .fontColor('#64748B')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (label: string) => label)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
