/**
 * Article 数据模型
 * 代表一篇 RSS/Atom 文章条目
 */

@Observed
export class Article {
  id: number = 0;
  feedId: number = 0;
  feedTitle: string = '';
  feedIconUrl: string = '';
  guid: string = '';
  title: string = '';
  link: string = '';
  author: string = '';
  summary: string = '';
  content: string = '';
  publishedAt: number = 0;
  isRead: boolean = false;
  isBookmarked: boolean = false;
  createdAt: number = Date.now();
  readProgress: number = 0; // 阅读进度 0~1，用于跨设备流转

  constructor(partial?: Partial<Article>) {
    if (partial) {
      if (partial.id !== undefined) this.id = partial.id;
      if (partial.feedId !== undefined) this.feedId = partial.feedId;
      if (partial.feedTitle !== undefined) this.feedTitle = partial.feedTitle;
      if (partial.feedIconUrl !== undefined) this.feedIconUrl = partial.feedIconUrl;
      if (partial.guid !== undefined) this.guid = partial.guid;
      if (partial.title !== undefined) this.title = partial.title;
      if (partial.link !== undefined) this.link = partial.link;
      if (partial.author !== undefined) this.author = partial.author;
      if (partial.summary !== undefined) this.summary = partial.summary;
      if (partial.content !== undefined) this.content = partial.content;
      if (partial.publishedAt !== undefined) this.publishedAt = partial.publishedAt;
      if (partial.isRead !== undefined) this.isRead = partial.isRead;
      if (partial.isBookmarked !== undefined) this.isBookmarked = partial.isBookmarked;
      if (partial.createdAt !== undefined) this.createdAt = partial.createdAt;
      if (partial.readProgress !== undefined) this.readProgress = partial.readProgress;
    }
  }

  /** 获取发布时间的友好展示 */
  getPublishedDisplay(): string {
    if (!this.publishedAt) return '';
    const now = Date.now();
    const diff = now - this.publishedAt;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;

    // 超过 7 天显示具体日期
    const date = new Date(this.publishedAt);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /** 获取摘要文本（去除 HTML 标签，截取前 120 字符） */
  getSummaryText(): string {
    const text = (this.summary || this.content || '')
      .replace(/<[^>]+>/g, '') // 去除 HTML 标签
      .replace(/\s+/g, ' ')    // 合并空白
      .trim();
    return text.length > 120 ? text.substring(0, 120) + '...' : text;
  }
}

/** LazyForEach 所需的 IDataSource 实现 */
export class ArticleDataSource implements IDataSource {
  private articles: Article[] = [];
  private listeners: DataChangeListener[] = [];

  setArticles(articles: Article[]): void {
    this.articles = articles;
    this.notifyDataReload();
  }

  totalCount(): number {
    return this.articles.length;
  }

  getData(index: number): Article {
    return this.articles[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(l => l.onDataReloaded());
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(l => l.onDataChanged(index));
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(l => l.onDataAdded(index));
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(l => l.onDataDeleted(index));
  }
}
