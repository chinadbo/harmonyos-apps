import { getDB } from '../database/DatabaseHelper';
import { DeckDao } from '../database/DeckDao';
import { CardDao } from '../database/CardDao';
import { StudyRecordDao } from '../database/StudyRecordDao';
import { Deck } from '../model/Deck';
import { DeckCard } from '../components/DeckCard';
import { EmptyState } from '../components/EmptyState';
import common from '@ohos.app.ability.common';

// --- 首页内容组件（Navigation 根页）---
@Component
struct HomeContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State decks: Deck[] = [];
  @State todayDueCount: number = 0;
  @State todayStudyCount: number = 0;
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    await this.loadData();
  }

  onPageShow(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const deckDao = new DeckDao(store);
      const cardDao = new CardDao(store);
      const recordDao = new StudyRecordDao(store);
      this.decks = await deckDao.getAll();
      this.todayDueCount = await cardDao.getTodayDueCount();
      this.todayStudyCount = await recordDao.getTodayCount();
      this.isLoading = false;
    } catch (e) {
      this.isLoading = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        // 顶部标题
        Row() {
          Column() {
            Text('HarmonyFlash')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A2E')
            Text('记忆卡片，终身学习')
              .fontSize(13)
              .fontColor('#9CA3AF')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button({ type: ButtonType.Circle }) {
            Text('⚙️').fontSize(20)
          }
          .width(44)
          .height(44)
          .backgroundColor('#F3F4F6')
          .onClick(() => {
            this.pageStack.pushPathByName('SettingsPage', null);
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })

        // 今日统计
        Row() {
          Column() {
            Text(String(this.todayDueCount))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3B82F6')
            Text('待复习')
              .fontSize(13)
              .fontColor('#6B7280')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .padding(16)
          .backgroundColor('#EFF6FF')
          .borderRadius(16)
          .margin({ right: 8 })

          Column() {
            Text(String(this.todayStudyCount))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#10B981')
            Text('今日完成')
              .fontSize(13)
              .fontColor('#6B7280')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .padding(16)
          .backgroundColor('#F0FDF4')
          .borderRadius(16)
          .margin({ left: 8 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })

        // 快速开始按钮
        if (this.todayDueCount > 0) {
          Button(`开始学习 (${this.todayDueCount} 张)`)
            .width('calc(100% - 40vp)')
            .height(52)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#3B82F6')
            .borderRadius(14)
            .margin({ bottom: 24 })
            .onClick(() => {
              this.pageStack.pushPathByName('StudyPage', { deckId: -1 });
            })
        }

        // 词库列表标题
        Row() {
          Text('我的词库')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
          Blank()
          Button('管理词库')
            .fontSize(14)
            .fontColor('#3B82F6')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.pageStack.pushPathByName('DeckListPage', null);
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 12 })

        if (this.isLoading) {
          LoadingProgress()
            .width(40)
            .height(40)
            .margin({ top: 40 })
        } else if (this.decks.length === 0) {
          EmptyState({
            emoji: '📚',
            title: '还没有词库',
            subtitle: '点击"管理词库"创建你的第一个词库'
          })
        } else {
          Column({ space: 12 }) {
            ForEach(this.decks, (deck: Deck) => {
              DeckCard({
                deck: deck,
                onTap: () => {
                  this.pageStack.pushPathByName('DeckDetailPage', { deckId: deck.id });
                }
              })
            }, (deck: Deck) => String(deck.id))
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }

        // 统计入口
        Button('查看学习统计')
          .width('calc(100% - 40vp)')
          .height(44)
          .fontSize(14)
          .fontColor('#3B82F6')
          .backgroundColor('#EFF6FF')
          .borderRadius(12)
          .margin({ bottom: 32 })
          .onClick(() => {
            this.pageStack.pushPathByName('StatsPage', null);
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor('#F8FAFC')
  }
}

// --- 根页面，Navigation 容器 ---
@Entry
@Component
struct Index {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string, param: ESObject) {
    if (name === 'DeckListPage') {
      DeckListDestination()
    } else if (name === 'DeckDetailPage') {
      DeckDetailDestination({ param: param })
    } else if (name === 'CardEditPage') {
      CardEditDestination({ param: param })
    } else if (name === 'StudyPage') {
      StudyDestination({ param: param })
    } else if (name === 'StatsPage') {
      StatsDestination()
    } else if (name === 'SettingsPage') {
      SettingsDestination()
    }
  }

  build() {
    Navigation(this.pageStack) {
      HomeContent()
    }
    .title('HarmonyFlash')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
    .hideTitleBar(true)
    .backgroundColor('#F8FAFC')
  }
}

// --- NavDestination 包装组件 ---
import { DeckListContent } from './DeckListPage';
import { DeckDetailContent } from './DeckDetailPage';
import { CardEditContent } from './CardEditPage';
import { StudyContent } from './StudyPage';
import { StatsContent } from './StatsPage';
import { SettingsContent } from './SettingsPage';

@Component
struct DeckListDestination {
  build() {
    NavDestination() {
      DeckListContent()
    }
    .title('词库管理')
    .hideTitleBar(false)
  }
}

@Component
struct DeckDetailDestination {
  @Prop param: ESObject = null;
  build() {
    NavDestination() {
      DeckDetailContent({ initParam: this.param })
    }
    .hideTitleBar(true)
  }
}

@Component
struct CardEditDestination {
  @Prop param: ESObject = null;
  build() {
    NavDestination() {
      CardEditContent({ initParam: this.param })
    }
    .hideTitleBar(true)
  }
}

@Component
struct StudyDestination {
  @Prop param: ESObject = null;
  build() {
    NavDestination() {
      StudyContent({ initParam: this.param })
    }
    .hideTitleBar(true)
  }
}

@Component
struct StatsDestination {
  build() {
    NavDestination() {
      StatsContent()
    }
    .hideTitleBar(true)
  }
}

@Component
struct SettingsDestination {
  build() {
    NavDestination() {
      SettingsContent()
    }
    .hideTitleBar(true)
  }
}
