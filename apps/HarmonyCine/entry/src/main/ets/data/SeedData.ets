/**
 * SeedData：硬编码种子库（45 条热门影视，电影/剧集/纪录/动漫均衡分布）。
 * 首次启动且 movie_item 表为空时自动灌入，用户可任意修改或删除。
 * watchedDaysAgo / addedDaysAgo 用于把种子时间铺开到近半年，保证统计图有数据。
 */
import { MovieItem, CineCategory, CineStatus } from '../model/Movie';

export interface SeedEntry {
  title: string;
  category: string;
  status: string;
  rating: number;
  progress: number;
  totalEpisodes: number;
  comment: string;
  /** 状态为「看过」时：多少天前看完（影响柱状图分布） */
  watchedDaysAgo?: number;
  /** 多少天前加入片单（影响 createdTime） */
  addedDaysAgo?: number;
}

export const SEED_MOVIES: SeedEntry[] = [
  // ---------------- 电影 ----------------
  {
    title: '肖申克的救赎', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 10, progress: 0, totalEpisodes: 0, comment: '希望是最好的东西', watchedDaysAgo: 160
  },
  {
    title: '盗梦空间', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '四层梦境结构太精妙', watchedDaysAgo: 148
  },
  {
    title: '星际穿越', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 10, progress: 0, totalEpisodes: 0, comment: '看哭在五维空间那一段', watchedDaysAgo: 120
  },
  {
    title: '楚门的世界', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '', watchedDaysAgo: 95
  },
  {
    title: '千与千寻', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 10, progress: 0, totalEpisodes: 0, comment: '宫崎骏巅峰', watchedDaysAgo: 90
  },
  {
    title: '让子弹飞', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '站着把钱挣了', watchedDaysAgo: 75
  },
  {
    title: '流浪地球2', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 8, progress: 0, totalEpisodes: 0, comment: '数字生命线的伏笔很棒', watchedDaysAgo: 62
  },
  {
    title: '寄生虫', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 8, progress: 0, totalEpisodes: 0, comment: '', watchedDaysAgo: 52
  },
  {
    title: '沙丘2', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '视听盛宴', watchedDaysAgo: 41
  },
  {
    title: '奥本海默', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '三小时毫无尿点', watchedDaysAgo: 30
  },
  {
    title: '疯狂动物城', category: CineCategory.MOVIE, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '', watchedDaysAgo: 20
  },
  {
    title: '布达佩斯大饭店', category: CineCategory.MOVIE, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 0, comment: '对称构图强迫症福音', addedDaysAgo: 12
  },
  {
    title: '你想活出怎样的人生', category: CineCategory.MOVIE, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 0, comment: '宫崎骏新作', addedDaysAgo: 5
  },
  {
    title: '霸王别姬', category: CineCategory.MOVIE, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 0, comment: '补一张华语经典欠条', addedDaysAgo: 2
  },
  // ---------------- 剧集 ----------------
  {
    title: '漫长的季节', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 10, progress: 12, totalEpisodes: 12, comment: '国产剧天花板', watchedDaysAgo: 140
  },
  {
    title: '琅琊榜', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 10, progress: 54, totalEpisodes: 54, comment: 'N 刷', watchedDaysAgo: 135
  },
  {
    title: '绝命毒师', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 10, progress: 62, totalEpisodes: 62, comment: '', watchedDaysAgo: 110
  },
  {
    title: '权力的游戏', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 8, progress: 73, totalEpisodes: 73, comment: '第八季扣一分', watchedDaysAgo: 88
  },
  {
    title: '怪奇物语', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 9, progress: 34, totalEpisodes: 34, comment: '', watchedDaysAgo: 58
  },
  {
    title: '黑暗荣耀', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 9, progress: 16, totalEpisodes: 16, comment: '', watchedDaysAgo: 45
  },
  {
    title: '重启人生', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 9, progress: 10, totalEpisodes: 10, comment: '温柔的高概念', watchedDaysAgo: 26
  },
  {
    title: '三体（电视剧版）', category: CineCategory.TV, status: CineStatus.WATCHING,
    rating: 0, progress: 18, totalEpisodes: 30, comment: '古筝行动名场面', addedDaysAgo: 25
  },
  {
    title: '繁花', category: CineCategory.TV, status: CineStatus.WATCHING,
    rating: 0, progress: 8, totalEpisodes: 30, comment: '王家卫的光影', addedDaysAgo: 20
  },
  {
    title: '庆余年第二季', category: CineCategory.TV, status: CineStatus.WATCHING,
    rating: 0, progress: 12, totalEpisodes: 36, comment: '', addedDaysAgo: 15
  },
  {
    title: '庆余年', category: CineCategory.TV, status: CineStatus.WATCHED,
    rating: 9, progress: 46, totalEpisodes: 46, comment: '', watchedDaysAgo: 100
  },
  {
    title: '辐射', category: CineCategory.TV, status: CineStatus.WATCHING,
    rating: 0, progress: 5, totalEpisodes: 8, comment: '游戏改编意外地好', addedDaysAgo: 8
  },
  {
    title: '真探：夜之国度', category: CineCategory.TV, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 6, comment: '', addedDaysAgo: 6
  },
  {
    title: '最后生还者', category: CineCategory.TV, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 9, comment: '等第二季一起看', addedDaysAgo: 3
  },
  // ---------------- 纪录片 ----------------
  {
    title: '蓝色星球 II', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 10, progress: 7, totalEpisodes: 7, comment: '配乐和镜头都是顶级', watchedDaysAgo: 155
  },
  {
    title: '地球脉动', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 10, progress: 11, totalEpisodes: 11, comment: '', watchedDaysAgo: 132
  },
  {
    title: '人生果实', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 10, progress: 0, totalEpisodes: 0, comment: '缓慢而坚定地生长', watchedDaysAgo: 118
  },
  {
    title: '徒手攀岩', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 9, progress: 0, totalEpisodes: 0, comment: '手心全是汗', watchedDaysAgo: 80
  },
  {
    title: '我在故宫修文物', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 9, progress: 3, totalEpisodes: 3, comment: '', watchedDaysAgo: 66
  },
  {
    title: '舌尖上的中国第一季', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 9, progress: 7, totalEpisodes: 7, comment: '深夜放毒', watchedDaysAgo: 48
  },
  {
    title: '寿司之神', category: CineCategory.DOC, status: CineStatus.WATCHED,
    rating: 8, progress: 0, totalEpisodes: 0, comment: '', watchedDaysAgo: 22
  },
  {
    title: '河西走廊', category: CineCategory.DOC, status: CineStatus.WATCHING,
    rating: 0, progress: 4, totalEpisodes: 10, comment: '配乐大气', addedDaysAgo: 18
  },
  {
    title: '宇宙时空之旅', category: CineCategory.DOC, status: CineStatus.WATCHING,
    rating: 0, progress: 3, totalEpisodes: 13, comment: '', addedDaysAgo: 9
  },
  {
    title: '冻结星球', category: CineCategory.DOC, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 6, comment: '', addedDaysAgo: 4
  },
  // ---------------- 动漫 ----------------
  {
    title: '进击的巨人 完结篇', category: CineCategory.ANIME, status: CineStatus.WATCHED,
    rating: 9, progress: 28, totalEpisodes: 28, comment: '史诗落幕', watchedDaysAgo: 152
  },
  {
    title: '紫罗兰永恒花园', category: CineCategory.ANIME, status: CineStatus.WATCHED,
    rating: 10, progress: 13, totalEpisodes: 13, comment: '京都动画的巅峰作画', watchedDaysAgo: 126
  },
  {
    title: '命运石之门', category: CineCategory.ANIME, status: CineStatus.WATCHED,
    rating: 10, progress: 24, totalEpisodes: 24, comment: '', watchedDaysAgo: 105
  },
  {
    title: '咒术回战', category: CineCategory.ANIME, status: CineStatus.WATCHED,
    rating: 8, progress: 24, totalEpisodes: 24, comment: '', watchedDaysAgo: 70
  },
  {
    title: '间谍过家家', category: CineCategory.ANIME, status: CineStatus.WATCHED,
    rating: 9, progress: 12, totalEpisodes: 12, comment: '阿尼亚哈哈哈', watchedDaysAgo: 38
  },
  {
    title: '葬送的芙莉莲', category: CineCategory.ANIME, status: CineStatus.WATCHING,
    rating: 0, progress: 10, totalEpisodes: 28, comment: '魔法使的世界温柔又哀伤', addedDaysAgo: 22
  },
  {
    title: '鬼灭之刃 柱训练篇', category: CineCategory.ANIME, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 8, comment: '', addedDaysAgo: 7
  },
  {
    title: '宫崎骏剧场合集', category: CineCategory.ANIME, status: CineStatus.WISH,
    rating: 0, progress: 0, totalEpisodes: 0, comment: '补天空之城和魔女宅急便', addedDaysAgo: 1
  }
];

const DAY_MS: number = 24 * 60 * 60 * 1000;

/** 把种子条目转换为待插入的 MovieItem */
export function buildSeedMovie(entry: SeedEntry, now: number): MovieItem {
  const addedDays = entry.addedDaysAgo !== undefined ? entry.addedDaysAgo : 60;
  const createdTime = now - addedDays * DAY_MS;
  let updatedTime = createdTime;
  let progress = entry.progress;
  if (entry.status === CineStatus.WATCHED) {
    const watchedDays = entry.watchedDaysAgo !== undefined ? entry.watchedDaysAgo : 1;
    updatedTime = now - watchedDays * DAY_MS;
    if (updatedTime < createdTime) {
      updatedTime = createdTime + DAY_MS;
    }
    if (entry.totalEpisodes > 0) {
      progress = entry.totalEpisodes;
    }
  }
  return {
    id: 0,
    title: entry.title,
    category: entry.category,
    status: entry.status,
    rating: entry.rating,
    progress: progress,
    totalEpisodes: entry.totalEpisodes,
    comment: entry.comment,
    createdTime: createdTime,
    updatedTime: Math.max(createdTime, updatedTime)
  };
}
