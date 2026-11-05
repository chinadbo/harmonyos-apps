/**
 * HarmonyCine 数据模型：枚举、条目/记录接口、成就定义、海报色板与通用工具函数。
 * 纯数据层，不依赖 UI 与数据库。
 */

// ---------------- 枚举 ----------------

/** 作品类型（自定义命名，避开系统 PlayMode 等冲突） */
export enum CineCategory {
  MOVIE = 'movie',
  TV = 'tv',
  DOC = 'doc',
  ANIME = 'anime'
}

/** 观看状态 */
export enum CineStatus {
  WATCHING = 'watching',
  WISH = 'wish',
  WATCHED = 'watched'
}

/** 观看记录动作类型 */
export enum WatchAction {
  ADD = 'add',
  STATUS_CHANGE = 'status_change',
  RATING = 'rating'
}

// ---------------- 数据接口 ----------------

/** 影视条目（对应 movie_item 表） */
export interface MovieItem {
  id: number;
  title: string;
  category: string;
  status: string;
  rating: number;
  progress: number;
  totalEpisodes: number;
  comment: string;
  createdTime: number;
  updatedTime: number;
}

/** 观看记录（对应 watch_record 表） */
export interface WatchRecordItem {
  id: number;
  movieId: number;
  action: string;
  recordTime: number;
}

/** 环形图分段 */
export interface RingSegment {
  label: string;
  value: number;
  color: string;
}

/** 柱状图数据项 */
export interface BarItem {
  label: string;
  value: number;
}

/** 各状态条目计数 */
export interface TabCounts {
  watching: number;
  wish: number;
  watched: number;
  total: number;
}

/** 成就定义 */
export interface AchievementDef {
  id: string;
  threshold: number;
  name: string;
  description: string;
}

// ---------------- 成就 ----------------

export const ACHIEVEMENT_DEFS: AchievementDef[] = [
  {
    id: 'milestone_10',
    threshold: 10,
    name: '初露锋芒',
    description: '累计看完 10 部作品'
  },
  {
    id: 'milestone_30',
    threshold: 30,
    name: '渐入佳境',
    description: '累计看完 30 部作品'
  },
  {
    id: 'milestone_50',
    threshold: 50,
    name: '观影达人',
    description: '累计看完 50 部作品'
  },
  {
    id: 'milestone_100',
    threshold: 100,
    name: '片单大师',
    description: '累计看完 100 部作品'
  }
];

// ---------------- 海报色板 ----------------

/** 12 组渐变海报配色 [起始色, 结束色] */
export const POSTER_PALETTE: string[][] = [
  ['#FF6B6B', '#C0392B'],
  ['#4ECDC4', '#21867C'],
  ['#FDCB6E', '#D68910'],
  ['#6C5CE7', '#39236B'],
  ['#00B894', '#0A7C61'],
  ['#E84393', '#92285B'],
  ['#74B9FF', '#2D6CB5'],
  ['#FF9F43', '#B35C0E'],
  ['#A29BFE', '#5B52C4'],
  ['#55EFC4', '#0FA67D'],
  ['#FF7675', '#B23A39'],
  ['#81ECEB', '#0B7285']
];

/**
 * 根据条目 id 与用户色板偏移生成海报渐变色序列。
 * 同一 id 颜色稳定，偏移量用于整体换色。
 */
export function posterColors(id: number, offset: number): [ResourceColor, number][] {
  const index = Math.abs(id + offset) % POSTER_PALETTE.length;
  const pair = POSTER_PALETTE[index];
  const colors: [ResourceColor, number][] = [
    [pair[0], 0.0],
    [pair[1], 1.0]
  ];
  return colors;
}

// ---------------- 类型/状态展示工具 ----------------

export function categoryLabel(category: string): string {
  switch (category) {
    case CineCategory.MOVIE:
      return '电影';
    case CineCategory.TV:
      return '剧集';
    case CineCategory.DOC:
      return '纪录片';
    case CineCategory.ANIME:
      return '动漫';
    default:
      return '其他';
  }
}

export function categorySymbol(category: string): string {
  switch (category) {
    case CineCategory.MOVIE:
      return '▶';
    case CineCategory.TV:
      return '≡';
    case CineCategory.DOC:
      return '◎';
    case CineCategory.ANIME:
      return '✦';
    default:
      return '◇';
  }
}

export function categoryColor(category: string): string {
  switch (category) {
    case CineCategory.MOVIE:
      return '#FF6B6B';
    case CineCategory.TV:
      return '#4ECDC4';
    case CineCategory.DOC:
      return '#74B9FF';
    case CineCategory.ANIME:
      return '#A29BFE';
    default:
      return '#8A8F9E';
  }
}

export function categoryList(): string[] {
  return [CineCategory.MOVIE, CineCategory.TV, CineCategory.DOC, CineCategory.ANIME];
}

export function statusLabel(status: string): string {
  switch (status) {
    case CineStatus.WATCHING:
      return '在看';
    case CineStatus.WISH:
      return '想看';
    case CineStatus.WATCHED:
      return '看过';
    default:
      return '未知';
  }
}

export function statusColor(status: string): string {
  switch (status) {
    case CineStatus.WATCHING:
      return '#F39C12';
    case CineStatus.WISH:
      return '#74B9FF';
    case CineStatus.WATCHED:
      return '#00B894';
    default:
      return '#8A8F9E';
  }
}

export function statusList(): string[] {
  return [CineStatus.WATCHING, CineStatus.WISH, CineStatus.WATCHED];
}

export function watchActionLabel(action: string): string {
  switch (action) {
    case WatchAction.ADD:
      return '加入片单';
    case WatchAction.STATUS_CHANGE:
      return '状态流转';
    case WatchAction.RATING:
      return '更新评分';
    default:
      return '其他';
  }
}

// ---------------- 时间工具 ----------------

function pad(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

/** 毫秒时间戳 -> 'yyyy-MM-dd HH:mm' */
export function formatDateTime(ts: number): string {
  const date = new Date(ts);
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} `
    + `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/** 毫秒时间戳 -> 'yyyy-MM-dd' */
export function formatDate(ts: number): string {
  const date = new Date(ts);
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

/** 毫秒时间戳 -> 'M月' */
export function monthLabel(ts: number): string {
  return `${new Date(ts).getMonth() + 1}月`;
}

/** 最近 count 个月（含当月）的起始时间戳，按从早到晚排列 */
export function recentMonthStarts(count: number, now: number): number[] {
  const starts: number[] = [];
  const current = new Date(now);
  current.setDate(1);
  current.setHours(0, 0, 0, 0);
  for (let i = count - 1; i >= 0; i--) {
    const d = new Date(current.getFullYear(), current.getMonth() - i, 1);
    starts.push(d.getTime());
  }
  return starts;
}

// ---------------- 模型构造工具 ----------------

export function emptyMovie(): MovieItem {
  return {
    id: 0,
    title: '',
    category: CineCategory.MOVIE,
    status: CineStatus.WISH,
    rating: 0,
    progress: 0,
    totalEpisodes: 0,
    comment: '',
    createdTime: 0,
    updatedTime: 0
  };
}

export function emptyCounts(): TabCounts {
  return {
    watching: 0,
    wish: 0,
    watched: 0,
    total: 0
  };
}
