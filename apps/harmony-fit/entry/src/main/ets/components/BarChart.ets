import { DailyStats } from '../model/WorkoutRecord'

@Component
export struct BarChart {
  @Prop data: DailyStats[]
  @Prop maxValue: number
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(260)
      .onReady(() => {
        this.drawChart()
      })
  }

  private drawChart(): void {
    const width = this.ctx.width > 0 ? this.ctx.width : 340
    const height = 260
    const left = 56
    const bottom = 210
    const chartHeight = 150
    const chartWidth = width - left - 20
    const barCount = this.data.length > 0 ? this.data.length : 7
    const barWidth = Math.floor(chartWidth / barCount * 0.6)
    const gap = Math.floor((chartWidth - barWidth * barCount) / Math.max(barCount - 1, 1))
    const today = this.formatDate(new Date())
    const maxValue = this.maxValue <= 0 ? 1 : this.maxValue

    this.ctx.clearRect(0, 0, width, height)

    // Y 轴网格线
    this.ctx.strokeStyle = '#E5EAF2'
    this.ctx.lineWidth = 1
    for (let i = 0; i <= 4; i++) {
      const y = bottom - chartHeight / 4 * i
      this.ctx.beginPath()
      this.ctx.moveTo(left, y)
      this.ctx.lineTo(left + chartWidth, y)
      this.ctx.stroke()

      this.ctx.fillStyle = '#8A94A6'
      this.ctx.font = '12px sans-serif'
      const labelValue = Math.floor(maxValue / 4 * i)
      this.ctx.fillText(`${labelValue}`, 4, y + 4)
    }

    // 柱状图
    for (let i = 0; i < this.data.length; i++) {
      const item = this.data[i]
      const x = left + i * (barWidth + gap)
      const ratio = item.totalSteps / maxValue
      const barHeight = Math.max(4, chartHeight * ratio)
      const y = bottom - barHeight
      const isToday = item.date === today

      this.ctx.fillStyle = isToday ? '#4F46E5' : '#9DB4FF'
      this.ctx.fillRect(x, y, barWidth, barHeight)

      // 步数标签
      if (item.totalSteps > 0) {
        this.ctx.fillStyle = '#1F2937'
        this.ctx.font = '11px sans-serif'
        this.ctx.fillText(`${item.totalSteps}`, x - 2, y - 6)
      }

      // 日期标签
      this.ctx.fillStyle = '#6B7280'
      this.ctx.font = '12px sans-serif'
      this.ctx.fillText(this.getWeekLabel(item.date), x + 2, bottom + 20)
    }
  }

  private getWeekLabel(dateText: string): string {
    const date = new Date(dateText)
    const labels = ['日', '一', '二', '三', '四', '五', '六']
    return `周${labels[date.getDay()]}`
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
