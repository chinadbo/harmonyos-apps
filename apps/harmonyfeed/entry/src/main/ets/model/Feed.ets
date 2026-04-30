/**
 * Feed 数据模型
 * 代表一个 RSS/Atom 订阅源
 */

@Observed
export class Feed {
  id: number = 0;
  url: string = '';
  title: string = '';
  description: string = '';
  iconUrl: string = '';
  categoryId: number = 0;
  lastUpdated: number = 0;
  unreadCount: number = 0;
  isEnabled: boolean = true;
  createdAt: number = Date.now();

  constructor(partial?: Partial<Feed>) {
    if (partial) {
      if (partial.id !== undefined) this.id = partial.id;
      if (partial.url !== undefined) this.url = partial.url;
      if (partial.title !== undefined) this.title = partial.title;
      if (partial.description !== undefined) this.description = partial.description;
      if (partial.iconUrl !== undefined) this.iconUrl = partial.iconUrl;
      if (partial.categoryId !== undefined) this.categoryId = partial.categoryId;
      if (partial.lastUpdated !== undefined) this.lastUpdated = partial.lastUpdated;
      if (partial.unreadCount !== undefined) this.unreadCount = partial.unreadCount;
      if (partial.isEnabled !== undefined) this.isEnabled = partial.isEnabled;
      if (partial.createdAt !== undefined) this.createdAt = partial.createdAt;
    }
  }

  /** 获取最近更新时间的友好展示 */
  getLastUpdatedDisplay(): string {
    if (!this.lastUpdated) return '从未更新';
    const now = Date.now();
    const diff = now - this.lastUpdated;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    return `${days}天前`;
  }
}

/** Feed 分类 */
@Observed
export class FeedCategory {
  id: number = 0;
  name: string = '';
  sortOrder: number = 0;
  feeds: Feed[] = [];

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
  }
}

/** 热门订阅源推荐数据 */
export const POPULAR_FEEDS: Array<{ name: string; url: string; category: string; description: string }> = [
  // 科技
  { name: 'Hacker News', url: 'https://news.ycombinator.com/rss', category: '科技', description: 'Y Combinator 科技社区' },
  { name: 'The Verge', url: 'https://www.theverge.com/rss/index.xml', category: '科技', description: '科技媒体旗舰' },
  { name: 'TechCrunch', url: 'https://techcrunch.com/feed/', category: '科技', description: '创业与科技资讯' },
  { name: 'Wired', url: 'https://www.wired.com/feed/rss', category: '科技', description: '科技与文化' },
  { name: 'MIT Technology Review', url: 'https://www.technologyreview.com/feed/', category: '科技', description: 'MIT 科技评论' },
  // AI
  { name: 'Google AI Blog', url: 'https://ai.googleblog.com/feeds/posts/default', category: 'AI', description: 'Google AI 官方博客' },
  { name: 'OpenAI Blog', url: 'https://openai.com/blog/rss.xml', category: 'AI', description: 'OpenAI 官方博客' },
  { name: 'Hugging Face Blog', url: 'https://huggingface.co/blog/feed.xml', category: 'AI', description: 'HuggingFace 技术博客' },
  // 开发者
  { name: 'CSS-Tricks', url: 'https://css-tricks.com/feed/', category: '开发', description: 'CSS 与前端技巧' },
  { name: 'Smashing Magazine', url: 'https://www.smashingmagazine.com/feed/', category: '开发', description: 'Web 设计与开发' },
  { name: 'Dev.to', url: 'https://dev.to/feed', category: '开发', description: '开发者社区' },
  // 中文科技
  { name: '少数派', url: 'https://sspai.com/feed', category: '中文科技', description: '高质量 App 与效率工具' },
  { name: 'InfoQ 中文', url: 'https://www.infoq.cn/feed', category: '中文科技', description: '软件架构与最佳实践' },
  { name: '阮一峰的网络日志', url: 'https://www.ruanyifeng.com/blog/atom.xml', category: '中文科技', description: '阮一峰技术博客' },
  // 科学
  { name: 'NASA Breaking News', url: 'https://www.nasa.gov/rss/dyn/breaking_news.rss', category: '科学', description: 'NASA 最新消息' },
  { name: 'New Scientist', url: 'https://www.newscientist.com/feed/home/', category: '科学', description: '新科学家杂志' },
];
