import type { WeightRecord } from '../model/WeightRecord'
import { DateUtils } from '../common/DateUtils'

@Component
export struct WeightChart {
  @Prop data: WeightRecord[] = []
  private canvasSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings)

  build() {
    Column() {
      if (this.data.length === 0) {
        Column({ space: 8 }) {
          Text('暂无记录')
            .fontSize(16)
            .fontColor('#888888')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(220)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      } else {
        Canvas(this.context2D)
          .width('100%')
          .height(220)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .onReady(() => {
            this.drawChart()
          })
      }
    }
  }

  private drawChart(): void {
    const width: number = 720
    const height: number = 440
    const left: number = 70
    const right: number = 30
    const top: number = 30
    const bottom: number = 60
    const ctx = this.context2D
    ctx.clearRect(0, 0, width, height)
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(0, 0, width, height)

    const sorted: WeightRecord[] = [...this.data].sort((a: WeightRecord, b: WeightRecord) => a.recordDate.localeCompare(b.recordDate))
    const weights: number[] = sorted.map((item: WeightRecord) => item.weight)
    const minWeight: number = Math.min(...weights) - 0.5
    const maxWeight: number = Math.max(...weights) + 0.5
    const chartWidth: number = width - left - right
    const chartHeight: number = height - top - bottom

    ctx.strokeStyle = '#EAEAEA'
    ctx.lineWidth = 1
    for (let index = 0; index <= 4; index++) {
      const y: number = top + chartHeight / 4 * index
      ctx.beginPath()
      ctx.moveTo(left, y)
      ctx.lineTo(width - right, y)
      ctx.stroke()
    }

    ctx.strokeStyle = '#CFCFCF'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(left, top)
    ctx.lineTo(left, height - bottom)
    ctx.lineTo(width - right, height - bottom)
    ctx.stroke()

    ctx.fillStyle = '#999999'
    ctx.font = '20px sans-serif'
    for (let index = 0; index <= 4; index++) {
      const value: number = maxWeight - ((maxWeight - minWeight) / 4) * index
      const y: number = top + chartHeight / 4 * index + 6
      ctx.fillText(value.toFixed(1), 10, y)
    }

    ctx.strokeStyle = '#FF8A00'
    ctx.lineWidth = 4
    ctx.beginPath()
    sorted.forEach((item: WeightRecord, index: number) => {
      const x: number = left + (sorted.length === 1 ? chartWidth / 2 : chartWidth / (sorted.length - 1) * index)
      const y: number = top + (maxWeight - item.weight) / (maxWeight - minWeight || 1) * chartHeight
      if (index === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    })
    ctx.stroke()

    sorted.forEach((item: WeightRecord, index: number) => {
      const x: number = left + (sorted.length === 1 ? chartWidth / 2 : chartWidth / (sorted.length - 1) * index)
      const y: number = top + (maxWeight - item.weight) / (maxWeight - minWeight || 1) * chartHeight
      ctx.fillStyle = '#FFFFFF'
      ctx.beginPath()
      ctx.arc(x, y, 8, 0, Math.PI * 2)
      ctx.fill()
      ctx.strokeStyle = '#FF8A00'
      ctx.lineWidth = 3
      ctx.stroke()
      ctx.fillStyle = '#666666'
      ctx.fillText(DateUtils.formatDisplayDate(item.recordDate), x - 24, height - 24)
    })
  }
}
