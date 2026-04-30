import relationalStore from '@ohos.data.relationalStore';
import { Feed } from '../model/Feed';
import { Article } from '../model/Article';
import { Constants } from '../utils/Constants';

/**
 * 数据库服务单例
 * 封装 RelationalStore 的初始化、CRUD 操作
 */
export class DatabaseService {
  private static instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore | null = null;

  private readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: Constants.DB_NAME,
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  private constructor() {}

  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  /** 初始化数据库（在 EntryAbility.onCreate 中调用） */
  async init(context: Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, this.STORE_CONFIG);
      await this.createTables();
    } catch (err) {
      console.error('[DB] init failed:', JSON.stringify(err));
      throw err;
    }
  }

  /** 检查 DB 是否已初始化 */
  private checkInit(): void {
    if (!this.rdbStore) {
      throw new Error('[DatabaseService] 数据库未初始化，请先调用 init()');
    }
  }

  /** 创建数据库表 */
  private async createTables(): Promise<void> {
    const sqls = [
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_CATEGORIES} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0
      )`,
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_FEEDS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        icon_url TEXT DEFAULT '',
        category_id INTEGER DEFAULT 0,
        last_updated INTEGER DEFAULT 0,
        unread_count INTEGER DEFAULT 0,
        is_enabled INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
      )`,
      `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_ARTICLES} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feed_id INTEGER NOT NULL,
        feed_title TEXT DEFAULT '',
        feed_icon_url TEXT DEFAULT '',
        guid TEXT NOT NULL,
        title TEXT NOT NULL,
        link TEXT NOT NULL,
        author TEXT DEFAULT '',
        summary TEXT DEFAULT '',
        content TEXT DEFAULT '',
        published_at INTEGER DEFAULT 0,
        is_read INTEGER DEFAULT 0,
        is_bookmarked INTEGER DEFAULT 0,
        read_progress REAL DEFAULT 0,
        created_at INTEGER NOT NULL,
        UNIQUE(feed_id, guid)
      )`,
    ];

    for (const sql of sqls) {
      await this.rdbStore!.executeSql(sql);
    }
    console.info('[DB] tables created');
  }

  // ===== Feed CRUD =====

  async insertFeed(feed: Feed): Promise<number> {
    this.checkInit();
    const row: relationalStore.ValuesBucket = {
      url: feed.url,
      title: feed.title,
      description: feed.description,
      icon_url: feed.iconUrl,
      category_id: feed.categoryId,
      last_updated: feed.lastUpdated,
      unread_count: feed.unreadCount,
      is_enabled: feed.isEnabled ? 1 : 0,
      created_at: feed.createdAt,
    };
    const rowId = await this.rdbStore!.insert(Constants.TABLE_FEEDS, row);
    return rowId;
  }

  async getAllFeeds(): Promise<Feed[]> {
    this.checkInit();
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FEEDS);
    predicates.orderByAsc('created_at');
    const cursor = await this.rdbStore!.query(predicates, [
      'id', 'url', 'title', 'description', 'icon_url', 'category_id',
      'last_updated', 'unread_count', 'is_enabled', 'created_at'
    ]);
    const feeds: Feed[] = [];
    while (cursor.goToNextRow()) {
      feeds.push(this.rowToFeed(cursor));
    }
    cursor.close();
    return feeds;
  }

  async updateFeedMeta(id: number, title: string, description: string, iconUrl: string, lastUpdated: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FEEDS);
    predicates.equalTo('id', id);
    await this.rdbStore!.update({
      title, description, icon_url: iconUrl, last_updated: lastUpdated
    }, predicates);
  }

  async updateFeedUnreadCount(feedId: number): Promise<void> {
    const sql = `UPDATE ${Constants.TABLE_FEEDS} SET unread_count = (
      SELECT COUNT(*) FROM ${Constants.TABLE_ARTICLES} 
      WHERE feed_id = ? AND is_read = 0
    ) WHERE id = ?`;
    await this.rdbStore!.executeSql(sql, [feedId, feedId]);
  }

  async deleteFeed(id: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_FEEDS);
    predicates.equalTo('id', id);
    await this.rdbStore!.delete(predicates);
    // 同时删除该 feed 的所有文章
    const articlePredicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    articlePredicates.equalTo('feed_id', id);
    await this.rdbStore!.delete(articlePredicates);
  }

  // ===== Article CRUD =====

  async insertArticles(articles: Article[]): Promise<void> {
    for (const article of articles) {
      const row: relationalStore.ValuesBucket = {
        feed_id: article.feedId,
        feed_title: article.feedTitle,
        feed_icon_url: article.feedIconUrl,
        guid: article.guid,
        title: article.title,
        link: article.link,
        author: article.author,
        summary: article.summary,
        content: article.content,
        published_at: article.publishedAt,
        is_read: 0,
        is_bookmarked: 0,
        read_progress: 0,
        created_at: article.createdAt,
      };
      try {
        await this.rdbStore!.insert(Constants.TABLE_ARTICLES, row,
          relationalStore.ConflictResolution.ON_CONFLICT_IGNORE);
      } catch {
        // 忽略重复插入（UNIQUE constraint）
      }
    }
  }

  async getArticlesByFeed(feedId: number, limit: number = 50, offset: number = 0): Promise<Article[]> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('feed_id', feedId)
      .orderByDesc('published_at')
      .limitAs(limit)
      .offsetAs(offset);
    return this.queryArticles(predicates);
  }

  async getAllArticles(limit: number = 100, offset: number = 0): Promise<Article[]> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.orderByDesc('published_at')
      .limitAs(limit)
      .offsetAs(offset);
    return this.queryArticles(predicates);
  }

  async getUnreadArticles(limit: number = 100): Promise<Article[]> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('is_read', 0)
      .orderByDesc('published_at')
      .limitAs(limit);
    return this.queryArticles(predicates);
  }

  async getBookmarkedArticles(): Promise<Article[]> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('is_bookmarked', 1)
      .orderByDesc('published_at');
    return this.queryArticles(predicates);
  }

  async markArticleRead(id: number, readProgress: number = 1): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('id', id);
    await this.rdbStore!.update({ is_read: 1, read_progress: readProgress }, predicates);
  }

  async markAllRead(feedId?: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('is_read', 0);
    if (feedId !== undefined) {
      predicates.and().equalTo('feed_id', feedId);
    }
    await this.rdbStore!.update({ is_read: 1 }, predicates);
  }

  async toggleBookmark(id: number, bookmarked: boolean): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.equalTo('id', id);
    await this.rdbStore!.update({ is_bookmarked: bookmarked ? 1 : 0 }, predicates);
  }

  async searchArticles(keyword: string, limit: number = 50): Promise<Article[]> {
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.contains('title', keyword)
      .or()
      .contains('summary', keyword)
      .orderByDesc('published_at')
      .limitAs(limit);
    return this.queryArticles(predicates);
  }

  async deleteOldArticles(retainDays: number = Constants.ARTICLE_RETAIN_DAYS): Promise<void> {
    const cutoff = Date.now() - retainDays * 86400000;
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_ARTICLES);
    predicates.lessThan('published_at', cutoff)
      .and()
      .equalTo('is_bookmarked', 0);
    await this.rdbStore!.delete(predicates);
  }

  // ===== 私有辅助方法 =====

  private async queryArticles(predicates: relationalStore.RdbPredicates): Promise<Article[]> {
    const cursor = await this.rdbStore!.query(predicates, [
      'id', 'feed_id', 'feed_title', 'feed_icon_url', 'guid', 'title', 'link',
      'author', 'summary', 'content', 'published_at', 'is_read', 'is_bookmarked',
      'read_progress', 'created_at'
    ]);
    const articles: Article[] = [];
    while (cursor.goToNextRow()) {
      articles.push(this.rowToArticle(cursor));
    }
    cursor.close();
    return articles;
  }

  private rowToFeed(cursor: relationalStore.ResultSet): Feed {
    return new Feed({
      id: cursor.getLong(cursor.getColumnIndex('id')),
      url: cursor.getString(cursor.getColumnIndex('url')),
      title: cursor.getString(cursor.getColumnIndex('title')),
      description: cursor.getString(cursor.getColumnIndex('description')),
      iconUrl: cursor.getString(cursor.getColumnIndex('icon_url')),
      categoryId: cursor.getLong(cursor.getColumnIndex('category_id')),
      lastUpdated: cursor.getLong(cursor.getColumnIndex('last_updated')),
      unreadCount: cursor.getLong(cursor.getColumnIndex('unread_count')),
      isEnabled: cursor.getLong(cursor.getColumnIndex('is_enabled')) === 1,
      createdAt: cursor.getLong(cursor.getColumnIndex('created_at')),
    });
  }

  private rowToArticle(cursor: relationalStore.ResultSet): Article {
    return new Article({
      id: cursor.getLong(cursor.getColumnIndex('id')),
      feedId: cursor.getLong(cursor.getColumnIndex('feed_id')),
      feedTitle: cursor.getString(cursor.getColumnIndex('feed_title')),
      feedIconUrl: cursor.getString(cursor.getColumnIndex('feed_icon_url')),
      guid: cursor.getString(cursor.getColumnIndex('guid')),
      title: cursor.getString(cursor.getColumnIndex('title')),
      link: cursor.getString(cursor.getColumnIndex('link')),
      author: cursor.getString(cursor.getColumnIndex('author')),
      summary: cursor.getString(cursor.getColumnIndex('summary')),
      content: cursor.getString(cursor.getColumnIndex('content')),
      publishedAt: cursor.getLong(cursor.getColumnIndex('published_at')),
      isRead: cursor.getLong(cursor.getColumnIndex('is_read')) === 1,
      isBookmarked: cursor.getLong(cursor.getColumnIndex('is_bookmarked')) === 1,
      readProgress: cursor.getDouble(cursor.getColumnIndex('read_progress')),
      createdAt: cursor.getLong(cursor.getColumnIndex('created_at')),
    });
  }
}
