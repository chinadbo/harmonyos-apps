import common from '@ohos.app.ability.common';
import ReaderViewModel from '../viewmodel/ReaderViewModel';
import { PageContent } from '../components/PageContent';
import { ReaderToolbar } from '../components/ReaderToolbar';
import { ThemePanel } from '../components/ThemePanel';

@Component
export struct ReaderPage {
  @Prop bookId: number;
  private context = getContext(this) as common.UIAbilityContext;
  @State viewModel: ReaderViewModel = new ReaderViewModel();
  @State showThemePanel: boolean = false;
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    await this.viewModel.initialize(this.context, this.bookId);
  }

  build() {
    Column() {
      if (this.viewModel.topBarVisible) {
        Row() {
          Button('<')
            .width(36)
            .height(36)
            .type(ButtonType.Capsule)
            .onClick(() => {
              this.navPathStack.pop();
            })
          Column() {
            Text(this.viewModel.book?.title ?? '阅读器')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(this.viewModel.getCurrentChapter()?.title ?? '')
              .fontSize(13)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          Blank()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#CCFFFFFF')
      }

      if (this.viewModel.loaded && this.viewModel.chapters.length > 0) {
        Swiper() {
          ForEach(this.viewModel.chapters, (chapter, index: number) => {
            PageContent({
              chapter,
              onToggleBars: () => this.viewModel.toggleFullscreen()
            })
          }, (chapter) => `${chapter.orderIndex}`)
        }
        .layoutWeight(1)
        .index(this.viewModel.currentChapterIndex)
        .indicator(false)
        .loop(false)
        .onChange(async (index: number) => {
          await this.viewModel.changeChapter(this.context, index);
        })
      } else {
        Column() {
          Text('正在加载内容...')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      if (this.viewModel.bottomBarVisible) {
        ReaderToolbar({
          onCatalogClick: () => {
            this.navPathStack.pushPathByName('ChapterListPage', { bookId: this.bookId });
          },
          onBookmarkClick: async () => {
            await this.viewModel.addBookmark(this.context);
            this.navPathStack.pushPathByName('BookmarkPage', { bookId: this.bookId });
          },
          onThemeClick: () => {
            this.showThemePanel = true;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showThemePanel, this.themeBuilder(), {
      height: SheetSize.MEDIUM,
      dragBar: true
    })
  }

  @Builder
  private themeBuilder() {
    ThemePanel({
      context: this.context
    })
  }
}
