export const DB_NAME: string = 'harmonycar.db';
export const DB_VERSION: number = 1;

export const PAGE_MAIN: string = 'MainPage';
export const PAGE_CAR_LIST: string = 'CarListPage';
export const PAGE_CAR_EDIT: string = 'CarEditPage';
export const PAGE_RECORD_LIST: string = 'RecordListPage';
export const PAGE_RECORD_EDIT: string = 'RecordEditPage';
export const PAGE_STATS: string = 'StatsPage';
export const PAGE_REMINDERS: string = 'RemindersPage';

export const VEHICLE_TABLE: string = 'vehicles';
export const RECORD_TABLE: string = 'maintenance_records';
export const REMINDER_TABLE: string = 'reminders';

export const MAINTENANCE_TYPES: string[] = ['油', '轮胎', '刹车', '年检', '保险', '洗车', '其他'];
export const REMINDER_TYPES: string[] = ['保养', '保险', '年检', '轮胎', '其他'];

export const CHART_COLORS: string[] = ['#4E7BF2', '#5CC8B2', '#FFB74D', '#F77B8A', '#8D6EEC', '#4DB6E5', '#90A4AE'];

export const FORM_SMALL_NAME: string = 'HarmonyCarSmallForm';
export const FORM_LARGE_NAME: string = 'HarmonyCarLargeForm';

export const DEFAULT_DATE_TEXT: string = '2026-06-05';

export function pageTitle(routeName: string): string {
  switch (routeName) {
    case PAGE_CAR_LIST:
      return '车辆管理';
    case PAGE_CAR_EDIT:
      return '编辑车辆';
    case PAGE_RECORD_LIST:
      return '保养记录';
    case PAGE_RECORD_EDIT:
      return '编辑记录';
    case PAGE_STATS:
      return '统计分析';
    case PAGE_REMINDERS:
      return '提醒管理';
    default:
      return 'HarmonyCar';
  }
}

export function normalizeMaintenanceType(type: string): string {
  return MAINTENANCE_TYPES.includes(type) ? type : '其他';
}

export function normalizeReminderType(type: string): string {
  return REMINDER_TYPES.includes(type) ? type : '其他';
}
