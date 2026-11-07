/**
 * 自选行情卡片：名称/代码 + 迷你走势线 + 现价(滚动) + 涨跌幅
 */

import { Quote, quoteChangePercent, quoteChange, TYPE_LABELS, emptyQuote } from '../model/Quote'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { SparkLine } from '../chart/SparkLine'
import { NumberRoll } from './NumberRoll'

@Component
export struct QuoteCard {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop quote: Quote = emptyQuote()

  build() {
    Row({ space: 8 }) {
      Column({ space: 3 }) {
        Text(this.quote.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .maxLines(1)
        Text(`${this.quote.symbol} · ${TYPE_LABELS[this.quote.type] || '证券'}`)
          .fontSize(11)
          .fontColor(Theme.TEXT2)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .constraintSize({ minWidth: '34%' })

      Row() {
        SparkLine({
          data: this.quote.minuteData,
          lineColor: Theme.changeColor(this.themeMode, quoteChange(this.quote)),
          lineHeight: 32
        })
      }
      .layoutWeight(1)
      .height(32)

      Column({ space: 3 }) {
        NumberRoll({
          value: this.quote.price,
          color: Theme.changeColor(this.themeMode, quoteChange(this.quote)),
          fontSize: 17
        })
        Text(Fmt.pct(quoteChangePercent(this.quote)))
          .fontSize(11)
          .fontColor('#FFFFFF')
          .backgroundColor(Theme.changeColor(this.themeMode, quoteChange(this.quote)))
          .borderRadius(4)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(Theme.CARD)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 })
  }
}
