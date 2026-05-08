import { getDB } from '../database/DatabaseHelper';
import { CardDao } from '../database/CardDao';
import { DeckDao } from '../database/DeckDao';
import { Card, createCard } from '../model/Card';
import common from '@ohos.app.ability.common';

@Component
export struct CardEditContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Prop initParam: ESObject = null;
  @State deckId: number = -1;
  @State cardId: number = -1;
  @State front: string = '';
  @State back: string = '';
  @State phonetic: string = '';
  @State example: string = '';
  @State isEditMode: boolean = false;
  @State isSaving: boolean = false;

  aboutToAppear(): void {
    if (this.initParam) {
      const p = this.initParam as Record<string, number>;
      this.deckId = p.deckId ?? -1;
      this.cardId = p.cardId ?? -1;
    }
    if (this.cardId > 0) {
      this.isEditMode = true;
      this.loadCard();
    }
  }

  async loadCard(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const cards = await new CardDao(store).getByDeck(this.deckId);
      const card = cards.find(c => c.id === this.cardId);
      if (card) {
        this.front = card.front;
        this.back = card.back;
        this.phonetic = card.phonetic;
        this.example = card.example;
      }
    } catch (e) {}
  }

  async save(): Promise<void> {
    if (!this.front.trim() || !this.back.trim()) return;
    this.isSaving = true;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const store = await getDB(context);
      const cardDao = new CardDao(store);
      const deckDao = new DeckDao(store);

      if (this.isEditMode && this.cardId > 0) {
        const cards = await cardDao.getByDeck(this.deckId);
        const card = cards.find(c => c.id === this.cardId);
        if (card) {
          card.front = this.front.trim();
          card.back = this.back.trim();
          card.phonetic = this.phonetic.trim();
          card.example = this.example.trim();
          await cardDao.update(card);
        }
      } else {
        const card = createCard(this.deckId, this.front.trim(), this.back.trim(), this.phonetic.trim(), this.example.trim());
        await cardDao.insert(card);
        const total = await cardDao.countByDeck(this.deckId);
        const mastered = await cardDao.countMasteredByDeck(this.deckId);
        await deckDao.updateCounts(this.deckId, total, mastered);
      }
      this.pageStack.pop();
    } catch (e) {}
    this.isSaving = false;
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

        Text(this.isEditMode ? '编辑卡片' : '添加卡片')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(15).fontColor(Color.White)
          .backgroundColor('#3B82F6').borderRadius(10)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .enabled(!this.isSaving)
          .onClick(() => { this.save(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      Scroll() {
        Column({ space: 16 }) {
          Column() {
            Text('正面 *（单词/问题）')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
              .alignSelf(ItemAlign.Start).margin({ bottom: 8 })
            TextInput({ placeholder: '输入单词或问题', text: this.front })
              .onChange(val => { this.front = val; })
              .fontSize(18).height(52).borderRadius(10).backgroundColor(Color.White)
          }.width('100%')

          Column() {
            Text('背面 *（释义/答案）')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
              .alignSelf(ItemAlign.Start).margin({ bottom: 8 })
            TextInput({ placeholder: '输入释义或答案', text: this.back })
              .onChange(val => { this.back = val; })
              .fontSize(16).height(52).borderRadius(10).backgroundColor(Color.White)
          }.width('100%')

          Column() {
            Text('音标（可选）')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
              .alignSelf(ItemAlign.Start).margin({ bottom: 8 })
            TextInput({ placeholder: '如 /wɜːrd/', text: this.phonetic })
              .onChange(val => { this.phonetic = val; })
              .fontSize(16).height(48).borderRadius(10).backgroundColor(Color.White)
          }.width('100%')

          Column() {
            Text('例句（可选）')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
              .alignSelf(ItemAlign.Start).margin({ bottom: 8 })
            TextArea({ placeholder: '输入例句', text: this.example })
              .onChange(val => { this.example = val; })
              .fontSize(15).height(80).borderRadius(10).backgroundColor(Color.White)
          }.width('100%')

          if (this.front) {
            Column() {
              Text('预览').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#374151')
                .alignSelf(ItemAlign.Start).margin({ bottom: 8 })
              Column() {
                Text(this.front)
                  .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
                  .textAlign(TextAlign.Center)
                if (this.phonetic) {
                  Text(this.phonetic)
                    .fontSize(16).fontColor('#9CA3AF').textAlign(TextAlign.Center)
                    .margin({ top: 4 })
                }
              }
              .width('100%').height(100)
              .backgroundColor('#EFF6FF').borderRadius(12)
              .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            }.width('100%')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 40 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
struct CardEditPage {
  build() {
    CardEditContent()
  }
}
