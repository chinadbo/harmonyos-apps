/**
 * 添加自选页：搜索框过滤内置标的池（30+ 条），按类型 Tab 过滤，点击添加/移除自选
 */

import promptAction from '@ohos.promptAction'
import { Quote, quoteChange, quoteChangePercent, TYPE_LABELS, emptyQuote } from '../model/Quote'
import { WatchItem } from '../model/WatchItem'
import { QuoteDB } from '../db/QuoteDB'
import { MarketEngine, SymbolInfo } from '../market/MarketEngine'
import { IMarketSource, getMarketSource } from '../market/MarketSource'
import { AppInit } from '../common/AppInit'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { BottomNav } from '../components/BottomNav'

const TYPE_TABS: string[] = ['all', 'stock', 'fund', 'index']

@Entry
@Component
struct AddQuotePage {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @State keyword: string = ''
  @State typeTab: string = 'all'
  @State quotes: Quote[] = []
  @State watchSymbols: string[] = []
  @State loaded: boolean = false
  private universe: SymbolInfo[] = []
  private source: IMarketSource = getMarketSource()
  private searchCtrl: TextInputController = new TextInputController()

  aboutToAppear(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    await AppInit.ready()
    this.universe = MarketEngine.getInstance().getUniverse()
    const symbols: string[] = this.universe.map((s: SymbolInfo) => s.symbol)
    this.quotes = await this.source.getQuotes(symbols)
    const wl: WatchItem[] = await QuoteDB.getInstance().getWatchlist()
    this.watchSymbols = wl.map((w: WatchItem) => w.symbol)
    this.loaded = true
  }

  private quoteOf(symbol: string): Quote {
    for (const q of this.quotes) {
      if (q.symbol === symbol) {
        return q
      }
    }
    return emptyQuote()
  }

  private isWatched(symbol: string): boolean {
    return this.watchSymbols.indexOf(symbol) >= 0
  }

  private async toggle(info: SymbolInfo): Promise<void> {
    if (this.isWatched(info.symbol)) {
      await QuoteDB.getInstance().removeWatch(info.symbol)
      this.watchSymbols = this.watchSymbols.filter((s: string) => s !== info.symbol)
      promptAction.showToast({ message: `已移除自选：${info.name}` })
    } else {
      await QuoteDB.getInstance().addWatch(info.symbol, info.name, info.type, this.watchSymbols.length)
      this.watchSymbols = this.watchSymbols.concat([info.symbol])
      promptAction.showToast({ message: `已添加自选：${info.name}` })
    }
  }

  build() {
    Column() {
      Row() {
        Text('添加自选')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Blank()
        Text(`已选 ${this.watchSymbols.length}`)
          .fontSize(12)
          .fontColor(Theme.TEXT2)
          .padding({ right: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })

      // 搜索框
      Row({ space: 6 }) {
        Text('搜索')
          .fontSize(12)
          .fontColor(Theme.TEXT2)
        TextInput({ placeholder: '名称或代码，如 茅台 / SH600519', controller: this.searchCtrl })
          .fontSize(13)
          .height(38)
          .backgroundColor('#00000000')
          .placeholderFont({ size: 13 })
          .onChange((v: string) => {
            this.keyword = v.trim()
          })
        if (this.keyword.length > 0) {
          Text('清除')
            .fontSize(12)
            .fontColor(Theme.TEXT2)
            .onClick(() => {
              this.keyword = ''
              this.searchCtrl.clearText()
            })
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12 })
      .backgroundColor(Theme.CARD)
      .borderRadius(10)
      .margin({ left: 14, right: 14, bottom: 8 })

      // 类型 Tab
      Row({ space: 8 }) {
        ForEach(TYPE_TABS, (t: string) => {
          Text(t === 'all' ? '全部' : TYPE_LABELS[t])
            .fontSize(12)
            .fontColor(this.typeTab === t ? '#FFFFFF' : Theme.TEXT2)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(this.typeTab === t ? Theme.ACCENT : Theme.CARD)
            .onClick(() => {
              this.typeTab = t
            })
        }, (t: string) => t)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 8 })

      // 标的列表
      if (this.loaded) {
        Scroll() {
          List({ space: 8 }) {
            ForEach(this.universe, (info: SymbolInfo) => {
              if (this.matches(info)) {
                ListItem() {
                  this.universeRow(info)
                }
              }
            }, (info: SymbolInfo) => info.symbol + (this.isWatched(info.symbol) ? '_1' : '_0'))
          }
          .width('100%')
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else {
        Column() {
          LoadingProgress()
            .width(28)
            .height(28)
            .color(Theme.ACCENT)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      BottomNav({ active: 3 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  private matches(info: SymbolInfo): boolean {
    if (this.typeTab !== 'all' && info.type !== this.typeTab) {
      return false
    }
    if (this.keyword.length === 0) {
      return true
    }
    return info.name.indexOf(this.keyword) >= 0 || info.symbol.indexOf(this.keyword.toUpperCase()) >= 0
  }

  @Builder
  universeRow(info: SymbolInfo) {
    Row({ space: 8 }) {
      Column({ space: 3 }) {
        Text(info.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .maxLines(1)
        Text(`${info.symbol} · ${TYPE_LABELS[info.type]}`)
          .fontSize(11)
          .fontColor(Theme.TEXT2)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 2 }) {
        Text(this.quoteOf(info.symbol).price.toFixed(2))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.changeColor(this.themeMode, quoteChange(this.quoteOf(info.symbol))))
        Text(Fmt.pct(quoteChangePercent(this.quoteOf(info.symbol))))
          .fontSize(11)
          .fontColor(Theme.changeColor(this.themeMode, quoteChange(this.quoteOf(info.symbol))))
      }
      .alignItems(HorizontalAlign.End)

      Text(this.isWatched(info.symbol) ? '已添加' : '+ 自选')
        .fontSize(12)
        .fontColor(this.isWatched(info.symbol) ? Theme.TEXT3 : '#FFFFFF')
        .backgroundColor(this.isWatched(info.symbol) ? Theme.BG : Theme.ACCENT)
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .onClick(() => {
          this.toggle(info)
        })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(Theme.CARD)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.03)' })
  }
}
