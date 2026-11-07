/**
 * 顶部指数概览条：3 个内置指数迷你卡（横向滚动）
 */

import { Quote, quoteChangePercent, quoteChange } from '../model/Quote'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { NumberRoll } from './NumberRoll'

@Component
export struct IndexBar {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @Prop quotes: Quote[] = []

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.quotes, (q: Quote) => {
          Column({ space: 2 }) {
            Text(q.name)
              .fontSize(11)
              .fontColor(Theme.TEXT2)
              .maxLines(1)
            NumberRoll({
              value: q.price,
              color: Theme.changeColor(this.themeMode, quoteChange(q)),
              fontSize: 15,
              fontWeight: FontWeight.Medium
            })
            Text(Fmt.pct(quoteChangePercent(q)))
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.changeColor(this.themeMode, quoteChange(q)))
          }
          .alignItems(HorizontalAlign.Center)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.CARD)
          .borderRadius(10)
        }, (q: Quote) => q.symbol)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}
