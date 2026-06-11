import { DayStats } from '../model/WeekStats'

@Component
export struct WeeklyBarChart {
  @Prop items: DayStats[] = []
  private contextSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings)

  @Watch('redraw')
  @Prop chartSeed: number = 0

  redraw(): void {
    this.drawChart()
  }

  private drawChart(): void {
    const width = 320
    const height = 180
    const barWidth = 24
    const gap = 18
    const maxValue = Math.max(2000, ...this.items.map((item: DayStats) => item.goal > item.total ? item.goal : item.total))

    this.canvasContext.clearRect(0, 0, width, height)
    this.canvasContext.fillStyle = '#D9E7FF'
    this.canvasContext.font = '12px sans-serif'

    this.items.forEach((item: DayStats, index: number) => {
      const ratio = maxValue > 0 ? item.total / maxValue : 0
      const barHeight = ratio * 110
      const x = 22 + index * (barWidth + gap)
      const y = 130 - barHeight

      this.canvasContext.fillStyle = item.total >= item.goal ? '#0A7BFF' : '#89B9FF'
      this.canvasContext.fillRect(x, y, barWidth, barHeight)
      this.canvasContext.fillStyle = '#666666'
      this.canvasContext.fillText(item.date.slice(5), x - 4, 154)
    })
  }

  build() {
    Canvas(this.canvasContext)
      .width(320)
      .height(180)
      .onReady(() => {
        this.drawChart()
      })
  }
}
