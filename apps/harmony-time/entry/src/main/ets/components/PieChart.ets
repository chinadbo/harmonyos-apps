import { ProjectDurationStat } from '../model/Stats'

@Component
export struct PieChart {
  @Prop @Watch('onDataChange') chartData: ProjectDurationStat[] = []
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private canvasWidth: number = 300
  private canvasHeight: number = 300

  onDataChange(): void {
    this.drawChart()
  }

  private drawChart(): void {
    const ctx = this.ctx
    const width = this.canvasWidth
    const height = this.canvasHeight
    const centerX = width / 2
    const centerY = height / 2
    const radius = Math.min(width, height) / 2 - 20

    // Clear canvas
    ctx.clearRect(0, 0, width, height)

    if (this.chartData.length === 0) {
      ctx.font = '14px sans-serif'
      ctx.fillStyle = '#999999'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('暂无数据', centerX, centerY)
      return
    }

    const total = this.chartData.reduce((sum, item) => sum + item.duration, 0)
    if (total === 0) {
      ctx.font = '14px sans-serif'
      ctx.fillStyle = '#999999'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('暂无数据', centerX, centerY)
      return
    }

    let startAngle = -Math.PI / 2

    for (let i = 0; i < this.chartData.length; i++) {
      const item = this.chartData[i]
      const sliceAngle = (item.duration / total) * 2 * Math.PI

      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle)
      ctx.closePath()
      ctx.fillStyle = item.color
      ctx.fill()

      startAngle += sliceAngle
    }

    // Draw center circle (donut style)
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius * 0.55, 0, 2 * Math.PI)
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()

    // Draw total time in center
    const totalHours = Math.floor(total / 3600)
    const totalMinutes = Math.floor((total % 3600) / 60)
    let totalStr = ''
    if (totalHours > 0) {
      totalStr = `${totalHours}h ${totalMinutes}m`
    } else {
      totalStr = `${totalMinutes}m`
    }

    ctx.font = 'bold 18px sans-serif'
    ctx.fillStyle = '#333333'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(totalStr, centerX, centerY - 10)

    ctx.font = '12px sans-serif'
    ctx.fillStyle = '#999999'
    ctx.fillText('总计', centerX, centerY + 12)
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
