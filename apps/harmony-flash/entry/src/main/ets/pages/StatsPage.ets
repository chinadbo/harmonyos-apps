import { getDB } from '../database/DatabaseHelper';
import { StudyRecordDao } from '../database/StudyRecordDao';
import { DeckDao } from '../database/DeckDao';
import { Deck } from '../model/Deck';
import { StatsChart } from '../components/StatsChart';
import common from '@ohos.app.ability.common';

@Component
export struct StatsContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State streak: number = 0;
  @State todayCount: number = 0;
  @State dailyData: Array<{ date: string; count: number }> = [];
  @State decks: Deck[] = [];

  async aboutToAppear(): Promise<void> {
    await this.loadStats();
  }

  async loadStats(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const recordDao = new StudyRecordDao(store);
      const deckDao = new DeckDao(store);
      this.streak = await recordDao.getStreakDays();
      this.todayCount = await recordDao.getTodayCount();
      this.dailyData = await recordDao.getDailyCount(7);
      this.decks = await deckDao.getAll();
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←').fontSize(20).fontColor('#374151')
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.pageStack.pop())

        Text('学习统计')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Column().width(40).height(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      Scroll() {
        Column({ space: 20 }) {
          Row({ space: 12 }) {
            Column() {
              Text('🔥').fontSize(28)
              Text(String(this.streak))
                .fontSize(32).fontWeight(FontWeight.Bold).fontColor('#EF4444')
              Text('连续打卡（天）')
                .fontSize(12).fontColor('#9CA3AF').margin({ top: 2 })
            }
            .layoutWeight(1).padding(16)
            .backgroundColor(Color.White).borderRadius(16)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

            Column() {
              Text('✅').fontSize(28)
              Text(String(this.todayCount))
                .fontSize(32).fontWeight(FontWeight.Bold).fontColor('#10B981')
              Text('今日已学')
                .fontSize(12).fontColor('#9CA3AF').margin({ top: 2 })
            }
            .layoutWeight(1).padding(16)
            .backgroundColor(Color.White).borderRadius(16)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
          }

          Column() {
            Text('近7天学习趋势')
              .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1A1A2E')
              .alignSelf(ItemAlign.Start).margin({ bottom: 16 })
            StatsChart({ dailyData: this.dailyData })
          }
          .width('100%').padding(20)
          .backgroundColor(Color.White).borderRadius(16)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          if (this.decks.length > 0) {
            Column() {
              Text('词库掌握率')
                .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#1A1A2E')
                .alignSelf(ItemAlign.Start).margin({ bottom: 16 })

              Column({ space: 16 }) {
                ForEach(this.decks, (deck: Deck) => {
                  Column() {
                    Row() {
                      Text(deck.name)
                        .fontSize(14).fontColor('#374151').layoutWeight(1)
                      Text(`${deck.masteredCount}/${deck.cardCount}`)
                        .fontSize(13).fontColor('#6B7280')
                    }
                    .width('100%').margin({ bottom: 6 })
                    Progress({
                      value: deck.cardCount > 0 ? deck.masteredCount / deck.cardCount * 100 : 0,
                      total: 100,
                      type: ProgressType.Linear
                    })
                      .width('100%').height(6)
                      .color('#3B82F6').backgroundColor('#E5E7EB')
                  }
                }, (deck: Deck) => String(deck.id))
              }
            }
            .width('100%').padding(20)
            .backgroundColor(Color.White).borderRadius(16)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 32 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
struct StatsPage {
  build() {
    StatsContent()
  }
}
