/**
 * 统计页：总资产收益曲线（Canvas 折线）+ 持仓分布条形图 +
 * 当日涨跌家数统计 + 最佳/最差标的
 */

import { Quote, NavPoint, quoteChangePercent, quoteChange, emptyQuote } from '../model/Quote'
import { Position } from '../model/Position'
import { QuoteDB } from '../db/QuoteDB'
import { IMarketSource, getMarketSource } from '../market/MarketSource'
import { AppInit } from '../common/AppInit'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { BottomNav } from '../components/BottomNav'
import { DEMO_TOTAL_SYMBOL } from '../db/DemoData'
import { fmtDate } from '../market/CandleGenerator'

interface DistItem {
  label: string
  value: number
  ratio: number
  color: string
}

@Entry
@Component
struct StatsPage {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @State navPoints: NavPoint[] = []
  @State distItems: DistItem[] = []
  @State upCount: number = 0
  @State downCount: number = 0
  @State flatCount: number = 0
  @State bestQuote: Quote = emptyQuote()
  @State worstQuote: Quote = emptyQuote()
  @State totalValue: number = 0
  @State navPnl: number = 0
  @State loaded: boolean = false
  private source: IMarketSource = getMarketSource()

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    await AppInit.ready()
    const db: QuoteDB = QuoteDB.getInstance()

    // 自选（含指数）涨跌统计 + 最佳/最差
    const watchSymbols: string[] = []
    const wl = await db.getWatchlist()
    for (const w of wl) {
      watchSymbols.push(w.symbol)
    }
    const positions: Position[] = await db.getPositions()
    const posSymbols: string[] = positions.map((p: Position) => p.symbol)
    const allSymbols: string[] = watchSymbols.concat(posSymbols)
    const quotes: Quote[] = await this.source.getQuotes(allSymbols)

    let up: number = 0
    let down: number = 0
    let flat: number = 0
    let best: Quote = quotes.length > 0 ? quotes[0] : emptyQuote()
    let worst: Quote = quotes.length > 0 ? quotes[0] : emptyQuote()
    for (const q of quotes) {
      const chg: number = quoteChange(q)
      if (chg > 0) {
        up++
      } else if (chg < 0) {
        down++
      } else {
        flat++
      }
      if (quoteChangePercent(q) > quoteChangePercent(best)) {
        best = q
      }
      if (quoteChangePercent(q) < quoteChangePercent(worst)) {
        worst = q
      }
    }
    this.upCount = up
    this.downCount = down
    this.flatCount = flat
    this.bestQuote = best
    this.worstQuote = worst

    // 持仓市值与分布
    let total: number = 0
    const dist: DistItem[] = []
    for (const p of positions) {
      const q: Quote = this.quoteIn(quotes, p.symbol)
      const value: number = p.shares * q.price
      total += value
      dist.push({
        label: p.name,
        value: value,
        ratio: 0,
        color: Theme.changeColor(this.themeMode, q.price - p.cost)
      })
    }
    if (total > 0) {
      for (const d of dist) {
        d.ratio = d.value / total * 100
      }
    }
    this.totalValue = total
    this.distItems = dist

    // 净值曲线：不足 2 天补生成，含当日则更新当日值
    let nav: NavPoint[] = await db.getNavHistory(DEMO_TOTAL_SYMBOL, 30)
    if (nav.length < 2 && total > 0) {
      await this.rebuildNav(db, total)
      nav = await db.getNavHistory(DEMO_TOTAL_SYMBOL, 30)
    } else if (nav.length > 0 && total > 0) {
      const lastDate: string = nav[nav.length - 1].date
      if (lastDate !== Fmt.today()) {
        await db.addNav(DEMO_TOTAL_SYMBOL, Fmt.today(), Math.round(total * 100) / 100)
        nav = await db.getNavHistory(DEMO_TOTAL_SYMBOL, 30)
      }
    }
    this.navPoints = nav
    if (nav.length >= 2) {
      const start: number = nav[0].close > 0 ? nav[0].close : 1
      this.navPnl = (nav[nav.length - 1].close - start) / start * 100
    }
    this.loaded = true
  }

  private async rebuildNav(db: QuoteDB, total: number): Promise<void> {
    let a: number = Math.floor(Date.now() / 1000) % 2147483647
    const rand: () => number = (): number => {
      a = (a * 48271) % 2147483647
      return a / 2147483647
    }
    let v: number = total * 0.92
    const days: number = 30
    for (let i = days - 1; i >= 0; i--) {
      const ts: number = Date.now() - i * 86400000
      await db.addNav(DEMO_TOTAL_SYMBOL, fmtDate(ts), Math.round(v * 100) / 100)
      v = v * (1 + (rand() - 0.45) * 0.012)
    }
  }

  private quoteIn(quotes: Quote[], symbol: string): Quote {
    for (const q of quotes) {
      if (q.symbol === symbol) {
        return q
      }
    }
    return emptyQuote()
  }

  build() {
    Column() {
      Row() {
        Text('统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Blank()
        Text('刷新')
          .fontSize(13)
          .fontColor(Theme.ACCENT)
          .padding(6)
          .onClick(() => {
            this.loadData()
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })

      Scroll() {
        Column({ space: 10 }) {
          // 总资产收益曲线
          Column({ space: 8 }) {
            Row() {
              Column({ space: 2 }) {
                Text('总资产收益曲线（近30日）')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.TEXT)
                Text(`当前总市值 ${Fmt.money(this.totalValue)} 元`)
                  .fontSize(11)
                  .fontColor(Theme.TEXT2)
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text(Fmt.pct(this.navPnl))
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.changeColor(this.themeMode, this.navPnl))
            }
            .width('100%')
            NavCurve({ points: this.navPoints, chartHeight: 210 })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 当日涨跌家数
          Column({ space: 10 }) {
            Text('当日涨跌家数（自选+持仓）')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            Row({ space: 16 }) {
              this.countChip('上涨', this.upCount, Theme.up(this.themeMode))
              this.countChip('平盘', this.flatCount, Theme.FLAT)
              this.countChip('下跌', this.downCount, Theme.down(this.themeMode))
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            // 涨跌比例条
            Stack({ alignContent: Alignment.Start }) {
              Row() {
                Row()
                  .width(this.upCount + this.downCount + this.flatCount > 0
                    ? `${this.upCount / (this.upCount + this.downCount + this.flatCount) * 100}%`
                    : '0%')
                  .height(8)
                  .backgroundColor(Theme.up(this.themeMode))
                Row()
                  .layoutWeight(1)
                  .height(8)
                  .backgroundColor(Theme.down(this.themeMode))
              }
              .width('100%')
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 持仓分布
          Column({ space: 8 }) {
            Text('持仓分布')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            if (this.distItems.length === 0) {
              Text('暂无持仓数据')
                .fontSize(12)
                .fontColor(Theme.TEXT3)
                .padding({ top: 20, bottom: 20 })
            } else {
              DistBars({ items: this.distItems })
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 最佳/最差标的
          Column({ space: 10 }) {
            Text('今日最佳 / 最差')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            Row({ space: 10 }) {
              this.extremeCard('最佳', this.bestQuote, true)
              this.extremeCard('最差', this.worstQuote, false)
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          if (!this.loaded) {
            Text('加载中…')
              .fontSize(12)
              .fontColor(Theme.TEXT3)
              .padding({ bottom: 20 })
          }
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 4, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      BottomNav({ active: 2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  countChip(label: string, count: number, color: string) {
    Row({ space: 6 }) {
      Circle({ width: 8, height: 8 }).fill(color)
      Text(`${label} ${count}`)
        .fontSize(13)
        .fontColor(Theme.TEXT)
    }
  }

  @Builder
  extremeCard(label: string, q: Quote, isBest: boolean) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor(Theme.TEXT2)
      Text(q.name)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
        .maxLines(1)
      Text(Fmt.pct(quoteChangePercent(q)))
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(isBest ? Theme.up(this.themeMode) : Theme.down(this.themeMode))
      Text(`${q.symbol} · 现价 ${q.price.toFixed(2)}`)
        .fontSize(10)
        .fontColor(Theme.TEXT3)
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(Theme.BG)
    .borderRadius(10)
  }
}

/**
 * 总资产收益曲线：Canvas 折线 + 渐变填充 + 轴刻度
 */
@Component
struct NavCurve {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop points: NavPoint[] = []
  @Prop chartHeight: number = 210
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
  }

  private draw(): void {
    const ctx = this.ctx
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    if (this.points.length < 2) {
      ctx.fillStyle = Theme.TEXT3
      ctx.font = '13px sans-serif'
      ctx.fillText('暂无净值数据', w / 2 - 45, h / 2)
      return
    }
    const padL: number = 6
    const padR: number = 52
    const padT: number = 10
    const padB: number = 16
    const x0: number = padL
    const x1: number = w - padR
    const yTop: number = padT
    const yBottom: number = h - padB

    let min: number = this.points[0].close
    let max: number = this.points[0].close
    for (const p of this.points) {
      if (p.close < min) {
        min = p.close
      }
      if (p.close > max) {
        max = p.close
      }
    }
    const padRange: number = (max - min) * 0.08 || 1
    min -= padRange
    max += padRange
    const n: number = this.points.length
    const xOf = (i: number): number => x0 + (i / (n - 1)) * (x1 - x0)
    const yOf = (v: number): number => yBottom - (v - min) / (max - min) * (yBottom - yTop)

    // 网格 + 刻度
    ctx.strokeStyle = Theme.GRID
    ctx.lineWidth = 1
    ctx.font = '9px sans-serif'
    for (let k = 0; k <= 3; k++) {
      const y: number = yTop + (yBottom - yTop) * k / 3
      ctx.beginPath()
      ctx.moveTo(x0, y)
      ctx.lineTo(x1, y)
      ctx.stroke()
      const v: number = max - (max - min) * k / 3
      ctx.fillStyle = Theme.TEXT2
      ctx.fillText(Fmt.vol(v), x1 + 4, y + 3)
    }
    ctx.fillStyle = Theme.TEXT2
    ctx.fillText(this.points[0].date.substring(5), x0, h - 3)
    ctx.fillText(this.points[n - 1].date.substring(5), x1 - 34, h - 3)

    // 首末涨跌决定主色
    const rising: boolean = this.points[n - 1].close >= this.points[0].close
    const mainColor: string = rising ? Theme.up(this.themeMode) : Theme.down(this.themeMode)

    // 渐变填充
    const grad = ctx.createLinearGradient(0, yTop, 0, yBottom)
    grad.addColorStop(0, Fmt.rgba(mainColor, 0.20))
    grad.addColorStop(1, Fmt.rgba(mainColor, 0.02))
    ctx.fillStyle = grad
    ctx.beginPath()
    ctx.moveTo(xOf(0), yOf(this.points[0].close))
    for (let i = 1; i < n; i++) {
      ctx.lineTo(xOf(i), yOf(this.points[i].close))
    }
    ctx.lineTo(xOf(n - 1), yBottom)
    ctx.lineTo(xOf(0), yBottom)
    ctx.closePath()
    ctx.fill()

    // 折线
    ctx.strokeStyle = mainColor
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(xOf(0), yOf(this.points[0].close))
    for (let i = 1; i < n; i++) {
      ctx.lineTo(xOf(i), yOf(this.points[i].close))
    }
    ctx.stroke()

    // 端点
    ctx.fillStyle = mainColor
    ctx.beginPath()
    ctx.arc(xOf(n - 1), yOf(this.points[n - 1].close), 3, 0, Math.PI * 2)
    ctx.fill()
  }
}

/**
 * 持仓分布：水平条形图（每持仓一行：名称 + 市值 + 占比条）
 */
@Component
struct DistBars {
  @Prop items: DistItem[] = []
  @Prop barHeight: number = 260

  build() {
    Column({ space: 12 }) {
      ForEach(this.items, (d: DistItem, idx: number) => {
        Column({ space: 4 }) {
          Row() {
            Text(d.label)
              .fontSize(12)
              .fontColor(Theme.TEXT)
              .maxLines(1)
              .constraintSize({ maxWidth: '50%' })
            Blank()
            Text(`${Fmt.money(d.value)} 元 · ${d.ratio.toFixed(1)}%`)
              .fontSize(11)
              .fontColor(Theme.TEXT2)
          }
          .width('100%')

          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(10)
              .backgroundColor(Theme.BG)
              .borderRadius(5)
            Row()
              .width(`${Math.max(2, d.ratio)}%`)
              .height(10)
              .backgroundColor(d.color)
              .borderRadius(5)
          }
          .width('100%')
        }
        .width('100%')
      }, (d: DistItem) => d.label + d.ratio.toFixed(1))
    }
    .width('100%')
  }
}
