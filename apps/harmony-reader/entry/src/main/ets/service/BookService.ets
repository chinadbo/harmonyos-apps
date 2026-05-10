import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BookInfo } from '../model/BookInfo';
import DatabaseService from './DatabaseService';
import ChapterParser from './ChapterParser';

const DOMAIN: number = 0x0000;
const TAG: string = 'BookService';
const COLORS: string[] = ['#5B8FF9', '#5AD8A6', '#5D7092', '#F6BD16', '#E8684A', '#6DC8EC'];

export default class BookService {
  static async importBook(context: common.UIAbilityContext): Promise<BookInfo | null> {
    const pickerInstance = new picker.DocumentViewPicker();
    const uris = await pickerInstance.select();
    if (!uris || uris.length === 0) {
      return null;
    }

    const uri = uris[0];
    const sourceFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    const fileName = this.getFileName(uri);
    const targetPath = `${context.filesDir}/${Date.now()}_${fileName}`;
    fs.copyFileSync(sourceFile.fd, targetPath);
    fs.closeSync(sourceFile);

    const text = fs.readTextSync(targetPath, { encoding: 'utf-8' });
    const draftBook = new BookInfo({
      title: fileName.replace(/\.txt$/i, ''),
      localPath: targetPath,
      coverColor: COLORS[Date.now() % COLORS.length],
      createdAt: Date.now()
    });
    const bookId = await DatabaseService.insertBook(context, draftBook);
    const chapters = ChapterParser.parse(bookId, text);
    chapters.forEach((chapter) => {
      chapter.bookId = bookId;
    });
    await DatabaseService.batchInsertChapters(context, chapters);
    const result = new BookInfo({
      ...draftBook,
      id: bookId,
      chapterCount: chapters.length
    });
    hilog.info(DOMAIN, TAG, `Book imported: ${result.title}`);
    return result;
  }

  static async deleteBook(context: common.UIAbilityContext, book: BookInfo): Promise<void> {
    try {
      fs.unlinkSync(book.localPath);
    } catch (_error) {
      hilog.warn(DOMAIN, TAG, `Unable to delete local file: ${book.localPath}`);
    }
    await DatabaseService.deleteBook(context, book.id);
  }

  private static getFileName(uri: string): string {
    const segments = uri.split('/');
    const name = segments[segments.length - 1];
    return name.length > 0 ? name : `book_${Date.now()}.txt`;
  }
}
