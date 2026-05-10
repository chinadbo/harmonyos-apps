import common from '@ohos.app.ability.common';
import { BookInfo } from '../model/BookInfo';
import BookshelfViewModel from '../viewmodel/BookshelfViewModel';
import { BookCard } from '../components/BookCard';
import { ReaderPage } from './ReaderPage';
import { BookmarkPage } from './BookmarkPage';
import { ChapterListPage } from './ChapterListPage';

@Entry
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext;
  @State viewModel: BookshelfViewModel = new BookshelfViewModel();
  @State showDeleteDialog: boolean = false;
  @State pendingDeleteBook: BookInfo | null = null;
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    await this.viewModel.loadBooks(this.context);
  }

  private openReader(book: BookInfo): void {
    this.navPathStack.pushPathByName('ReaderPage', { bookId: book.id });
  }

  private confirmDelete(book: BookInfo): void {
    this.pendingDeleteBook = book;
    this.showDeleteDialog = true;
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {
        Row() {
          Text('书架')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          Blank()
          Button('+')
            .width(40)
            .height(40)
            .type(ButtonType.Capsule)
            .onClick(async () => {
              await this.viewModel.importBook(this.context);
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12 })

        if (this.viewModel.books.length === 0) {
          Column() {
            Text('暂无书籍，点击 + 导入')
              .fontSize(18)
              .fontColor('#666666')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Grid() {
            ForEach(this.viewModel.books, (book: BookInfo) => {
              GridItem() {
                BookCard({
                  book,
                  onClick: (item: BookInfo) => this.openReader(item),
                  onLongPress: (item: BookInfo) => this.confirmDelete(item)
                })
              }
            }, (book: BookInfo) => `${book.id}`)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .padding(20)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F7FB')
      .bindContentCover($$this.showDeleteDialog, this.deleteDialogBuilder(), {
        modalTransition: ModalTransition.DEFAULT
      })
    }
    .title('HarmonyReader')
    .navDestination(this.pageMap)
  }

  @Builder
  private deleteDialogBuilder() {
    Column({ space: 16 }) {
      Text('确认删除这本书吗？')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .onClick(() => {
            this.showDeleteDialog = false;
          })
        Button('删除')
          .layoutWeight(1)
          .backgroundColor('#E8684A')
          .fontColor(Color.White)
          .onClick(async () => {
            if (this.pendingDeleteBook !== null) {
              await this.viewModel.deleteBook(this.context, this.pendingDeleteBook);
            }
            this.showDeleteDialog = false;
          })
      }
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }

  @Builder
  private pageMap(name: string, param: Object) {
    const routeParam = param as Record<string, number>;
    if (name === 'ReaderPage') {
      ReaderPage({ bookId: routeParam.bookId });
    } else if (name === 'BookmarkPage') {
      BookmarkPage({ bookId: routeParam.bookId });
    } else if (name === 'ChapterListPage') {
      ChapterListPage({ bookId: routeParam.bookId });
    } else {
      Text('Page not found');
    }
  }
}
