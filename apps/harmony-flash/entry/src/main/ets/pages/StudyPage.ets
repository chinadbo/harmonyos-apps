import { getDB } from '../database/DatabaseHelper';
import { CardDao } from '../database/CardDao';
import { StudyRecordDao } from '../database/StudyRecordDao';
import { DeckDao } from '../database/DeckDao';
import { Card } from '../model/Card';
import { createStudyRecord } from '../model/StudyRecord';
import { sm2 } from '../algorithm/SM2Algorithm';
import { FlashCard } from '../components/FlashCard';
import { EmptyState } from '../components/EmptyState';
import common from '@ohos.app.ability.common';

@Component
export struct StudyContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Prop initParam: ESObject = null;
  @State cards: Card[] = [];
  @State currentIndex: number = 0;
  @State isLoading: boolean = true;
  @State isFinished: boolean = false;
  @State studiedCount: number = 0;
  @State deckId: number = -1;

  aboutToAppear(): void {
    if (this.initParam) {
      const p = this.initParam as Record<string, number>;
      this.deckId = p.deckId ?? -1;
    }
    this.loadCards();
  }

  async loadCards(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const cardDao = new CardDao(store);
      if (this.deckId > 0) {
        this.cards = await cardDao.getByDeck(this.deckId);
      } else {
        this.cards = await cardDao.getTodayDue();
      }
      this.isLoading = false;
      if (this.cards.length === 0) {
        this.isFinished = true;
      }
    } catch (e) {
      this.isLoading = false;
    }
  }

  async handleQuality(quality: number): Promise<void> {
    if (this.currentIndex >= this.cards.length) return;
    const card = this.cards[this.currentIndex];
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const cardDao = new CardDao(store);
      const recordDao = new StudyRecordDao(store);
      const deckDao = new DeckDao(store);

      const updatedCard = sm2(card, quality);
      this.cards[this.currentIndex] = updatedCard;
      await cardDao.updateSM2(updatedCard);

      const record = createStudyRecord(card.id, card.deckId, quality);
      await recordDao.insert(record);

      const total = await cardDao.countByDeck(card.deckId);
      const mastered = await cardDao.countMasteredByDeck(card.deckId);
      await deckDao.updateCounts(card.deckId, total, mastered);
    } catch (e) {}

    this.studiedCount++;
    this.currentIndex++;
    if (this.currentIndex >= this.cards.length) {
      this.isFinished = true;
    }
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

        Column() {
          Text('学习中')
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          if (!this.isFinished && this.cards.length > 0) {
            Text(`${this.currentIndex + 1} / ${this.cards.length}`)
              .fontSize(13).fontColor('#9CA3AF')
          }
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)

        Column().width(40).height(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(48).height(48)
          Text('加载中...')
            .fontSize(15).fontColor('#9CA3AF').margin({ top: 12 })
        }
        .width('100%').layoutWeight(1)
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      } else if (this.isFinished) {
        Column({ space: 20 }) {
          Text('🎉').fontSize(64)
          Text('本轮学习完成！')
            .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          Text(`本次复习了 ${this.studiedCount} 张卡片`)
            .fontSize(16).fontColor('#6B7280')
          Button('返回')
            .width(160).height(48).fontSize(16)
            .backgroundColor('#3B82F6').borderRadius(14)
            .onClick(() => this.pageStack.pop())
        }
        .width('100%').layoutWeight(1)
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      } else {
        Column() {
          Progress({
            value: this.currentIndex,
            total: this.cards.length,
            type: ProgressType.Linear
          })
            .width('100%').height(4)
            .color('#3B82F6').backgroundColor('#E5E7EB')
            .padding({ left: 20, right: 20 })

          Column() {
            FlashCard({ card: this.cards[this.currentIndex] })
              .margin({ bottom: 12 })
            Text('点击卡片查看答案')
              .fontSize(13).fontColor('#9CA3AF')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 24 })

          Blank()

          Column() {
            Text('掌握程度')
              .fontSize(14).fontColor('#6B7280').margin({ bottom: 12 })

            Row({ space: 12 }) {
              Button() {
                Column() {
                  Text('😰').fontSize(24)
                  Text('不熟').fontSize(13).fontColor('#EF4444').margin({ top: 4 })
                }
              }
              .layoutWeight(1).height(72)
              .backgroundColor('#FEF2F2').borderRadius(14)
              .onClick(() => { this.handleQuality(0); })

              Button() {
                Column() {
                  Text('🤔').fontSize(24)
                  Text('一般').fontSize(13).fontColor('#F59E0B').margin({ top: 4 })
                }
              }
              .layoutWeight(1).height(72)
              .backgroundColor('#FFFBEB').borderRadius(14)
              .onClick(() => { this.handleQuality(3); })

              Button() {
                Column() {
                  Text('😊').fontSize(24)
                  Text('熟悉').fontSize(13).fontColor('#10B981').margin({ top: 4 })
                }
              }
              .layoutWeight(1).height(72)
              .backgroundColor('#F0FDF4').borderRadius(14)
              .onClick(() => { this.handleQuality(5); })
            }
            .padding({ left: 20, right: 20 })
          }
          .alignItems(HorizontalAlign.Center)
          .padding({ bottom: 40 })
        }
        .width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
struct StudyPage {
  build() {
    StudyContent()
  }
}
