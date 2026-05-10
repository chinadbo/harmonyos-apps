import hilog from '@ohos.hilog';
import { ChapterInfo } from '../model/BookInfo';

const DOMAIN: number = 0x0000;
const TAG: string = 'ChapterParser';
const CHAPTER_PATTERNS: RegExp[] = [
  /^第[零一二三四五六七八九十百千万\d]+[章节回卷部篇]/,
  /^Chapter\s+\d+/i,
  /^\d{1,3}[\.、。]\s*[一-龥]/
];

export default class ChapterParser {
  static parse(bookId: number, rawText: string): ChapterInfo[] {
    const text: string = rawText.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    const lines: string[] = text.split('\n');
    const chapters: ChapterInfo[] = [];
    let currentTitle: string = '开始';
    let currentLines: string[] = [];
    let orderIndex: number = 0;

    const pushChapter = () => {
      const content: string = currentLines.join('\n').trim();
      if (content.length === 0 && chapters.length > 0) {
        return;
      }
      chapters.push(new ChapterInfo({
        bookId,
        title: currentTitle,
        content: content.length > 0 ? content : '暂无内容',
        orderIndex
      }));
      orderIndex += 1;
    };

    for (let index = 0; index < lines.length; index += 1) {
      const line: string = lines[index].trim();
      if (this.isChapterTitle(line)) {
        if (currentLines.length > 0 || chapters.length === 0) {
          pushChapter();
          currentLines = [];
        }
        currentTitle = line;
        continue;
      }
      currentLines.push(lines[index]);
    }

    if (currentLines.length > 0 || chapters.length === 0) {
      pushChapter();
    }

    if (chapters.length === 0) {
      hilog.warn(DOMAIN, TAG, 'No chapter parsed, fallback to single chapter');
      return [new ChapterInfo({ bookId, title: '正文', content: text.trim(), orderIndex: 0 })];
    }

    return chapters.filter((item: ChapterInfo, idx: number) => !(idx === 0 && item.content === '暂无内容' && item.title === '开始' && chapters.length > 1));
  }

  static isChapterTitle(line: string): boolean {
    return CHAPTER_PATTERNS.some((pattern: RegExp) => pattern.test(line));
  }
}
