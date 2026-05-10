import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { BookInfo, BookmarkInfo, ChapterInfo, ReadingProgress } from '../model/BookInfo';
import DatabaseService from '../service/DatabaseService';

@Observed
export default class ReaderViewModel {
  book: BookInfo | null = null;
  chapters: ChapterInfo[] = [];
  bookmarks: BookmarkInfo[] = [];
  currentChapterIndex: number = 0;
  currentParagraphIndex: number = 0;
  topBarVisible: boolean = true;
  bottomBarVisible: boolean = true;
  loaded: boolean = false;

  async initialize(context: common.UIAbilityContext, bookId: number): Promise<void> {
    this.book = await DatabaseService.getBookById(context, bookId);
    this.chapters = await DatabaseService.getChaptersByBookId(context, bookId);
    this.bookmarks = await DatabaseService.getBookmarks(context, bookId);
    const progress = await DatabaseService.getReadingProgress(context, bookId);
    if (progress !== null) {
      this.currentChapterIndex = progress.chapterIndex;
      this.currentParagraphIndex = progress.paragraphIndex;
    }
    this.loaded = true;
  }

  async saveProgress(context: common.UIAbilityContext): Promise<void> {
    if (this.book === null) {
      return;
    }
    await DatabaseService.saveReadingProgress(context, new ReadingProgress({
      bookId: this.book.id,
      chapterIndex: this.currentChapterIndex,
      paragraphIndex: this.currentParagraphIndex,
      updatedAt: Date.now()
    }));
  }

  async changeChapter(context: common.UIAbilityContext, chapterIndex: number): Promise<void> {
    if (chapterIndex < 0 || chapterIndex >= this.chapters.length) {
      return;
    }
    this.currentChapterIndex = chapterIndex;
    this.currentParagraphIndex = 0;
    await this.saveProgress(context);
  }

  async goToPreviousChapter(context: common.UIAbilityContext): Promise<void> {
    await this.changeChapter(context, this.currentChapterIndex - 1);
  }

  async goToNextChapter(context: common.UIAbilityContext): Promise<void> {
    await this.changeChapter(context, this.currentChapterIndex + 1);
  }

  toggleFullscreen(): void {
    this.topBarVisible = !this.topBarVisible;
    this.bottomBarVisible = !this.bottomBarVisible;
  }

  async addBookmark(context: common.UIAbilityContext): Promise<void> {
    const currentChapter = this.getCurrentChapter();
    if (this.book === null || currentChapter === null) {
      return;
    }
    const paragraphs = currentChapter.getParagraphs();
    const preview = paragraphs[Math.min(this.currentParagraphIndex, Math.max(0, paragraphs.length - 1))] ?? currentChapter.content;
    await DatabaseService.insertBookmark(context, new BookmarkInfo({
      bookId: this.book.id,
      chapterIndex: this.currentChapterIndex,
      paragraphIndex: this.currentParagraphIndex,
      chapterTitle: currentChapter.title,
      previewText: preview.slice(0, 40),
      createdAt: Date.now()
    }));
    this.bookmarks = await DatabaseService.getBookmarks(context, this.book.id);
    promptAction.showToast({ message: '书签已添加' });
  }

  async deleteBookmark(context: common.UIAbilityContext, bookmarkId: number): Promise<void> {
    await DatabaseService.deleteBookmark(context, bookmarkId);
    if (this.book !== null) {
      this.bookmarks = await DatabaseService.getBookmarks(context, this.book.id);
    }
  }

  async jumpToBookmark(context: common.UIAbilityContext, bookmark: BookmarkInfo): Promise<void> {
    this.currentParagraphIndex = bookmark.paragraphIndex;
    await this.changeChapter(context, bookmark.chapterIndex);
  }

  getCurrentChapter(): ChapterInfo | null {
    if (this.currentChapterIndex < 0 || this.currentChapterIndex >= this.chapters.length) {
      return null;
    }
    return this.chapters[this.currentChapterIndex];
  }
}
