import { DailyDurationStat } from '../model/Stats'

@Component
export struct BarChart {
  @Prop @Watch('onDataChange') barData: DailyDurationStat[] = []
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private canvasWidth: number = 350
  private canvasHeight: number = 200

  onDataChange(): void {
    this.drawChart()
  }

  private drawChart(): void {
    const ctx = this.ctx
    const width = this.canvasWidth
    const height = this.canvasHeight
    const paddingLeft = 50
    const paddingRight = 20
    const paddingTop = 20
    const paddingBottom = 40

    // Clear canvas
    ctx.clearRect(0, 0, width, height)

    if (this.barData.length === 0) {
      ctx.font = '14px sans-serif'
      ctx.fillStyle = '#999999'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('暂无数据', width / 2, height / 2)
      return
    }

    const chartWidth = width - paddingLeft - paddingRight
    const chartHeight = height - paddingTop - paddingBottom
    const maxDuration = Math.max(...this.barData.map(d => d.duration), 1)
    const barCount = this.barData.length
    const barWidth = Math.min(chartWidth / barCount * 0.6, 40)
    const gap = (chartWidth - barWidth * barCount) / (barCount + 1)

    // Draw Y axis
    ctx.beginPath()
    ctx.moveTo(paddingLeft, paddingTop)
    ctx.lineTo(paddingLeft, height - paddingBottom)
    ctx.strokeStyle = '#E0E0E0'
    ctx.lineWidth = 1
    ctx.stroke()

    // Draw X axis
    ctx.beginPath()
    ctx.moveTo(paddingLeft, height - paddingBottom)
    ctx.lineTo(width - paddingRight, height - paddingBottom)
    ctx.stroke()

    // Draw Y axis labels
    const ySteps = 4
    ctx.font = '11px sans-serif'
    ctx.fillStyle = '#999999'
    ctx.textAlign = 'right'
    ctx.textBaseline = 'middle'
    for (let i = 0; i <= ySteps; i++) {
      const yVal = (maxDuration / ySteps) * i
      const yPos = height - paddingBottom - (chartHeight / ySteps) * i
      const label = this.formatDurationShort(Math.round(yVal))
      ctx.fillText(label, paddingLeft - 8, yPos)

      // Grid line
      if (i > 0) {
        ctx.beginPath()
        ctx.moveTo(paddingLeft, yPos)
        ctx.lineTo(width - paddingRight, yPos)
        ctx.strokeStyle = '#F0F0F0'
        ctx.lineWidth = 0.5
        ctx.stroke()
      }
    }

    // Draw bars
    for (let i = 0; i < barCount; i++) {
      const item = this.barData[i]
      const x = paddingLeft + gap + (barWidth + gap) * i
      const barHeight = (item.duration / maxDuration) * chartHeight
      const y = height - paddingBottom - barHeight

      // Bar
      ctx.fillStyle = '#4FC3F7'
      ctx.beginPath()
      ctx.roundRect(x, y, barWidth, barHeight, [4, 4, 0, 0])
      ctx.fill()

      // X axis label
      ctx.font = '11px sans-serif'
      ctx.fillStyle = '#666666'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'top'
      ctx.fillText(item.dayLabel, x + barWidth / 2, height - paddingBottom + 8)
    }
  }

  private formatDurationShort(seconds: number): string {
    if (seconds < 60) {
      return `${seconds}s`
    }
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (h > 0) {
      return `${h}h`
    }
    return `${m}m`
  }

  build() {
    Column() {
      Canvas(this.ctx)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .onReady(() => {
          this.drawChart()
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
