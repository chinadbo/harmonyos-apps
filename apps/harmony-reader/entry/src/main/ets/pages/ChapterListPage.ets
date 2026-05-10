import common from '@ohos.app.ability.common';
import { ChapterInfo } from '../model/BookInfo';
import ReaderViewModel from '../viewmodel/ReaderViewModel';

@Component
export struct ChapterListPage {
  @Prop bookId: number;
  private context = getContext(this) as common.UIAbilityContext;
  @State viewModel: ReaderViewModel = new ReaderViewModel();
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    await this.viewModel.initialize(this.context, this.bookId);
  }

  build() {
    Column() {
      Row() {
        Button('<')
          .width(36)
          .height(36)
          .type(ButtonType.Capsule)
          .onClick(() => this.navPathStack.pop())
        Text('章节目录')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)

      List({ space: 8 }) {
        ForEach(this.viewModel.chapters, (chapter: ChapterInfo, index: number) => {
          ListItem() {
            Row() {
              Text(chapter.title)
                .fontSize(16)
                .fontColor(index === this.viewModel.currentChapterIndex ? '#5B8FF9' : '#333333')
                .fontWeight(index === this.viewModel.currentChapterIndex ? FontWeight.Bold : FontWeight.Regular)
              Blank()
              if (index === this.viewModel.currentChapterIndex) {
                Text('当前')
                  .fontSize(12)
                  .fontColor('#5B8FF9')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(14)
          }
          .onClick(async () => {
            await this.viewModel.changeChapter(this.context, index);
            this.navPathStack.pop();
          })
        }, (chapter: ChapterInfo) => `${chapter.id}_${chapter.orderIndex}`)
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7FB')
  }
}
