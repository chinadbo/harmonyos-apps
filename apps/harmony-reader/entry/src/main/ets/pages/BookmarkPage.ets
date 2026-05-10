import common from '@ohos.app.ability.common';
import { BookmarkInfo } from '../model/BookInfo';
import ReaderViewModel from '../viewmodel/ReaderViewModel';

@Component
export struct BookmarkPage {
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
        Text('书签')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)

      List({ space: 10 }) {
        ForEach(this.viewModel.bookmarks, (bookmark: BookmarkInfo) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(bookmark.chapterTitle)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
              Text(bookmark.previewText)
                .fontSize(13)
                .fontColor('#666666')
                .maxLines(2)
              Text(new Date(bookmark.createdAt).toLocaleString())
                .fontSize(12)
                .fontColor('#999999')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
          }
          .swipeAction({ end: this.deleteActionBuilder(bookmark) })
          .onClick(async () => {
            await this.viewModel.jumpToBookmark(this.context, bookmark);
            this.navPathStack.pop();
          })
        }, (bookmark: BookmarkInfo) => `${bookmark.id}`)
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F7FB')
  }

  @Builder
  private deleteActionBuilder(bookmark: BookmarkInfo) {
    Button('删除')
      .width(72)
      .height('100%')
      .backgroundColor('#E8684A')
      .fontColor(Color.White)
      .onClick(async () => {
        await this.viewModel.deleteBookmark(this.context, bookmark.id);
      })
  }
}
