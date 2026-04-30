import { Feed } from '../model/Feed';
import { Article } from '../model/Article';
import { DatabaseService } from './DatabaseService';
import { HttpService } from './HttpService';
import { RssParser } from './RssParser';
import { StringUtils } from '../utils/StringUtils';

/**
 * Feed 管理服务
 * 负责 Feed 的增删改查和刷新逻辑
 */
export class FeedService {
  private static instance: FeedService;
  private db = DatabaseService.getInstance();
  private http = HttpService.getInstance();

  private constructor() {}

  static getInstance(): FeedService {
    if (!FeedService.instance) {
      FeedService.instance = new FeedService();
    }
    return FeedService.instance;
  }

  /** 获取所有订阅源 */
  async getAllFeeds(): Promise<Feed[]> {
    return this.db.getAllFeeds();
  }

  /**
   * 添加新订阅源
   * 会先验证 URL 并拉取 Feed 元数据
   */
  async addFeed(url: string): Promise<Feed> {
    if (!StringUtils.isValidUrl(url)) {
      throw new Error('请输入有效的 URL 地址（以 http:// 或 https:// 开头）');
    }

    // 拉取并解析 Feed
    const xml = await this.http.fetchFeed(url);
    const { feedTitle, feedDescription, articles } = RssParser.parse(xml, 0, url);

    const feed = new Feed({
      url,
      title: feedTitle || StringUtils.getDomain(url),
      description: feedDescription,
      iconUrl: StringUtils.getFaviconUrl(url),
      lastUpdated: Date.now(),
      createdAt: Date.now(),
    });

    // 写入数据库
    const id = await this.db.insertFeed(feed);
    feed.id = id;

    // 写入初始文章（更新 feedId）
    const articlesWithId = articles.map(a => new Article({ ...a, feedId: id, feedTitle: feed.title }));
    await this.db.insertArticles(articlesWithId.slice(0, 50));
    await this.db.updateFeedUnreadCount(id);

    return feed;
  }

  /** 删除订阅源（及其文章） */
  async deleteFeed(feedId: number): Promise<void> {
    await this.db.deleteFeed(feedId);
  }

  /**
   * 刷新单个 Feed
   * @returns 新增文章数量
   */
  async refreshFeed(feed: Feed): Promise<number> {
    try {
      const xml = await this.http.fetchFeed(feed.url);
      const { feedTitle, feedDescription, articles } = RssParser.parse(xml, feed.id, feed.url);

      // 更新 Feed 元数据
      await this.db.updateFeedMeta(
        feed.id, feedTitle || feed.title, feedDescription, feed.iconUrl, Date.now()
      );

      // 插入新文章
      const newArticles = articles.map(a => new Article({
        ...a, feedId: feed.id, feedTitle: feedTitle || feed.title
      }));
      await this.db.insertArticles(newArticles);
      await this.db.updateFeedUnreadCount(feed.id);

      return newArticles.length;
    } catch (err) {
      console.error(`[FeedService] refresh feed ${feed.id} failed:`, JSON.stringify(err));
      return 0;
    }
  }

  /** 刷新所有 Feed */
  async refreshAllFeeds(feeds: Feed[]): Promise<{ total: number; success: number }> {
    let success = 0;
    for (const feed of feeds) {
      if (!feed.isEnabled) continue;
      try {
        await this.refreshFeed(feed);
        success++;
      } catch {
        // 单个 Feed 失败不影响其他
      }
    }
    return { total: feeds.length, success };
  }
}
