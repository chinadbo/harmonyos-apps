import router from '@ohos.router';
import { Theme } from '../model/Theme';
import { PracticeParams } from '../model/Models';
import { RdbHelper, WrongRow } from '../data/RdbHelper';

@Entry
@Component
struct WrongBookPage {
  @State items: WrongRow[] = [];
  @State loading: boolean = true;
  @State showMastered: boolean = false;
  @State unmasteredCount: number = 0;

  aboutToAppear(): void {
    this.load();
  }

  onPageShow(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.loading = true;
    const rdb: RdbHelper = RdbHelper.getInstance();
    await rdb.ready();
    const all: WrongRow[] = await rdb.queryWrongQuestions();
    let unmastered: number = 0;
    for (const row of all) {
      if (row.mastered === 0) {
        unmastered += 1;
      }
    }
    this.unmasteredCount = unmastered;
    const filtered: WrongRow[] = [];
    for (const row of all) {
      if (this.showMastered && row.mastered === 1) {
        filtered.push(row);
      }
      if (!this.showMastered && row.mastered === 0) {
        filtered.push(row);
      }
    }
    this.items = filtered;
    this.loading = false;
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text($r('app.string.title_wrong_book'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT_DARK)
        Blank()
        Text(`未掌握 ${this.unmasteredCount} 题`)
          .fontSize(13)
          .fontColor(Theme.TEXT_SECONDARY)
      }
      .width('100%')

      Row({ space: 10 }) {
        Text('未掌握')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(!this.showMastered ? Color.White : Theme.TEXT_DARK)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor(!this.showMastered ? Theme.PRIMARY : Color.White)
          .onClick(() => {
            this.showMastered = false;
            this.load();
          })
        Text(`已掌握`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.showMastered ? Color.White : Theme.TEXT_DARK)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .borderRadius(12)
          .backgroundColor(this.showMastered ? Theme.PRIMARY : Color.White)
          .onClick(() => {
            this.showMastered = true;
            this.load();
          })
      }
      .width('100%')

      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(48)
            .height(48)
            .color(Theme.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.items.length === 0) {
        Column({ space: 10 }) {
          Text(this.showMastered ? '还没有已掌握的错题' : '错题本是空的，去练一组题吧')
            .fontSize(15)
            .fontColor(Theme.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (item: WrongRow) => {
              this.WrongItemCard(item)
            }, (item: WrongRow) => `${item.id}`)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Row({ space: 12 }) {
        Button(`重练错题`)
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.unmasteredCount > 0 ? Theme.PRIMARY : '#B8C4D4')
          .onClick(() => {
            this.repractice();
          })
        Button('清空错题')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.White)
          .fontColor(Theme.DANGER)
          .borderRadius(10)
          .onClick(() => {
            this.confirmClear();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Theme.BG)
  }

  @Builder
  WrongItemCard(item: WrongRow) {
    Column({ space: 8 }) {
      Row() {
        Text(item.stem)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT_DARK)
          .layoutWeight(1)
        Text(`错 ${item.wrongCount} 次`)
          .fontSize(12)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(8)
          .backgroundColor(item.wrongCount >= 3 ? Theme.DANGER : Theme.WARNING)
      }
      .width('100%')

      Row() {
        Text(`正确答案 ${item.answer}`)
          .fontSize(13)
          .fontColor(Theme.SUCCESS)
        Blank()
        Text(`上次答 ${item.userAnswer}`)
          .fontSize(13)
          .fontColor(Theme.DANGER)
      }
      .width('100%')

      if (item.mastered === 0) {
        Text('标记已掌握')
          .fontSize(12)
          .fontColor(Theme.PRIMARY)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(10)
          .backgroundColor(Theme.PRIMARY_LIGHT)
          .alignSelf(ItemAlign.Start)
          .onClick(() => {
            this.markMastered(item.id);
          })
      } else {
        Text('已掌握')
          .fontSize(12)
          .fontColor(Theme.SUCCESS)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(10)
          .backgroundColor(Theme.SUCCESS_LIGHT)
          .alignSelf(ItemAlign.Start)
      }
    }
    .width('100%')
    .padding(14)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  private async markMastered(id: number): Promise<void> {
    const rdb: RdbHelper = RdbHelper.getInstance();
    await rdb.markMastered(id);
    this.load();
  }

  private repractice(): void {
    if (this.unmasteredCount === 0) {
      return;
    }
    const params: PracticeParams = { mode: 'wrong', difficulty: 1, limitSec: 0 };
    router.pushUrl({ url: 'pages/PracticePage', params: params });
  }

  private confirmClear(): void {
    AlertDialog.show({
      title: '清空错题本',
      message: '确定删除全部错题记录吗？此操作不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '清空',
        fontColor: Theme.DANGER,
        action: () => {
          this.doClear();
        }
      }
    });
  }

  private async doClear(): Promise<void> {
    const rdb: RdbHelper = RdbHelper.getInstance();
    await rdb.clearWrongBook();
    this.load();
  }
}
