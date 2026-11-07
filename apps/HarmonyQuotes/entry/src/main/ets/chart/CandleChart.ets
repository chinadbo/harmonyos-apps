/**
 * K 线图：蜡烛 + MA5/MA10 + 成交量副图
 * 手势：PinchGesture 缩放可见根数 / PanGesture 平移 / 点击定位十字光标
 */

import { Candle } from '../model/Quote'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'

const MIN_VISIBLE: number = 20

@Component
export struct CandleChart {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop @Watch('onCandlesChange') candles: Candle[] = []
  @State visible: number = 60
  @State crossIndex: number = -1
  @Prop chartHeight: number = 430
  private offsetFromEnd: number = 0
  private pinchStart: number = 60
  private panStartOffset: number = 0
  private lastStart: number = 0
  private lastColW: number = 1
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.draw()
      })
      .onAreaChange(() => {
        this.draw()
      })
      .onClick((event: ClickEvent) => {
        this.crossIndex = this.hitTest(event.x)
        this.draw()
      })
      .gesture(
        GestureGroup(GestureMode.Parallel,
          PinchGesture({ fingers: 2 })
            .onActionStart(() => {
              this.pinchStart = this.visible
            })
            .onActionUpdate((e: GestureEvent) => {
              if (e.scale > 0.15 && this.candles.length > 0) {
                let v: number = Math.round(this.pinchStart / e.scale)
                v = Math.max(MIN_VISIBLE, Math.min(this.candles.length, v))
                if (v !== this.visible) {
                  this.visible = v
                  this.clampOffset()
                  this.draw()
                }
              }
            }),
          PanGesture({ fingers: 1, direction: PanDirection.Horizontal })
            .onActionStart(() => {
              this.panStartOffset = this.offsetFromEnd
            })
            .onActionUpdate((e: GestureEvent) => {
              if (this.candles.length > 0) {
                const cw: number = this.cw()
                if (cw > 0) {
                  let off: number = this.panStartOffset + Math.round(e.offsetX / cw)
                  off = Math.max(0, Math.min(this.candles.length - this.visible, off))
                  if (off !== this.offsetFromEnd) {
                    this.offsetFromEnd = off
                    this.draw()
                  }
                }
              }
            })
        )
      )
  }

  private onCandlesChange(): void {
    this.crossIndex = -1
    this.offsetFromEnd = 0
    this.draw()
  }

  private cw(): number {
    const w: number = this.ctx.width
    if (w <= 0 || this.visible <= 0) {
      return 1
    }
    return (w - 8 - 54) / this.visible
  }

  private hitTest(x: number): number {
    if (this.candles.length === 0) {
      return -1
    }
    const rel: number = Math.floor((x - 8) / this.lastColW)
    const idx: number = this.lastStart + rel
    if (idx < this.lastStart || idx >= this.lastStart + this.visible || idx >= this.candles.length) {
      return -1
    }
    return idx
  }

  private clampOffset(): void {
    const maxOff: number = Math.max(0, this.candles.length - this.visible)
    if (this.offsetFromEnd > maxOff) {
      this.offsetFromEnd = maxOff
    }
    if (this.offsetFromEnd < 0) {
      this.offsetFromEnd = 0
    }
  }

  private calcMA(n: number): number[] {
    const result: number[] = []
    for (let i = 0; i < this.candles.length; i++) {
      if (i < n - 1) {
        result.push(-1)
      } else {
        let sum: number = 0
        for (let j = i - n + 1; j <= i; j++) {
          sum += this.candles[j].close
        }
        result.push(sum / n)
      }
    }
    return result
  }

  private draw(): void {
    const ctx = this.ctx
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    const data: Candle[] = this.candles
    if (data.length < 2) {
      ctx.fillStyle = Theme.TEXT3
      ctx.font = '14px sans-serif'
      ctx.fillText('暂无K线数据', w / 2 - 50, h / 2)
      return
    }

    const total: number = data.length
    const visible: number = Math.max(MIN_VISIBLE, Math.min(total, this.visible))
    this.visible = visible
    this.clampOffset()
    let start: number = total - visible - this.offsetFromEnd
    if (start < 0) {
      start = 0
    }
    if (start + visible > total) {
      start = total - visible
    }
    const end: number = start + visible

    const ma5: number[] = this.calcMA(5)
    const ma10: number[] = this.calcMA(10)

    // 可见范围价格/成交量极值
    let min: number = Number.POSITIVE_INFINITY
    let max: number = Number.NEGATIVE_INFINITY
    let volMax: number = 0
    for (let i = start; i < end; i++) {
      if (data[i].low < min) {
        min = data[i].low
      }
      if (data[i].high > max) {
        max = data[i].high
      }
      if (ma5[i] > 0 && ma5[i] < min) {
        min = ma5[i]
      }
      if (ma5[i] > 0 && ma5[i] > max) {
        max = ma5[i]
      }
      if (ma10[i] > 0 && ma10[i] < min) {
        min = ma10[i]
      }
      if (ma10[i] > 0 && ma10[i] > max) {
        max = ma10[i]
      }
      if (data[i].volume > volMax) {
        volMax = data[i].volume
      }
    }
    const padRange: number = (max - min) * 0.06
    min -= padRange
    max += padRange

    const padL: number = 8
    const padR: number = 54
    const x0: number = padL
    const x1: number = w - padR
    const priceTop: number = 24
    const priceBottom: number = h * 0.70
    const volTop: number = h * 0.76
    const volBottom: number = h - 22
    const cw: number = (x1 - x0) / visible
    this.lastStart = start
    this.lastColW = cw

    const xOf = (i: number): number => x0 + (i - start) * cw + cw / 2
    const yP = (v: number): number => priceBottom - (v - min) / (max - min) * (priceBottom - priceTop)
    const yV = (v: number): number => volMax > 0 ? volBottom - v / volMax * (volBottom - volTop) : volBottom

    // 网格 + 价格刻度
    ctx.strokeStyle = Theme.GRID
    ctx.lineWidth = 1
    ctx.font = '10px sans-serif'
    for (let k = 0; k <= 4; k++) {
      const y: number = priceTop + (priceBottom - priceTop) * k / 4
      ctx.beginPath()
      ctx.moveTo(x0, y)
      ctx.lineTo(x1, y)
      ctx.stroke()
      const v: number = max - (max - min) * k / 4
      ctx.fillStyle = Theme.TEXT2
      ctx.fillText(v.toFixed(2), x1 + 4, y + 3)
    }

    // 蜡烛 + 影线 + 成交量
    const upColor: string = Theme.up(this.themeMode)
    const downColor: string = Theme.down(this.themeMode)
    const bodyW: number = Math.max(1.5, cw * 0.64)
    for (let i = start; i < end; i++) {
      const c: Candle = data[i]
      const x: number = xOf(i)
      const up: boolean = c.close >= c.open
      const color: string = up ? upColor : downColor
      // 影线
      ctx.strokeStyle = color
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(x, yP(c.high))
      ctx.lineTo(x, yP(c.low))
      ctx.stroke()
      // 实体
      const bodyTop: number = yP(Math.max(c.open, c.close))
      const bodyBottom: number = yP(Math.min(c.open, c.close))
      ctx.fillStyle = color
      ctx.fillRect(x - bodyW / 2, bodyTop, bodyW, Math.max(1, bodyBottom - bodyTop))
      // 成交量
      ctx.fillStyle = up ? Theme.TEXT3 : Theme.TEXT3
      const vTop: number = yV(c.volume)
      ctx.globalAlpha = 0.6
      ctx.fillRect(x - bodyW / 2, vTop, bodyW, Math.max(1, volBottom - vTop))
      ctx.globalAlpha = 1
    }

    // MA 均线
    this.strokeMA(ctx, ma5, start, end, xOf, yP, Theme.MA5)
    this.strokeMA(ctx, ma10, start, end, xOf, yP, Theme.MA10)

    // MA 图例
    ctx.font = '10px sans-serif'
    const ma5v: number = ma5[end - 1]
    const ma10v: number = ma10[end - 1]
    ctx.fillStyle = Theme.MA5
    ctx.fillText(`MA5:${ma5v > 0 ? ma5v.toFixed(2) : '--'}`, x0 + 2, 12)
    ctx.fillStyle = Theme.MA10
    ctx.fillText(`MA10:${ma10v > 0 ? ma10v.toFixed(2) : '--'}`, x0 + 72, 12)
    ctx.fillStyle = Theme.TEXT2
    ctx.fillText('成交量', x0 + 2, volTop - 4)

    // x 轴日期标签
    const step: number = Math.max(1, Math.ceil(visible / 5))
    ctx.fillStyle = Theme.TEXT2
    for (let i = start; i < end; i += step) {
      const x: number = xOf(i)
      if (x < x1 - 50) {
        ctx.fillText(data[i].date.substring(5), x - 15, h - 6)
      }
    }

    // 十字光标
    if (this.crossIndex >= start && this.crossIndex < end) {
      const ci: number = this.crossIndex
      const c: Candle = data[ci]
      const cx: number = xOf(ci)
      const cy: number = yP(c.close)
      ctx.strokeStyle = 'rgba(60,64,70,0.55)'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(cx, priceTop)
      ctx.lineTo(cx, volBottom)
      ctx.stroke()
      ctx.beginPath()
      ctx.moveTo(x0, cy)
      ctx.lineTo(x1, cy)
      ctx.stroke()
      // 价格标签（右侧）
      const pLabel: string = c.close.toFixed(2)
      ctx.fillStyle = Theme.TEXT
      ctx.fillRect(x1 + 2, cy - 8, 50, 16)
      ctx.fillStyle = '#FFFFFF'
      ctx.fillText(pLabel, x1 + 6, cy + 4)
      // 日期标签（底部）
      const dLabel: string = c.date
      const dw: number = dLabel.length * 6.5 + 8
      ctx.fillStyle = Theme.TEXT
      ctx.fillRect(Math.min(Math.max(cx - dw / 2, x0), x1 - dw), h - 18, dw, 14)
      ctx.fillStyle = '#FFFFFF'
      ctx.fillText(dLabel, Math.min(Math.max(cx - dw / 2 + 4, x0 + 4), x1 - dw + 4), h - 8)
      // 信息浮层：开/高/低/收/量
      ctx.fillStyle = 'rgba(255,255,255,0.94)'
      ctx.fillRect(x0 + 4, priceTop + 4, 150, 40)
      ctx.strokeStyle = Theme.GRID
      ctx.strokeRect(x0 + 4, priceTop + 4, 150, 40)
      ctx.fillStyle = c.close >= c.open ? upColor : downColor
      ctx.font = '10px sans-serif'
      ctx.fillText(`开:${c.open.toFixed(2)}  高:${c.high.toFixed(2)}`, x0 + 10, priceTop + 19)
      ctx.fillText(`低:${c.low.toFixed(2)}  收:${c.close.toFixed(2)}  量:${Fmt.vol(c.volume)}`, x0 + 10, priceTop + 37)
    }
  }

  private strokeMA(ctx: CanvasRenderingContext2D, ma: number[], start: number, end: number,
    xOf: (i: number) => number, yP: (v: number) => number, color: string): void {
    ctx.strokeStyle = color
    ctx.lineWidth = 1.4
    ctx.beginPath()
    let drawing: boolean = false
    for (let i = start; i < end; i++) {
      if (ma[i] > 0) {
        const x: number = xOf(i)
        const y: number = yP(ma[i])
        if (!drawing) {
          ctx.moveTo(x, y)
          drawing = true
        } else {
          ctx.lineTo(x, y)
        }
      } else {
        drawing = false
      }
    }
    ctx.stroke()
  }
}
