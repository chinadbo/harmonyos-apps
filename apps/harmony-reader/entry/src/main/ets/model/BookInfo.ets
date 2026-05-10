export type ThemeKey = 'light' | 'eye' | 'dark';

export class BookInfo {
  id: number = 0;
  title: string = '';
  author: string = '未知作者';
  localPath: string = '';
  coverColor: string = '#5B8FF9';
  progressPercent: number = 0;
  chapterCount: number = 0;
  createdAt: number = Date.now();

  constructor(init?: Partial<BookInfo>) {
    Object.assign(this, init);
  }
}

export class ChapterInfo {
  id: number = 0;
  bookId: number = 0;
  title: string = '';
  content: string = '';
  orderIndex: number = 0;

  constructor(init?: Partial<ChapterInfo>) {
    Object.assign(this, init);
  }

  getParagraphs(): string[] {
    const parts: string[] = this.content
      .split(/\n{2,}|\r\n{2,}/)
      .map((item: string) => item.trim())
      .filter((item: string) => item.length > 0);
    return parts.length > 0 ? parts : ['暂无内容'];
  }
}

export class BookmarkInfo {
  id: number = 0;
  bookId: number = 0;
  chapterIndex: number = 0;
  paragraphIndex: number = 0;
  chapterTitle: string = '';
  previewText: string = '';
  createdAt: number = Date.now();

  constructor(init?: Partial<BookmarkInfo>) {
    Object.assign(this, init);
  }
}

export class ReadingProgress {
  id: number = 0;
  bookId: number = 0;
  chapterIndex: number = 0;
  paragraphIndex: number = 0;
  updatedAt: number = Date.now();

  constructor(init?: Partial<ReadingProgress>) {
    Object.assign(this, init);
  }
}
