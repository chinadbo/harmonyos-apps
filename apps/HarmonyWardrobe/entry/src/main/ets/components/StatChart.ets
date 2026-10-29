import { ChartItem } from '../model/WardrobeModels'

@Component
export struct StatChart {
  @Prop @Watch('onDataChanged') chartType: string
  @Prop @Watch('onDataChanged') items: ChartItem[]
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context2d: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onDataChanged(): void {
    if (this.ready) {
      this.draw()
    }
  }

  private total(): number {
    let sum: number = 0
    this.items.forEach((item: ChartItem) => {
      sum += item.value
    })
    return sum
  }

  private maxValue(): number {
    let max: number = 0
    this.items.forEach((item: ChartItem) => {
      if (item.value > max) {
        max = item.value
      }
    })
    return max
  }

  private draw(): void {
    const ctx = this.context2d
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    if (this.chartType === 'pie') {
      this.drawPie(ctx, w, h)
    } else {
      this.drawBar(ctx, w, h)
    }
  }

  private drawPie(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    const total: number = this.total()
    if (total <= 0) {
      return
    }
    const cx: number = w / 2
    const cy: number = h / 2
    const r: number = Math.min(w, h) / 2 - vp2px(10)
    let start: number = -Math.PI / 2
    this.items.forEach((item: ChartItem) => {
      const angle: number = item.value / total * Math.PI * 2
      ctx.beginPath()
      ctx.moveTo(cx, cy)
      ctx.arc(cx, cy, r, start, start + angle)
      ctx.closePath()
      ctx.fillStyle = item.color
      ctx.fill()
      start += angle
    })
    ctx.beginPath()
    ctx.arc(cx, cy, r * 0.55, 0, Math.PI * 2)
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.font = `${vp2px(18)}px sans-serif`
    ctx.fillStyle = '#2B3A4A'
    ctx.fillText(total.toString(), cx, cy)
  }

  private drawBar(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    const n: number = this.items.length
    if (n === 0) {
      return
    }
    const maxV: number = this.maxValue()
    const padding: number = vp2px(8)
    const bottomH: number = vp2px(20)
    const topH: number = vp2px(14)
    const chartH: number = h - bottomH - topH
    const slotW: number = (w - padding * 2) / n
    const barW: number = slotW * 0.5
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    for (let i = 0; i < n; i++) {
      const item: ChartItem = this.items[i]
      const barH: number = maxV > 0 ? item.value / maxV * chartH : 0
      const x: number = padding + slotW * i + (slotW - barW) / 2
      const y: number = h - bottomH - barH
      ctx.fillStyle = item.color
      ctx.fillRect(x, y, barW, barH)
      ctx.font = `${vp2px(11)}px sans-serif`
      ctx.fillStyle = '#2B3A4A'
      ctx.fillText(item.value.toString(), x + barW / 2, y - vp2px(8))
      ctx.fillStyle = '#8A97A5'
      const label: string = item.label.length > 4 ? item.label.substring(0, 4) : item.label
      ctx.fillText(label, x + barW / 2, h - vp2px(10))
    }
  }

  build() {
    Column() {
      Canvas(this.context2d)
        .width('100%')
        .height(220)
        .onReady(() => {
          this.ready = true
          this.draw()
        })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
        ForEach(this.items, (item: ChartItem, index: number) => {
          Row({ space: 6 }) {
            Circle()
              .width(10)
              .height(10)
              .fill(item.color)
            Text(`${item.label} ${item.value}`)
              .fontSize(12)
              .fontColor('#6B7684')
          }
          .margin(6)
        }, (item: ChartItem, index: number) => `${index}_${item.label}_${item.value}`)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }
}
