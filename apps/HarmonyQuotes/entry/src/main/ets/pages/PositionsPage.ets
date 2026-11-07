/**
 * 持仓管理页：持仓列表（成本/现价/收益率/盈亏额）+ 弹窗表单添加/编辑 + 删除
 */

import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Quote, emptyQuote } from '../model/Quote'
import { Position } from '../model/Position'
import { QuoteDB } from '../db/QuoteDB'
import { MarketEngine } from '../market/MarketEngine'
import { IMarketSource, getMarketSource } from '../market/MarketSource'
import { AppInit } from '../common/AppInit'
import { Theme } from '../common/Theme'
import { Fmt } from '../common/Fmt'
import { PositionCard } from '../components/PositionCard'
import { BottomNav } from '../components/BottomNav'
import { NumberRoll } from '../components/NumberRoll'

@Entry
@Component
struct PositionsPage {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @State positions: Position[] = []
  @State posQuotes: Quote[] = []
  @State loaded: boolean = false
  // 弹窗表单状态
  @State showForm: boolean = false
  @State formEditId: number = -1
  @State formSymbol: string = ''
  @State formName: string = ''
  @State formCost: string = ''
  @State formShares: string = ''
  private source: IMarketSource = getMarketSource()

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    await AppInit.ready()
    this.positions = await QuoteDB.getInstance().getPositions()
    await this.refreshQuotes()
    this.loaded = true
  }

  private async refreshQuotes(): Promise<void> {
    const symbols: string[] = this.positions.map((p: Position) => p.symbol)
    this.posQuotes = await this.source.getQuotes(symbols)
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
      sum += p.shares * this.quoteOf(p.symbol).price
    }
    return sum
  }

  private get totalPnl(): number {
    let sum: number = 0
    for (const p of this.positions) {
      const q: Quote = this.quoteOf(p.symbol)
      sum += (q.price - p.cost) * p.shares
    }
    return sum
  }

  private openAdd(): void {
    this.formEditId = -1
    this.formSymbol = ''
    this.formName = ''
    this.formCost = ''
    this.formShares = ''
    this.showForm = true
  }

  private openEdit(p: Position): void {
    this.formEditId = p.id
    this.formSymbol = p.symbol
    this.formName = p.name
    this.formCost = p.cost.toString()
    this.formShares = p.shares.toString()
    this.showForm = true
  }

  private confirmDelete(p: Position): void {
    AlertDialog.show({
      title: '删除持仓',
      message: `确定删除「${p.name}」的持仓记录吗？`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: Theme.UP_RED,
        action: async () => {
          await QuoteDB.getInstance().deletePosition(p.id)
          this.loadData()
          promptAction.showToast({ message: '持仓已删除' })
        }
      }
    })
  }

  private async saveForm(): Promise<void> {
    const symbol: string = this.formSymbol.trim().toUpperCase()
    const cost: number = Number(this.formCost.trim())
    const shares: number = Number(this.formShares.trim())
    if (symbol.length === 0 && this.formEditId < 0) {
      promptAction.showToast({ message: '请输入标的代码' })
      return
    }
    if (Number.isNaN(cost) || cost <= 0) {
      promptAction.showToast({ message: '请输入有效成本价' })
      return
    }
    if (Number.isNaN(shares) || shares <= 0) {
      promptAction.showToast({ message: '请输入有效持仓数量' })
      return
    }
    if (this.formEditId >= 0) {
      await QuoteDB.getInstance().updatePosition(this.formEditId, cost, shares)
      promptAction.showToast({ message: '持仓已更新' })
    } else {
      const info = MarketEngine.getInstance().getSymbolInfo(symbol)
      if (info === null) {
        promptAction.showToast({ message: '标的池中不存在该代码，如 SH600519' })
        return
      }
      await QuoteDB.getInstance().addPosition(info.symbol, info.name, info.type, cost, shares)
      promptAction.showToast({ message: `已添加持仓：${info.name}` })
    }
    this.showForm = false
    this.loadData()
  }

  build() {
    Stack() {
      Column() {
        // 顶栏
        Row() {
          Text('持仓管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text('+ 添加持仓')
            .fontSize(13)
            .fontColor(Theme.ACCENT)
            .padding(6)
            .onClick(() => {
              this.openAdd()
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 6 })

        // 汇总条
        Row({ space: 20 }) {
          Column({ space: 2 }) {
            Text('持仓市值')
              .fontSize(11)
              .fontColor(Theme.TEXT2)
            NumberRoll({ value: this.totalValue, fontSize: 18 })
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 2 }) {
            Text('持仓盈亏')
              .fontSize(11)
              .fontColor(Theme.TEXT2)
            Text(Fmt.pnl(this.totalPnl))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.changeColor(this.themeMode, this.totalPnl))
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
        }
        .width('100%')
        .padding({ left: 18, right: 18, bottom: 8 })

        // 持仓列表
        if (this.loaded && this.positions.length === 0) {
          Column({ space: 8 }) {
            Text('暂无持仓')
              .fontSize(15)
              .fontColor(Theme.TEXT2)
            Text('点击右上「+ 添加持仓」录入你的第一笔持仓')
              .fontSize(12)
              .fontColor(Theme.TEXT3)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            List({ space: 10 }) {
              ForEach(this.positions, (p: Position) => {
                ListItem() {
                  PositionCard({
                    position: p,
                    quote: this.quoteOf(p.symbol),
                    onEdit: (item: Position) => {
                      this.openEdit(item)
                    },
                    onDelete: (item: Position) => {
                      this.confirmDelete(item)
                    }
                  })
                }
              }, (p: Position) => `pos_${p.id}_${p.cost}`)
            }
            .width('100%')
            .scrollBar(BarState.Off)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }

        BottomNav({ active: 1 })
      }
      .width('100%')
      .height('100%')

      // 弹窗表单
      if (this.showForm) {
        Column() {
          Column({ space: 14 }) {
            Text(this.formEditId >= 0 ? '编辑持仓' : '添加持仓')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT)

            Column({ space: 4 }) {
              Text('标的代码')
                .fontSize(11)
                .fontColor(Theme.TEXT2)
              TextInput({
                placeholder: '如 SH600519 / SZ300750 / OF110022',
                text: this.formSymbol
              })
                .fontSize(13)
                .height(40)
                .backgroundColor(Theme.BG)
                .borderRadius(8)
                .enabled(this.formEditId < 0)
                .onChange((v: string) => {
                  this.formSymbol = v
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            Row({ space: 10 }) {
              Column({ space: 4 }) {
                Text('成本单价')
                  .fontSize(11)
                  .fontColor(Theme.TEXT2)
                TextInput({ placeholder: '0.00', text: this.formCost })
                  .fontSize(13)
                  .height(40)
                  .backgroundColor(Theme.BG)
                  .borderRadius(8)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string) => {
                    this.formCost = v
                  })
              }
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text('持仓数量')
                  .fontSize(11)
                  .fontColor(Theme.TEXT2)
                TextInput({ placeholder: '0', text: this.formShares })
                  .fontSize(13)
                  .height(40)
                  .backgroundColor(Theme.BG)
                  .borderRadius(8)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string) => {
                    this.formShares = v
                  })
              }
              .layoutWeight(1)
            }
            .width('100%')

            if (this.formEditId < 0) {
              Text('代码需在内置标的池中，可在「自选」页浏览全部标的')
                .fontSize(11)
                .fontColor(Theme.TEXT3)
            }

            Row({ space: 10 }) {
              Button('取消')
                .fontSize(14)
                .height(38)
                .backgroundColor('#F0F1F5')
                .fontColor(Theme.TEXT2)
                .layoutWeight(1)
                .onClick(() => {
                  this.showForm = false
                })
              Button('保存')
                .fontSize(14)
                .height(38)
                .backgroundColor(Theme.ACCENT)
                .layoutWeight(1)
                .onClick(() => {
                  this.saveForm()
                })
            }
            .width('100%')
          }
          .width('86%')
          .padding(20)
          .backgroundColor(Theme.CARD)
          .borderRadius(14)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.45)')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
