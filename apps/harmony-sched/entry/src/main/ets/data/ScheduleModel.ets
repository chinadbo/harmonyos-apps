export interface ScheduleProfile {
  id: number;
  name: string;
  termName: string;
  startDate: string;
  weeks: number;
  isActive: boolean;
  createdAt: number;
  updatedAt: number;
}

export interface ScheduleDraft {
  id?: number;
  name: string;
  termName: string;
  startDate: string;
  weeks: number;
  isActive: boolean;
}

export const DEFAULT_SCHEDULE: ScheduleDraft = {
  name: '我的课表',
  termName: '2026 春季学期',
  startDate: '2026-02-24',
  weeks: 20,
  isActive: true
};
