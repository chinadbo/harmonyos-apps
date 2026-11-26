/**
 * Constants.ets — 全局常量、枚举、筛选模型
 * 品类预置、成色、排序、AppStorage 键、颜色与筛选过滤器
 */

export interface CategorySeed {
  key: string;
  name: string;
  icon: string;
}

/** 预置品类（首次启动写入 categories 表） */
export const DEFAULT_CATEGORIES: CategorySeed[] = [
  { key: 'figure', name: '手办', icon: '◆' },
  { key: 'stamp', name: '邮票', icon: '▤' },
  { key: 'coin', name: '钱币', icon: '●' },
  { key: 'sneaker', name: '球鞋', icon: '▲' },
  { key: 'card', name: '卡牌', icon: '■' },
  { key: 'model', name: '模型', icon: '⬟' },
  { key: 'other', name: '其他', icon: '◈' }
];

/** 成色枚举 */
export const CONDITIONS: string[] = ['全新', '95新', '9成新', '有使用痕迹', '仅配件'];

/** 默认品类 key */
export const DEFAULT_CATEGORY_KEY = 'other';

/** 默认成色 */
export const DEFAULT_CONDITION = '全新';

/** 心愿优先级 1-3 */
export const PRIORITIES: number[] = [1, 2, 3];

export function priorityLabel(p: number): string {
  if (p >= 3) {
    return '强烈想要';
  }
  if (p === 2) {
    return '想要';
  }
  return '随缘';
}

/** 排序键 */
export const SORT_CREATED = 'created';
export const SORT_DATE = 'acquireDate';
export const SORT_VALUE = 'estValue';
export const SORT_NAME = 'name';

export interface SortOption {
  key: string;
  label: string;
}

export const SORT_OPTIONS: SortOption[] = [
  { key: SORT_CREATED, label: '最近添加' },
  { key: SORT_DATE, label: '入手日期' },
  { key: SORT_VALUE, label: '估值' },
  { key: SORT_NAME, label: '名称' }
];

export function sortLabel(key: string): string {
  for (let i = 0; i < SORT_OPTIONS.length; i++) {
    if (SORT_OPTIONS[i].key === key) {
      return SORT_OPTIONS[i].label;
    }
  }
  return '最近添加';
}

/** 视图模式 */
export const VIEW_GRID = 'grid';
export const VIEW_LIST = 'list';

/** AppStorage / Preferences 键 */
export const KEY_VIEW_MODE = 'viewMode';
export const KEY_SORT_MODE = 'sortMode';
export const KEY_SHOW_ACQUIRED = 'showAcquired';
export const KEY_REFRESH = 'refreshTick';
export const KEY_READY = 'dbReady';

/** AppStorage 默认值 */
export const DEFAULT_VIEW_MODE = VIEW_GRID;
export const DEFAULT_SORT_MODE = SORT_CREATED;
export const DEFAULT_SHOW_ACQUIRED = false;

/** 心愿状态 */
export const WISH_WANTED = 0;
export const WISH_ACQUIRED = 1;

/** 调色板：博物馆大地色系 */
const PALETTE: string[] = [
  '#B0743B',
  '#7C8A5B',
  '#4F6D7A',
  '#A6503B',
  '#8C6A9E',
  '#C9A227',
  '#6B6B6B',
  '#3F7C6E',
  '#9E5A73',
  '#55688C'
];

/** 预置品类固定配色 */
const CATEGORY_COLOR_MAP: string[] = [
  'figure|#B0743B',
  'stamp|#7C8A5B',
  'coin|#C9A227',
  'sneaker|#4F6D7A',
  'card|#A6503B',
  'model|#3F7C6E',
  'other|#6B6B6B'
];

/** 根据品类 key 取稳定颜色 */
export function categoryColor(key: string): string {
  for (let i = 0; i < CATEGORY_COLOR_MAP.length; i++) {
    const pair = CATEGORY_COLOR_MAP[i].split('|');
    if (pair[0] === key) {
      return pair[1];
    }
  }
  let hash = 0;
  const text = key.length > 0 ? key : 'other';
  for (let i = 0; i < text.length; i++) {
    hash = (hash * 31 + text.charCodeAt(i)) & 0x7fffffff;
  }
  return PALETTE[hash % PALETTE.length];
}

/** 成色配色 */
export function conditionColor(condition: string): string {
  if (condition === '全新') {
    return '#3F7C6E';
  }
  if (condition === '95新') {
    return '#7C8A5B';
  }
  if (condition === '9成新') {
    return '#C9A227';
  }
  if (condition === '有使用痕迹') {
    return '#B0743B';
  }
  if (condition === '仅配件') {
    return '#9E5A73';
  }
  return '#6B6B6B';
}

export function conditionIndex(condition: string): number {
  const idx = CONDITIONS.indexOf(condition);
  return idx < 0 ? 0 : idx;
}

/** 筛选模型 */
export interface ItemFilter {
  keyword: string;
  categories: string[];
  conditions: string[];
  minValue: number;
  maxValue: number;
  sort: string;
}

export function defaultFilter(): ItemFilter {
  const filter: ItemFilter = {
    keyword: '',
    categories: [],
    conditions: [],
    minValue: 0,
    maxValue: 0,
    sort: DEFAULT_SORT_MODE
  };
  return filter;
}

export function hasActiveFilter(filter: ItemFilter): boolean {
  return filter.keyword.length > 0 ||
    filter.categories.length > 0 ||
    filter.conditions.length > 0 ||
    filter.minValue > 0 ||
    filter.maxValue > 0;
}

/** 主题色（与 color.json 一致，供 Canvas / 内联样式使用） */
export const C_BRAND = '#B0743B';
export const C_BG = '#F7F4ED';
export const C_CARD = '#FFFFFF';
export const C_TEXT = '#2B2620';
export const C_SUB = '#8A8175';
export const C_LINE = '#E7E0D4';
export const C_DANGER = '#B34A3C';
export const C_SUCCESS = '#3F7C6E';

/** 刷新信号：通知各 Tab 重新加载数据 */
export function bumpRefresh(): void {
  const current: number = AppStorage.get<number>(KEY_REFRESH) ?? 0;
  AppStorage.setOrCreate<number>(KEY_REFRESH, current + 1);
}
