/**
 * 全局常量定义
 */
export class Constants {
  // 数据库
  static readonly DB_NAME = 'harmonyfeed.db';
  static readonly DB_VERSION = 1;

  // 表名
  static readonly TABLE_FEEDS = 'feeds';
  static readonly TABLE_ARTICLES = 'articles';
  static readonly TABLE_CATEGORIES = 'categories';

  // 刷新间隔（毫秒）
  static readonly REFRESH_15MIN = 15 * 60 * 1000;
  static readonly REFRESH_30MIN = 30 * 60 * 1000;
  static readonly REFRESH_1HOUR = 60 * 60 * 1000;

  // 文章保留天数
  static readonly ARTICLE_RETAIN_DAYS = 30;

  // 每次拉取最大文章数
  static readonly MAX_ARTICLES_PER_FEED = 50;

  // 网络超时（毫秒）
  static readonly HTTP_TIMEOUT = 15000;

  // 搜索防抖延迟
  static readonly SEARCH_DEBOUNCE_MS = 300;

  // 默认分类 ID
  static readonly DEFAULT_CATEGORY_ID = 0;

  // AppStorage Keys
  static readonly KEY_CURRENT_THEME = 'currentTheme';
  static readonly KEY_FONT_SIZE = 'readerFontSize';
  static readonly KEY_REFRESH_INTERVAL = 'refreshInterval';
  static readonly KEY_NOTIFICATION_ENABLED = 'notificationEnabled';

  // 默认设置值
  static readonly DEFAULT_FONT_SIZE = 16;
  static readonly DEFAULT_REFRESH_INTERVAL = Constants.REFRESH_30MIN;
}
