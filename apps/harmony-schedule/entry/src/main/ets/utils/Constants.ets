import { TagModel } from '../models/TagModel';
import { RepeatType } from '../models/EventModel';

// 应用常量，集中管理主题、提醒和预设标签配置
export const APP_PRIMARY_COLOR: string = '#4A90D9';
export const EVENT_PRESET_COLORS: string[] = ['#4A90D9', '#43C463', '#F5A623', '#8B5CF6', '#D64545'];
export const REMINDER_OPTIONS: number[] = [15, 30, 60];
export const REMINDER_OPTION_LABELS: string[] = ['提前 15 分钟', '提前 30 分钟', '提前 1 小时'];
export const REPEAT_OPTIONS: RepeatType[] = ['NONE', 'DAILY', 'WEEKLY', 'MONTHLY'];
export const REPEAT_OPTION_LABELS: string[] = ['不重复', '每日', '每周', '每月'];
export const TAB_INDEX_MONTH: number = 0;
export const TAB_INDEX_WEEK: number = 1;
export const TAB_INDEX_TAG: number = 2;
export const TAB_INDEX_SETTINGS: number = 3;
export const TIMELINE_START_HOUR: number = 6;
export const TIMELINE_END_HOUR: number = 24;
export const DEFAULT_EVENT_DURATION_MS: number = 60 * 60 * 1000;
export const STORAGE_KEY_DEFAULT_REMINDER: string = 'defaultReminderMinutes';
export const STORAGE_KEY_LAST_EXPORT: string = 'lastExportJson';

export const DEFAULT_TAGS: TagModel[] = [
  { id: 1, name: '工作', color: '#4A90D9', sortOrder: 1, isPreset: true },
  { id: 2, name: '学习', color: '#43C463', sortOrder: 2, isPreset: true },
  { id: 3, name: '生活', color: '#F5A623', sortOrder: 3, isPreset: true },
  { id: 4, name: '健康', color: '#8B5CF6', sortOrder: 4, isPreset: true },
  { id: 5, name: '其他', color: '#D64545', sortOrder: 5, isPreset: true }
];

export function getReminderLabel(minutes: number): string {
  if (minutes === 60) {
    return '提前 1 小时';
  }
  if (minutes > 60) {
    return `提前 ${minutes / 60} 小时`;
  }
  return `提前 ${minutes} 分钟`;
}

export function getRepeatLabel(type: RepeatType): string {
  switch (type) {
    case 'DAILY':
      return '每日';
    case 'WEEKLY':
      return '每周';
    case 'MONTHLY':
      return '每月';
    default:
      return '不重复';
  }
}
