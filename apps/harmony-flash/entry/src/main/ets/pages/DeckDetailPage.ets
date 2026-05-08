import { getDB } from '../database/DatabaseHelper';
import { DeckDao } from '../database/DeckDao';
import { CardDao } from '../database/CardDao';
import { Deck } from '../model/Deck';
import { Card } from '../model/Card';
import { EmptyState } from '../components/EmptyState';
import common from '@ohos.app.ability.common';

@Component
export struct DeckDetailContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Prop initParam: ESObject = null;
  @State deck: Deck | null = null;
  @State cards: Card[] = [];
  @State deckId: number = -1;

  aboutToAppear(): void {
    if (this.initParam) {
      const p = this.initParam as Record<string, number>;
      this.deckId = p.deckId ?? -1;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    if (this.deckId < 0) return;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      this.deck = await new DeckDao(store).getById(this.deckId);
      this.cards = await new CardDao(store).getByDeck(this.deckId);
    } catch (e) {}
  }

  async deleteCard(cardId: number): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      await new CardDao(store).delete(cardId);
      await this.loadData();
    } catch (e) {}
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←').fontSize(20).fontColor('#374151')
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.pageStack.pop())

        Text(this.deck?.name ?? '词库详情')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('+').fontSize(24).fontColor('#3B82F6')
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.pageStack.pushPathByName('CardEditPage', { deckId: this.deckId, cardId: -1 });
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      if (this.deck) {
        Column() {
          Row() {
            Text(`${this.deck.cardCount} 张卡片`)
              .fontSize(14).fontColor('#6B7280')
            Blank()
            Text(`已掌握 ${this.deck.masteredCount} 张`)
              .fontSize(14).fontColor('#10B981')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 8 })

          Button(`开始复习 (${this.deck.cardCount} 张)`)
            .width('calc(100% - 40vp)').height(46)
            .fontSize(15).fontWeight(FontWeight.Medium)
            .backgroundColor('#3B82F6').borderRadius(12)
            .margin({ bottom: 16 })
            .onClick(() => {
              this.pageStack.pushPathByName('StudyPage', { deckId: this.deckId });
            })
        }
      }

      Scroll() {
        Column({ space: 8 }) {
          if (this.cards.length === 0) {
            EmptyState({ emoji: '🃏', title: '还没有卡片', subtitle: '点击右上角 + 添加单词' })
          } else {
            ForEach(this.cards, (card: Card) => {
              Row() {
                Column() {
                  Text(card.front)
                    .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1A1A2E')
                  if (card.phonetic) {
                    Text(card.phonetic)
                      .fontSize(13).fontColor('#9CA3AF').margin({ top: 2 })
                  }
                  Text(card.back)
                    .fontSize(14).fontColor('#6B7280')
                    .margin({ top: 4 }).maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)

                Button({ type: ButtonType.Circle }) {
                  Text('✎').fontSize(14).fontColor('#6B7280')
                }
                .width(32).height(32)
                .backgroundColor('#F3F4F6')
                .onClick(() => {
                  this.pageStack.pushPathByName('CardEditPage', { deckId: this.deckId, cardId: card.id });
                })
              }
              .width('100%').padding(16)
              .backgroundColor(Color.White).borderRadius(12)
              .shadow({ radius: 2, color: '#0000000A', offsetX: 0, offsetY: 1 })
            }, (card: Card) => String(card.id))
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
struct DeckDetailPage {
  build() {
    DeckDetailContent()
  }
}
