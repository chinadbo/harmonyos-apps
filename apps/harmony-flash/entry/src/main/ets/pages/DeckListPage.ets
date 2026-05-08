import { getDB } from '../database/DatabaseHelper';
import { DeckDao } from '../database/DeckDao';
import { Deck, createDeck } from '../model/Deck';
import { DeckCard } from '../components/DeckCard';
import { EmptyState } from '../components/EmptyState';
import common from '@ohos.app.ability.common';

// 导出内容组件，供 NavDestination 使用
@Component
export struct DeckListContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State decks: Deck[] = [];
  @State showCreateDialog: boolean = false;
  @State newDeckName: string = '';
  @State newDeckDesc: string = '';

  async aboutToAppear(): Promise<void> {
    await this.loadDecks();
  }

  async loadDecks(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const store = await getDB(context);
    const dao = new DeckDao(store);
    this.decks = await dao.getAll();
  }

  async createDeck(): Promise<void> {
    if (!this.newDeckName.trim()) return;
    const context = getContext(this) as common.UIAbilityContext;
    const store = await getDB(context);
    const dao = new DeckDao(store);
    const deck = createDeck(this.newDeckName.trim(), this.newDeckDesc.trim());
    await dao.insert(deck);
    this.newDeckName = '';
    this.newDeckDesc = '';
    this.showCreateDialog = false;
    await this.loadDecks();
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

        Text('词库管理')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('+').fontSize(24).fontColor('#3B82F6')
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.showCreateDialog = true; })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      Scroll() {
        Column({ space: 12 }) {
          if (this.decks.length === 0) {
            EmptyState({ emoji: '📚', title: '还没有词库', subtitle: '点击右上角 + 创建词库' })
          } else {
            ForEach(this.decks, (deck: Deck) => {
              DeckCard({
                deck: deck,
                onTap: () => {
                  this.pageStack.pushPathByName('DeckDetailPage', { deckId: deck.id });
                }
              })
            }, (deck: Deck) => String(deck.id))
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 20 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 新建词库对话框
      if (this.showCreateDialog) {
        Stack() {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#000000').opacity(0.4)
            .onClick(() => { this.showCreateDialog = false; })

          Column() {
            Text('新建词库')
              .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
              .margin({ bottom: 20 })
            TextInput({ placeholder: '词库名称（必填）', text: this.newDeckName })
              .onChange(val => { this.newDeckName = val; })
              .margin({ bottom: 12 }).borderRadius(10)
            TextInput({ placeholder: '词库描述（选填）', text: this.newDeckDesc })
              .onChange(val => { this.newDeckDesc = val; })
              .margin({ bottom: 20 }).borderRadius(10)
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1).height(44)
                .backgroundColor('#F3F4F6').fontColor('#374151').borderRadius(12)
                .onClick(() => { this.showCreateDialog = false; })
              Button('创建')
                .layoutWeight(1).height(44)
                .backgroundColor('#3B82F6').borderRadius(12)
                .onClick(() => { this.createDeck(); })
            }
          }
          .width('80%').padding(24)
          .backgroundColor(Color.White).borderRadius(20)
        }
        .width('100%').height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

// @Entry 包装，用于页面直接访问
@Entry
@Component
struct DeckListPage {
  build() {
    DeckListContent()
  }
}
