import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BookInfo, BookmarkInfo, ChapterInfo, ReadingProgress } from '../model/BookInfo';

const DOMAIN: number = 0x0000;
const TAG: string = 'DatabaseService';
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_reader.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

export default class DatabaseService {
  private static store: relationalStore.RdbStore | null = null;

  private static async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store !== null) {
      return this.store;
    }
    this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT, local_path TEXT NOT NULL, cover_color TEXT, progress_percent INTEGER DEFAULT 0, chapter_count INTEGER DEFAULT 0, created_at INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS chapters (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, order_index INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL, chapter_index INTEGER NOT NULL, paragraph_index INTEGER NOT NULL, chapter_title TEXT NOT NULL, preview_text TEXT NOT NULL, created_at INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS reading_progress (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER UNIQUE NOT NULL, chapter_index INTEGER NOT NULL, paragraph_index INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
    return this.store;
  }

  static async initialize(context: common.UIAbilityContext): Promise<void> {
    await this.getStore(context);
    hilog.info(DOMAIN, TAG, 'Database initialized');
  }

  static async insertBook(context: common.UIAbilityContext, book: BookInfo): Promise<number> {
    const store = await this.getStore(context);
    const id = await store.insert('books', {
      title: book.title,
      author: book.author,
      local_path: book.localPath,
      cover_color: book.coverColor,
      progress_percent: book.progressPercent,
      chapter_count: book.chapterCount,
      created_at: book.createdAt
    });
    return Number(id);
  }

  static async batchInsertChapters(context: common.UIAbilityContext, chapters: ChapterInfo[]): Promise<void> {
    const store = await this.getStore(context);
    const values: Array<relationalStore.ValuesBucket> = chapters.map((chapter: ChapterInfo) => ({
      book_id: chapter.bookId,
      title: chapter.title,
      content: chapter.content,
      order_index: chapter.orderIndex
    }));
    if (values.length > 0) {
      await store.batchInsert('chapters', values);
    }
  }

  static async getBooks(context: common.UIAbilityContext): Promise<BookInfo[]> {
    const store = await this.getStore(context);
    const cursor = await store.querySql('SELECT * FROM books ORDER BY created_at DESC');
    const books: BookInfo[] = [];
    while (cursor.goToNextRow()) {
      books.push(new BookInfo({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        title: cursor.getString(cursor.getColumnIndex('title')),
        author: cursor.getString(cursor.getColumnIndex('author')),
        localPath: cursor.getString(cursor.getColumnIndex('local_path')),
        coverColor: cursor.getString(cursor.getColumnIndex('cover_color')),
        progressPercent: cursor.getLong(cursor.getColumnIndex('progress_percent')),
        chapterCount: cursor.getLong(cursor.getColumnIndex('chapter_count')),
        createdAt: cursor.getLong(cursor.getColumnIndex('created_at'))
      }));
    }
    cursor.close();
    return books;
  }

  static async getBookById(context: common.UIAbilityContext, bookId: number): Promise<BookInfo | null> {
    const store = await this.getStore(context);
    const cursor = await store.querySql(`SELECT * FROM books WHERE id = ${bookId} LIMIT 1`);
    let book: BookInfo | null = null;
    if (cursor.goToFirstRow()) {
      book = new BookInfo({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        title: cursor.getString(cursor.getColumnIndex('title')),
        author: cursor.getString(cursor.getColumnIndex('author')),
        localPath: cursor.getString(cursor.getColumnIndex('local_path')),
        coverColor: cursor.getString(cursor.getColumnIndex('cover_color')),
        progressPercent: cursor.getLong(cursor.getColumnIndex('progress_percent')),
        chapterCount: cursor.getLong(cursor.getColumnIndex('chapter_count')),
        createdAt: cursor.getLong(cursor.getColumnIndex('created_at'))
      });
    }
    cursor.close();
    return book;
  }

  static async getChaptersByBookId(context: common.UIAbilityContext, bookId: number): Promise<ChapterInfo[]> {
    const store = await this.getStore(context);
    const cursor = await store.querySql(`SELECT * FROM chapters WHERE book_id = ${bookId} ORDER BY order_index ASC`);
    const chapters: ChapterInfo[] = [];
    while (cursor.goToNextRow()) {
      chapters.push(new ChapterInfo({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        bookId: cursor.getLong(cursor.getColumnIndex('book_id')),
        title: cursor.getString(cursor.getColumnIndex('title')),
        content: cursor.getString(cursor.getColumnIndex('content')),
        orderIndex: cursor.getLong(cursor.getColumnIndex('order_index'))
      }));
    }
    cursor.close();
    return chapters;
  }

  static async saveReadingProgress(context: common.UIAbilityContext, progress: ReadingProgress): Promise<void> {
    const store = await this.getStore(context);
    await store.executeSql(`INSERT OR REPLACE INTO reading_progress (id, book_id, chapter_index, paragraph_index, updated_at)
      VALUES ((SELECT id FROM reading_progress WHERE book_id = ${progress.bookId}), ${progress.bookId}, ${progress.chapterIndex}, ${progress.paragraphIndex}, ${progress.updatedAt})`);
    const chapters = await this.getChaptersByBookId(context, progress.bookId);
    const percent = chapters.length === 0 ? 0 : Math.min(100, Math.floor(((progress.chapterIndex + 1) / chapters.length) * 100));
    await store.executeSql(`UPDATE books SET progress_percent = ${percent} WHERE id = ${progress.bookId}`);
  }

  static async getReadingProgress(context: common.UIAbilityContext, bookId: number): Promise<ReadingProgress | null> {
    const store = await this.getStore(context);
    const cursor = await store.querySql(`SELECT * FROM reading_progress WHERE book_id = ${bookId} LIMIT 1`);
    let progress: ReadingProgress | null = null;
    if (cursor.goToFirstRow()) {
      progress = new ReadingProgress({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        bookId: cursor.getLong(cursor.getColumnIndex('book_id')),
        chapterIndex: cursor.getLong(cursor.getColumnIndex('chapter_index')),
        paragraphIndex: cursor.getLong(cursor.getColumnIndex('paragraph_index')),
        updatedAt: cursor.getLong(cursor.getColumnIndex('updated_at'))
      });
    }
    cursor.close();
    return progress;
  }

  static async getBookmarks(context: common.UIAbilityContext, bookId: number): Promise<BookmarkInfo[]> {
    const store = await this.getStore(context);
    const cursor = await store.querySql(`SELECT * FROM bookmarks WHERE book_id = ${bookId} ORDER BY created_at DESC`);
    const bookmarks: BookmarkInfo[] = [];
    while (cursor.goToNextRow()) {
      bookmarks.push(new BookmarkInfo({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        bookId: cursor.getLong(cursor.getColumnIndex('book_id')),
        chapterIndex: cursor.getLong(cursor.getColumnIndex('chapter_index')),
        paragraphIndex: cursor.getLong(cursor.getColumnIndex('paragraph_index')),
        chapterTitle: cursor.getString(cursor.getColumnIndex('chapter_title')),
        previewText: cursor.getString(cursor.getColumnIndex('preview_text')),
        createdAt: cursor.getLong(cursor.getColumnIndex('created_at'))
      }));
    }
    cursor.close();
    return bookmarks;
  }

  static async insertBookmark(context: common.UIAbilityContext, bookmark: BookmarkInfo): Promise<void> {
    const store = await this.getStore(context);
    await store.insert('bookmarks', {
      book_id: bookmark.bookId,
      chapter_index: bookmark.chapterIndex,
      paragraph_index: bookmark.paragraphIndex,
      chapter_title: bookmark.chapterTitle,
      preview_text: bookmark.previewText,
      created_at: bookmark.createdAt
    });
  }

  static async deleteBookmark(context: common.UIAbilityContext, bookmarkId: number): Promise<void> {
    const store = await this.getStore(context);
    await store.executeSql(`DELETE FROM bookmarks WHERE id = ${bookmarkId}`);
  }

  static async deleteBook(context: common.UIAbilityContext, bookId: number): Promise<void> {
    const store = await this.getStore(context);
    await store.executeSql(`DELETE FROM chapters WHERE book_id = ${bookId}`);
    await store.executeSql(`DELETE FROM bookmarks WHERE book_id = ${bookId}`);
    await store.executeSql(`DELETE FROM reading_progress WHERE book_id = ${bookId}`);
    await store.executeSql(`DELETE FROM books WHERE id = ${bookId}`);
  }
}
