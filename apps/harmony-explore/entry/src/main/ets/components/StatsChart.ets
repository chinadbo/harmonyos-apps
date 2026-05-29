export interface StatisticsBarItem {
  label: string
  value: number
}

@Component
export struct StatsChart {
  @Watch('onBarsChanged') @Prop bars: StatisticsBarItem[] = []
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private isReady: boolean = false

  build() {
    Canvas(this.context2D)
      .width('100%')
      .height(220)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .onReady(() => {
        this.isReady = true
        this.drawChart()
      })
  }

  private onBarsChanged(): void {
    this.drawChart()
  }

  private drawChart(): void {
    if (!this.isReady) {
      return
    }
    this.context2D.clearRect(0, 0, 720, 440)
    this.context2D.fillStyle = '#FFFFFF'
    this.context2D.fillRect(0, 0, 720, 440)
    const maxValue: number = Math.max(1, ...this.bars.map((item: StatisticsBarItem) => item.value))
    const barWidth: number = 56
    const gap: number = 28
    const startX: number = 40
    const chartBottom: number = 320
    const chartHeight: number = 200
    this.context2D.strokeStyle = '#E6E8EB'
    this.context2D.lineWidth = 2
    this.context2D.beginPath()
    this.context2D.moveTo(24, chartBottom)
    this.context2D.lineTo(680, chartBottom)
    this.context2D.stroke()
    this.bars.forEach((item: StatisticsBarItem, index: number) => {
      const height: number = item.value / maxValue * chartHeight
      const x: number = startX + index * (barWidth + gap)
      const y: number = chartBottom - height
      this.context2D.fillStyle = '#6AA9FF'
      this.context2D.fillRect(x, y, barWidth, height)
      this.context2D.fillStyle = '#182431'
      this.context2D.font = '20px sans-serif'
      this.context2D.fillText(`${item.value}`, x + 12, y - 8)
      this.context2D.fillStyle = '#8A8A8A'
      this.context2D.fillText(item.label, x, chartBottom + 28)
    })
  }
}
