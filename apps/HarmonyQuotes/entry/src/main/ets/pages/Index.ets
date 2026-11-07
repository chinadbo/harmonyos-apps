/**
 * 首页：总资产卡片（总市值/总盈亏/当日盈亏）+ 顶部指数概览条 + 自选列表
 * 支持下拉刷新与长按删除；5 秒定时刷新行情，onPageHide 清理
 */

import router from '@ohos.router'
import { Quote, emptyQuote } from '../model/Quote'
import { Position, posDayPnl } from '../model/Position'
import { WatchItem } from '../model/WatchItem'
import { QuoteDB } from '../db/QuoteDB'
import { MarketEngine } from '../market/MarketEngine'
import { IMarketSource, getMarketSource } from '../market/MarketSource'
import { AppInit } from '../common/AppInit'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { QuoteCard } from '../components/QuoteCard'
import { IndexBar } from '../components/IndexBar'
import { BottomNav } from '../components/BottomNav'
import { NumberRoll } from '../components/NumberRoll'

const INDEX_SYMBOLS: string[] = ['IDX000001', 'IDX399001', 'IDX399006']
const REFRESH_MS: number = 5000

@Entry
@Component
struct Index {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @State quotes: Quote[] = []
  @State indexQuotes: Quote[] = []
  @State positions: Position[] = []
  @State posQuotes: Quote[] = []
  @State refreshing: boolean = false
  @State loaded: boolean = false
  private watchSymbols: string[] = []
  private posSymbols: string[] = []
  private source: IMarketSource = getMarketSource()
  private timer: number = -1
  private pageShown: boolean = false

  aboutToAppear(): void {
    this.loadData()
    this.startTimer()
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  onPageShow(): void {
    // 首次 onPageShow 紧跟 aboutToAppear，跳过避免重复 loadData
    if (this.pageShown) {
      this.loadData()
    }
    this.pageShown = true
    this.startTimer()
  }

  onPageHide(): void {
    this.stopTimer()
  }

  private startTimer(): void {
    if (this.timer < 0) {
      this.timer = setInterval(() => {
        this.refreshQuotes(false)
      }, REFRESH_MS)
    }
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  private async loadData(): Promise<void> {
    await AppInit.ready()
    const db: QuoteDB = QuoteDB.getInstance()
    const watchlist: WatchItem[] = await db.getWatchlist()
    this.watchSymbols = watchlist
      .filter((w: WatchItem) => w.type !== 'index')
      .map((w: WatchItem) => w.symbol)
    this.positions = await db.getPositions()
    this.posSymbols = this.positions.map((p: Position) => p.symbol)
    this.loaded = true
    await this.refreshQuotes(false)
  }

  private async refreshQuotes(pull: boolean): Promise<void> {
    const all: string[] = []
    for (const s of this.watchSymbols) {
      all.push(s)
    }
    for (const s of INDEX_SYMBOLS) {
      all.push(s)
    }
    for (const s of this.posSymbols) {
      all.push(s)
    }
    const qs: Quote[] = await this.source.getQuotes(all)
    this.quotes = qs.filter((q: Quote) => this.watchSymbols.indexOf(q.symbol) >= 0)
    this.indexQuotes = qs.filter((q: Quote) => INDEX_SYMBOLS.indexOf(q.symbol) >= 0)
    this.posQuotes = qs.filter((q: Quote) => this.posSymbols.indexOf(q.symbol) >= 0)
    if (pull) {
      this.refreshing = false
    }
  }

  private quoteOf(symbol: string): Quote {
    for (const q of this.posQuotes) {
      if (q.symbol === symbol) {
        return q
      }
    }
    return emptyQuote()
  }

  private get totalValue(): number {
    let sum: number = 0
    for (const p of this.positions) {
      const q: Quote = this.quoteOf(p.symbol)
      sum += p.shares * q.price
    }
    return sum
  }

  private get totalCost(): number {
    let sum: number = 0
    for (const p of this.positions) {
      sum += p.shares * p.cost
    }
    return sum
  }

  private get totalPnl(): number {
    return this.totalValue - this.totalCost
  }

  private get dayPnl(): number {
    let sum: number = 0
    for (const p of this.positions) {
      const q: Quote = this.quoteOf(p.symbol)
      sum += posDayPnl(p, q.price, q.prevClose)
    }
    return sum
  }

  private confirmDelete(symbol: string, name: string): void {
    AlertDialog.show({
      title: '移除自选',
      message: `确定将「${name}」从自选中移除吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '移除',
        fontColor: Theme.UP_RED,
        action: () => {
          this.doDelete(symbol)
        }
      }
    })
  }

  private async doDelete(symbol: string): Promise<void> {
    await QuoteDB.getInstance().removeWatch(symbol)
    this.watchSymbols = this.watchSymbols.filter((s: string) => s !== symbol)
    await this.refreshQuotes(false)
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('HarmonyQuotes')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Blank()
        Text('设置')
          .fontSize(13)
          .fontColor(Theme.TEXT2)
          .padding(6)
          .onClick(() => {
            router.pushUrl({ url: 'pages/SettingsPage' })
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })

      Column() {
        // 总资产卡片
        Column({ space: 8 }) {
          Row() {
            Text('总资产 (元)')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.85)
            Blank()
            Text(`持仓 ${this.positions.length} 只`)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.85)
          }
          .width('100%')

          NumberRoll({
            value: this.totalValue,
            color: '#FFFFFF',
            fontSize: 30
          })
          .alignSelf(ItemAlign.Start)

          Row({ space: 24 }) {
            Column({ space: 2 }) {
              Text('总盈亏')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .opacity(0.85)
              Text(Fmt.pnl(this.totalPnl))
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .alignItems(HorizontalAlign.Start)

            Column({ space: 2 }) {
              Text('当日盈亏')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .opacity(0.85)
              Text(Fmt.pnl(this.dayPnl))
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Text('管理持仓 ›')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .onClick(() => {
                router.pushUrl({ url: 'pages/PositionsPage' })
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .borderRadius(14)
        .linearGradient({
          angle: 135,
          colors: this.totalPnl >= 0
            ? [['#C0392B', 0], [Theme.up(this.themeMode), 1]]
            : [['#1E8449', 0], [Theme.down(this.themeMode), 1]]
        })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.10)' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/PositionsPage' })
        })

        // 指数概览条
        IndexBar({ quotes: this.indexQuotes })
          .margin({ top: 10, bottom: 10 })

        // 自选区标题
        Row() {
          Text(`自选 · ${this.quotes.length}`)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.TEXT)
          Blank()
          Text('+ 添加自选')
            .fontSize(13)
            .fontColor(Theme.ACCENT)
            .padding(4)
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddQuotePage' })
            })
        }
        .width('100%')
        .padding({ left: 4, right: 4, bottom: 8 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 4 })

      // 自选列表（下拉刷新 + 长按删除）
      if (this.loaded && this.quotes.length === 0) {
        Column({ space: 8 }) {
          Text('暂无自选')
            .fontSize(15)
            .fontColor(Theme.TEXT2)
          Text('点击上方「+ 添加自选」浏览内置标的池')
            .fontSize(12)
            .fontColor(Theme.TEXT3)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: $$this.refreshing, offset: 64, friction: 42 }) {
          List({ space: 8 }) {
            ForEach(this.quotes, (q: Quote) => {
              ListItem() {
                QuoteCard({ quote: q })
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/QuoteDetail', params: { symbol: q.symbol } })
              })
              .gesture(
                LongPressGesture({ repeat: false, duration: 500 })
                  .onAction(() => {
                    this.confirmDelete(q.symbol, q.name)
                  })
              )
            }, (q: Quote) => q.symbol)
          }
          .width('100%')
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 14, right: 14 })
        .onRefreshing(() => {
          MarketEngine.getInstance().tick(3)
          this.refreshQuotes(true)
        })
      }

      BottomNav({ active: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
