import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { BookInfo } from '../model/BookInfo';
import DatabaseService from '../service/DatabaseService';
import BookService from '../service/BookService';

@Observed
export default class BookshelfViewModel {
  books: BookInfo[] = [];
  loading: boolean = false;

  async loadBooks(context: common.UIAbilityContext): Promise<void> {
    this.loading = true;
    this.books = await DatabaseService.getBooks(context);
    this.loading = false;
  }

  async importBook(context: common.UIAbilityContext): Promise<void> {
    const book = await BookService.importBook(context);
    if (book !== null) {
      await this.loadBooks(context);
      promptAction.showToast({ message: `已导入《${book.title}》` });
    }
  }

  async deleteBook(context: common.UIAbilityContext, book: BookInfo): Promise<void> {
    await BookService.deleteBook(context, book);
    await this.loadBooks(context);
    promptAction.showToast({ message: `已删除《${book.title}》` });
  }
}
