import { SpeedRecord } from '../model/SpeedRecord'

@Component
export struct LineChartCanvas {
  @Prop @Watch('onRecordsChange') records: SpeedRecord[] = []
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  onRecordsChange(): void {
    this.drawChart()
  }

  private drawChart(): void {
    const w = this.ctx.width
    const h = this.ctx.height
    this.ctx.clearRect(0, 0, w, h)

    const recent = this.records.slice(0, 7).reverse()

    if (recent.length === 0) {
      this.ctx.fillStyle = '#9E9E9E'
      this.ctx.font = '16px sans-serif'
      this.ctx.textAlign = 'center'
      this.ctx.textBaseline = 'middle'
      this.ctx.fillText('暂无记录', w / 2, h / 2)
      return
    }

    const padLeft = 40
    const padRight = 16
    const padTop = 16
    const padBottom = 30
    const chartW = w - padLeft - padRight
    const chartH = h - padTop - padBottom

    // Find max
    let maxVal = 1
    for (const r of recent) {
      if (r.downloadSpeed > maxVal) { maxVal = r.downloadSpeed }
      if (r.uploadSpeed > maxVal) { maxVal = r.uploadSpeed }
    }
    maxVal = maxVal * 1.2

    // Draw axes
    this.ctx.strokeStyle = '#333344'
    this.ctx.lineWidth = 1
    this.ctx.beginPath()
    this.ctx.moveTo(padLeft, padTop)
    this.ctx.lineTo(padLeft, padTop + chartH)
    this.ctx.lineTo(padLeft + chartW, padTop + chartH)
    this.ctx.stroke()

    // Y-axis labels
    this.ctx.fillStyle = '#9E9E9E'
    this.ctx.font = '10px sans-serif'
    this.ctx.textAlign = 'right'
    this.ctx.textBaseline = 'middle'
    for (let i = 0; i <= 4; i++) {
      const val = (maxVal * i / 4)
      const y = padTop + chartH - chartH * i / 4
      this.ctx.fillText(val.toFixed(0), padLeft - 4, y)
    }

    const n = recent.length
    const xStep = n > 1 ? chartW / (n - 1) : chartW / 2

    // Draw download line (blue)
    this.ctx.beginPath()
    this.ctx.strokeStyle = '#2196F3'
    this.ctx.lineWidth = 2
    for (let i = 0; i < n; i++) {
      const x = padLeft + i * xStep
      const y = padTop + chartH - chartH * (recent[i].downloadSpeed / maxVal)
      if (i === 0) { this.ctx.moveTo(x, y) } else { this.ctx.lineTo(x, y) }
    }
    this.ctx.stroke()

    // Draw upload line (orange)
    this.ctx.beginPath()
    this.ctx.strokeStyle = '#FF9800'
    this.ctx.lineWidth = 2
    for (let i = 0; i < n; i++) {
      const x = padLeft + i * xStep
      const y = padTop + chartH - chartH * (recent[i].uploadSpeed / maxVal)
      if (i === 0) { this.ctx.moveTo(x, y) } else { this.ctx.lineTo(x, y) }
    }
    this.ctx.stroke()

    // Legend
    this.ctx.fillStyle = '#2196F3'
    this.ctx.fillRect(padLeft, h - padBottom + 6, 20, 4)
    this.ctx.fillStyle = '#9E9E9E'
    this.ctx.font = '10px sans-serif'
    this.ctx.textAlign = 'left'
    this.ctx.textBaseline = 'middle'
    this.ctx.fillText('↓下载', padLeft + 24, h - padBottom + 8)

    this.ctx.fillStyle = '#FF9800'
    this.ctx.fillRect(padLeft + 70, h - padBottom + 6, 20, 4)
    this.ctx.fillStyle = '#9E9E9E'
    this.ctx.fillText('↑上传', padLeft + 94, h - padBottom + 8)
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(160)
      .backgroundColor('#1E1E2E')
      .borderRadius(8)
      .onReady(() => {
        this.drawChart()
      })
      .onAreaChange((_oldVal: Area, _newVal: Area) => {
        this.drawChart()
      })
  }
}
