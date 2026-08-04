// 日程数据模型，统一日程读写字段定义
export type RepeatType = 'NONE' | 'DAILY' | 'WEEKLY' | 'MONTHLY';

export interface EventModel {
  id: number;
  title: string;
  description: string;
  startTime: number;
  endTime: number;
  isAllDay: boolean;
  location: string;
  tagId: number;
  reminderTimes: number[];
  repeatType: RepeatType;
  repeatEnd: number;
  color: string;
  createdAt: number;
  updatedAt: number;
}

export function createEmptyEventModel(startTime?: number, endTime?: number): EventModel {
  const now: number = Date.now();
  const start: number = startTime ?? now;
  const end: number = endTime ?? start + 60 * 60 * 1000;
  return {
    id: 0,
    title: '',
    description: '',
    startTime: start,
    endTime: end,
    isAllDay: false,
    location: '',
    tagId: 0,
    reminderTimes: [],
    repeatType: 'NONE',
    repeatEnd: 0,
    color: '#4A90D9',
    createdAt: now,
    updatedAt: now
  };
}
