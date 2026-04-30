import { Article } from '../model/Article';
import { DatabaseService } from './DatabaseService';

/**
 * 文章管理服务
 * 负责文章的查询、已读/收藏状态管理
 */
export class ArticleService {
  private static instance: ArticleService;
  private db = DatabaseService.getInstance();

  private constructor() {}

  static getInstance(): ArticleService {
    if (!ArticleService.instance) {
      ArticleService.instance = new ArticleService();
    }
    return ArticleService.instance;
  }

  /** 获取指定 Feed 的文章列表 */
  async getArticlesByFeed(feedId: number, limit: number = 50): Promise<Article[]> {
    return this.db.getArticlesByFeed(feedId, limit);
  }

  /** 获取所有文章（最新 100 条） */
  async getAllArticles(): Promise<Article[]> {
    return this.db.getAllArticles(100);
  }

  /** 获取未读文章 */
  async getUnreadArticles(): Promise<Article[]> {
    return this.db.getUnreadArticles();
  }

  /** 获取收藏文章 */
  async getBookmarkedArticles(): Promise<Article[]> {
    return this.db.getBookmarkedArticles();
  }

  /** 搜索文章 */
  async searchArticles(keyword: string): Promise<Article[]> {
    if (!keyword.trim()) return [];
    return this.db.searchArticles(keyword.trim());
  }

  /** 标记文章已读 */
  async markRead(articleId: number, readProgress: number = 1): Promise<void> {
    await this.db.markArticleRead(articleId, readProgress);
  }

  /** 标记全部已读 */
  async markAllRead(feedId?: number): Promise<void> {
    await this.db.markAllRead(feedId);
  }

  /** 切换收藏状态 */
  async toggleBookmark(article: Article): Promise<boolean> {
    const newState = !article.isBookmarked;
    await this.db.toggleBookmark(article.id, newState);
    article.isBookmarked = newState;
    return newState;
  }

  /** 清理过期文章（超过 30 天且未收藏） */
  async cleanOldArticles(): Promise<void> {
    await this.db.deleteOldArticles();
  }
}
