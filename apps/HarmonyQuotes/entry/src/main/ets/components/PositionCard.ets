/**
 * 持仓卡片：成本/现价/收益率/盈亏额
 */

import { Position, posRoi, posPnl } from '../model/Position'
import { Quote as QuoteModel, emptyQuote } from '../model/Quote'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { NumberRoll } from './NumberRoll'

@Component
export struct PositionCard {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop position: Position = { id: 0, symbol: '', name: '--', type: 'stock', cost: 0, shares: 0, createdAt: 0 }
  @Prop quote: QuoteModel = emptyQuote()
  onEdit: (p: Position) => void = (p: Position) => {
  }
  onDelete: (p: Position) => void = (p: Position) => {
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 3 }) {
          Text(this.position.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.TEXT)
            .maxLines(1)
          Text(`${this.position.symbol} · 持仓 ${Fmt.money(this.position.shares)}`)
            .fontSize(11)
            .fontColor(Theme.TEXT2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: 12 }) {
          Text('编辑')
            .fontSize(12)
            .fontColor(Theme.ACCENT)
            .onClick(() => this.onEdit(this.position))
          Text('删除')
            .fontSize(12)
            .fontColor(Theme.UP_RED)
            .onClick(() => this.onDelete(this.position))
        }
      }

      Divider().color(Theme.GRID).margin({ top: -2, bottom: -2 })

      Row() {
        this.metric('成本价', this.position.cost.toFixed(2), Theme.TEXT)
        this.metric('现价', this.quote.price.toFixed(2),
          Theme.changeColor(this.themeMode, this.quote.price - this.quote.prevClose))
        this.metric('收益率', Fmt.pct(posRoi(this.position, this.quote.price)),
          Theme.changeColor(this.themeMode, posRoi(this.position, this.quote.price)))
        this.metric('盈亏额', Fmt.pnl(posPnl(this.position, this.quote.price)),
          Theme.changeColor(this.themeMode, posPnl(this.position, this.quote.price)))
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.CARD)
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 2 })
  }

  @Builder
  metric(label: string, value: string, color: string) {
    Column({ space: 3 }) {
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
