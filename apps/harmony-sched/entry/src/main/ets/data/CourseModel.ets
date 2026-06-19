export interface Course {
  id: number;
  scheduleId: number;
  name: string;
  teacher: string;
  location: string;
  dayOfWeek: number;
  startSection: number;
  duration: number;
  startWeek: number;
  endWeek: number;
  weekType: number;
  color: string;
  reminderEnabled: boolean;
  reminderMinutes: number;
  reminderId: number;
  note: string;
  createdAt: number;
  updatedAt: number;
}

export interface CourseDraft {
  id?: number;
  scheduleId: number;
  name: string;
  teacher: string;
  location: string;
  dayOfWeek: number;
  startSection: number;
  duration: number;
  startWeek: number;
  endWeek: number;
  weekType: number;
  color: string;
  reminderEnabled: boolean;
  reminderMinutes: number;
  note: string;
}

export interface CourseBlock {
  id: number;
  title: string;
  subtitle: string;
  dayOfWeek: number;
  topPercent: number;
  heightPercent: number;
  color: string;
}

export const PRESET_COLORS: string[] = [
  '#FF4A6CF7', '#FF8B5CF6', '#FFEC4899', '#FFEF4444', '#FFF97316', '#FFEAB308',
  '#FF22C55E', '#FF14B8A6', '#FF06B6D4', '#FF3B82F6', '#FF6B7280', '#FF8B5E3C'
];
