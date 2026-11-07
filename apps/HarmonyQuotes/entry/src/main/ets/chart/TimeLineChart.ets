/**
 * 分时图：240 分钟价格折线 + 均价线 + 昨收基准线 + 渐变填充
 */

import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'

@Component
export struct TimeLineChart {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop @Watch('onDataChange') data: number[] = []
  @Prop @Watch('onDataChange') avgData: number[] = []
  @Prop @Watch('onDataChange') base: number = 0
  @Prop chartHeight: number = 260
  private canvasReady: boolean = false
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.canvasReady = true
        this.draw()
      })
      .onAreaChange(() => {
        this.draw()
      })
  }

  private onDataChange(): void {
    if (this.canvasReady) {
      this.draw()
    }
  }

  private draw(): void {
    const ctx = this.ctx
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    if (this.data.length < 2 || this.base <= 0) {
      ctx.fillStyle = Theme.TEXT3
      ctx.font = '14px sans-serif'
      ctx.fillText('暂无分时数据', w / 2 - 50, h / 2)
      return
    }

    const padL: number = 8
    const padR: number = 56
    const padT: number = 18
    const padB: number = 20
    const x0: number = padL
    const x1: number = w - padR
    const yTop: number = padT
    const yBottom: number = h - padB

    let min: number = Math.min(this.base, this.data[0])
    let max: number = Math.max(this.base, this.data[0])
    for (const v of this.data) {
      if (v < min) {
        min = v
      }
      if (v > max) {
        max = v
      }
    }
    const padRange: number = (max - min) * 0.08 + (max - min) * 0.01
    min -= padRange
    max += padRange
    if (max - min < 1e-6) {
      max = min + 1e-6
    }

    const slots: number = 240
    const xOf = (i: number): number => x0 + (i / slots) * (x1 - x0)
    const yOf = (v: number): number => yBottom - (v - min) / (max - min) * (yBottom - yTop)

    // 网格 + 右侧价格刻度
    ctx.strokeStyle = Theme.GRID
    ctx.lineWidth = 1
    ctx.font = '10px sans-serif'
    for (let k = 0; k <= 4; k++) {
      const y: number = yTop + (yBottom - yTop) * k / 4
      ctx.beginPath()
      ctx.moveTo(x0, y)
      ctx.lineTo(x1, y)
      ctx.stroke()
      const v: number = max - (max - min) * k / 4
      ctx.fillStyle = Theme.TEXT2
      ctx.fillText(v.toFixed(2), x1 + 4, y + 3)
    }
    // x 轴时间标签
    ctx.fillStyle = Theme.TEXT2
    const timeLabels: string[] = ['09:30', '10:30', '11:30', '14:00', '15:00']
    for (let k = 0; k < timeLabels.length; k++) {
      const x: number = x0 + (x1 - x0) * k / (timeLabels.length - 1)
      ctx.fillText(timeLabels[k], Math.min(x, x1 - 30), h - 6)
    }

    // 昨收基准线
    const baseY: number = yOf(this.base)
    ctx.strokeStyle = Theme.TEXT3
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(x0, baseY)
    ctx.lineTo(x1, baseY)
    ctx.stroke()
    ctx.fillStyle = Theme.TEXT2
    ctx.fillText('昨收 ' + this.base.toFixed(2), x0 + 4, Math.max(yTop + 8, baseY - 4))

    // 价格线主色：以最新价相对昨收的涨跌决定
    const last: number = this.data[this.data.length - 1]
    const up: boolean = last >= this.base
    const mainColor: string = up ? Theme.up(this.themeMode) : Theme.down(this.themeMode)

    // 渐变填充（价格线下方）
    const grad = ctx.createLinearGradient(0, yTop, 0, yBottom)
    grad.addColorStop(0, Fmt.rgba(mainColor, 0.22))
    grad.addColorStop(1, Fmt.rgba(mainColor, 0.02))
    ctx.fillStyle = grad
    ctx.beginPath()
    ctx.moveTo(xOf(0), yOf(this.data[0]))
    for (let i = 1; i < this.data.length; i++) {
      ctx.lineTo(xOf(i), yOf(this.data[i]))
    }
    ctx.lineTo(xOf(this.data.length - 1), yBottom)
    ctx.lineTo(xOf(0), yBottom)
    ctx.closePath()
    ctx.fill()

    // 均价线
    if (this.avgData.length > 1) {
      ctx.strokeStyle = Theme.MA5
      ctx.lineWidth = 1.2
      ctx.beginPath()
      ctx.moveTo(xOf(0), yOf(this.avgData[0]))
      for (let i = 1; i < this.avgData.length; i++) {
        ctx.lineTo(xOf(i), yOf(this.avgData[i]))
      }
      ctx.stroke()
    }

    // 价格线
    ctx.strokeStyle = mainColor
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(xOf(0), yOf(this.data[0]))
    for (let i = 1; i < this.data.length; i++) {
      ctx.lineTo(xOf(i), yOf(this.data[i]))
    }
    ctx.stroke()

    // 最新价标记点 + 右侧标签
    const lx: number = xOf(this.data.length - 1)
    const ly: number = yOf(last)
    ctx.fillStyle = mainColor
    ctx.beginPath()
    ctx.arc(lx, ly, 3, 0, Math.PI * 2)
    ctx.fill()
    const label: string = last.toFixed(2)
    ctx.font = '11px sans-serif'
    const labelW: number = label.length * 6.5 + 8
    ctx.fillRect(x1 + 2, ly - 8, labelW, 16)
    ctx.fillStyle = '#FFFFFF'
    ctx.fillText(label, x1 + 6, ly + 4)
  }
}
