/**
 * 行情详情页：分时图 / 日K线（Tab 切换）+ 五档关键指标 + 价格提醒设置
 * 提醒阈值存 watchlist 表 alert_high/alert_low，触发时本地通知 + 震动
 */

import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Quote, Candle, quoteChange, quoteChangePercent, quoteAmplitude, emptyQuote } from '../model/Quote'
import { WatchItem } from '../model/WatchItem'
import { QuoteDB } from '../db/QuoteDB'
import { IMarketSource, getMarketSource } from '../market/MarketSource'
import { AppInit } from '../common/AppInit'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { Notify } from '../common/Notify'
import { TimeLineChart } from '../chart/TimeLineChart'
import { CandleChart } from '../chart/CandleChart'
import { NumberRoll } from '../components/NumberRoll'

const REFRESH_MS: number = 5000

@Entry
@Component
struct QuoteDetail {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @StorageLink('alertEnabled') alertEnabled: boolean = true
  @State quote: Quote = emptyQuote()
  @State candles: Candle[] = []
  @State chartTab: number = 0
  @State alertHighText: string = ''
  @State alertLowText: string = ''
  @State lastUpdate: string = ''
  private symbol: string = ''
  private source: IMarketSource = getMarketSource()
  private timer: number = -1
  private historyLoaded: boolean = false
  private alertNotifiedHigh: boolean = false
  private alertNotifiedLow: boolean = false
  private alertHigh: number = 0
  private alertLow: number = 0

  aboutToAppear(): void {
    const p = router.getParams() as Record<string, string>
    if (p !== undefined && p !== null && p['symbol'] !== undefined) {
      this.symbol = p['symbol']
    } else {
      this.symbol = 'SH600519'
    }
    this.loadQuote()
    this.loadAlerts()
    this.timer = setInterval(() => {
      this.loadQuote()
    }, REFRESH_MS)
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  private async loadQuote(): Promise<void> {
    await AppInit.ready()
    const qs: Quote[] = await this.source.getQuotes([this.symbol])
    if (qs.length > 0) {
      this.quote = qs[0]
      this.lastUpdate = Fmt.time(Date.now())
      this.checkAlerts()
    }
    if (!this.historyLoaded) {
      this.candles = await this.source.getHistory(this.symbol, 120)
      this.historyLoaded = true
    }
  }

  private async loadAlerts(): Promise<void> {
    await AppInit.ready()
    const list: WatchItem[] = await QuoteDB.getInstance().getWatchlist()
    for (const w of list) {
      if (w.symbol === this.symbol) {
        this.alertHigh = w.alertHigh
        this.alertLow = w.alertLow
        this.alertHighText = w.alertHigh > 0 ? w.alertHigh.toString() : ''
        this.alertLowText = w.alertLow > 0 ? w.alertLow.toString() : ''
        return
      }
    }
  }

  private checkAlerts(): void {
    if (!this.alertEnabled) {
      return
    }
    const price: number = this.quote.price
    if (this.alertHigh > 0 && price >= this.alertHigh) {
      if (!this.alertNotifiedHigh) {
        this.alertNotifiedHigh = true
        Notify.sendQuoteAlert(this.quote.name, price, true, this.alertHigh)
      }
    } else if (price < this.alertHigh * 0.995) {
      this.alertNotifiedHigh = false
    }
    if (this.alertLow > 0 && price <= this.alertLow) {
      if (!this.alertNotifiedLow) {
        this.alertNotifiedLow = true
        Notify.sendQuoteAlert(this.quote.name, price, false, this.alertLow)
      }
    } else if (price > this.alertLow * 1.005) {
      this.alertNotifiedLow = false
    }
  }

  private async saveAlerts(): Promise<void> {
    const high: number = this.alertHighText.trim().length > 0 ? Number(this.alertHighText.trim()) : 0
    const low: number = this.alertLowText.trim().length > 0 ? Number(this.alertLowText.trim()) : 0
    if (Number.isNaN(high) || Number.isNaN(low) || high < 0 || low < 0) {
      promptAction.showToast({ message: '请输入有效的提醒价格' })
      return
    }
    if (high > 0 && low > 0 && low >= high) {
      promptAction.showToast({ message: '低位阈值需低于高位阈值' })
      return
    }
    await QuoteDB.getInstance().setAlert(this.symbol, high, low)
    this.alertHigh = high
    this.alertLow = low
    this.alertNotifiedHigh = false
    this.alertNotifiedLow = false
    if (this.alertEnabled && (high > 0 || low > 0)) {
      const ok: boolean = await Notify.ensurePermission()
      promptAction.showToast({
        message: ok ? '提醒已保存，达到阈值将通知你' : '提醒已保存（未授权通知，仅震动提示）'
      })
    } else {
      promptAction.showToast({ message: '提醒已清除' })
    }
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('‹')
          .fontSize(24)
          .fontColor(Theme.TEXT)
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back()
          })
        Column({ space: 1 }) {
          Text(this.quote.name)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Text(`${this.quote.symbol} · 模拟行情`)
            .fontSize(11)
            .fontColor(Theme.TEXT2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(`更新 ${this.lastUpdate}`)
          .fontSize(10)
          .fontColor(Theme.TEXT3)
          .padding({ right: 8 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      Scroll() {
        Column() {
          // 价格区
          Row({ space: 14 }) {
            NumberRoll({
              value: this.quote.price,
              color: Theme.changeColor(this.themeMode, quoteChange(this.quote)),
              fontSize: 32
            })
            Column({ space: 3 }) {
              Text(`${Fmt.pnl(quoteChange(this.quote))}  ${Fmt.pct(quoteChangePercent(this.quote))}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.changeColor(this.themeMode, quoteChange(this.quote)))
              Text(`昨收 ${this.quote.prevClose.toFixed(2)}`)
                .fontSize(11)
                .fontColor(Theme.TEXT2)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: 6, bottom: 10 })

          // 图表 Tab 切换
          Row() {
            this.tabButton('分时图', 0)
            this.tabButton('日K线', 1)
          }
          .width('100%')
          .backgroundColor(Theme.CARD)
          .borderRadius(10)
          .padding(3)
          .margin({ bottom: 10 })

          // 图表
          Column() {
            if (this.chartTab === 0) {
              TimeLineChart({
                data: this.quote.minuteData,
                avgData: this.quote.avgData,
                base: this.quote.prevClose,
                chartHeight: 260
              })
            } else {
              CandleChart({
                candles: this.candles,
                chartHeight: 430
              })
            }
          }
          .width('100%')
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .padding({ left: 6, right: 6, top: 4, bottom: 4 })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 五档关键指标
          Column({ space: 10 }) {
            Text('关键指标')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            Row() {
              this.indicator('开盘', this.quote.open.toFixed(2), Theme.TEXT)
              this.indicator('最高', this.quote.high.toFixed(2), Theme.up(this.themeMode))
              this.indicator('最低', this.quote.low.toFixed(2), Theme.down(this.themeMode))
            }
            .width('100%')
            Row() {
              this.indicator('成交量', Fmt.vol(this.quote.volume), Theme.TEXT)
              this.indicator('振幅', quoteAmplitude(this.quote).toFixed(2) + '%', Theme.TEXT)
              this.indicator('现价', this.quote.price.toFixed(2),
                Theme.changeColor(this.themeMode, quoteChange(this.quote)))
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .margin({ top: 10 })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 价格提醒
          Column({ space: 10 }) {
            Row() {
              Text('价格提醒')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.TEXT)
              Blank()
              Text(this.alertEnabled ? '已开启' : '已全局关闭')
                .fontSize(11)
                .fontColor(this.alertEnabled ? Theme.ACCENT : Theme.TEXT3)
            }
            .width('100%')

            Row({ space: 10 }) {
              Column({ space: 4 }) {
                Text('高于阈值')
                  .fontSize(11)
                  .fontColor(Theme.TEXT2)
                TextInput({ placeholder: '如 ' + (this.quote.price * 1.03).toFixed(2), text: this.alertHighText })
                  .fontSize(13)
                  .height(38)
                  .backgroundColor(Theme.BG)
                  .borderRadius(8)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string) => {
                    this.alertHighText = v
                  })
              }
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text('低于阈值')
                  .fontSize(11)
                  .fontColor(Theme.TEXT2)
                TextInput({ placeholder: '如 ' + (this.quote.price * 0.97).toFixed(2), text: this.alertLowText })
                  .fontSize(13)
                  .height(38)
                  .backgroundColor(Theme.BG)
                  .borderRadius(8)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string) => {
                    this.alertLowText = v
                  })
              }
              .layoutWeight(1)
            }
            .width('100%')

            Row({ space: 10 }) {
              Button('保存提醒')
                .fontSize(13)
                .height(36)
                .backgroundColor(Theme.ACCENT)
                .layoutWeight(1)
                .onClick(() => {
                  this.saveAlerts()
                })
              Button('清除')
                .fontSize(13)
                .height(36)
                .backgroundColor('#F0F1F5')
                .fontColor(Theme.TEXT2)
                .layoutWeight(1)
                .onClick(() => {
                  this.alertHighText = ''
                  this.alertLowText = ''
                  this.saveAlerts()
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .margin({ top: 10, bottom: 20 })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 4 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  tabButton(label: string, idx: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.chartTab === idx ? '#FFFFFF' : Theme.TEXT2)
      .fontWeight(this.chartTab === idx ? FontWeight.Medium : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .height(30)
      .layoutWeight(1)
      .borderRadius(8)
      .backgroundColor(this.chartTab === idx ? Theme.ACCENT : Theme.CARD)
      .onClick(() => {
        this.chartTab = idx
      })
  }

  @Builder
  indicator(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor(Theme.TEXT2)
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}
