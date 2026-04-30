export enum TimerStatus {
  IDLE = 'IDLE',
  RUNNING = 'RUNNING',
  PAUSED = 'PAUSED',
  COMPLETED = 'COMPLETED'
}

export enum SessionMode {
  FOCUS = 'FOCUS',
  SHORT_BREAK = 'SHORT_BREAK',
  LONG_BREAK = 'LONG_BREAK'
}

export enum WhiteNoiseType {
  NONE = 'none',
  RAIN = 'rain',
  FOREST = 'forest',
  CAFE = 'cafe',
  WAVES = 'waves'
}

export class AppDefaults {
  static readonly DATABASE_NAME: string = 'harmony_focus.db'
  static readonly DATABASE_VERSION: number = 1
  static readonly FOCUS_MINUTES: number = 25
  static readonly SHORT_BREAK_MINUTES: number = 5
  static readonly LONG_BREAK_MINUTES: number = 15
  static readonly LONG_BREAK_INTERVAL: number = 4
  static readonly NOTIFICATION_ID: number = 1001
  static readonly TIMER_INTERVAL_MS: number = 1000
  static readonly FOCUS_COLOR: string = '#FF6B6B'
  static readonly REST_COLOR: string = '#51CF66'
  static readonly TRACK_COLOR: string = '#E9ECEF'
  static readonly STORAGE_TIMER_STATUS: string = 'timerStatus'
  static readonly STORAGE_REMAINING_SECONDS: string = 'remainingSeconds'
  static readonly STORAGE_CURRENT_TASK_ID: string = 'currentTaskId'
  static readonly STORAGE_TODAY_POMODOROS: string = 'todayPomodoros'
  static readonly STORAGE_CURRENT_MODE: string = 'currentMode'
  static readonly STORAGE_TOTAL_SECONDS: string = 'totalSeconds'
  static readonly STORAGE_LAST_TICK_AT: string = 'lastTickAt'
  static readonly STORAGE_CURRENT_TASK_NAME: string = 'currentTaskName'
  static readonly STORAGE_NOTIFICATION_ENABLED: string = 'notificationEnabled'
}

export const FOCUS_DURATION_OPTIONS: number[] = [15, 25, 30, 45, 60]
export const SHORT_BREAK_OPTIONS: number[] = [3, 5, 10]
export const LONG_BREAK_OPTIONS: number[] = [10, 15, 20]
export const LONG_BREAK_INTERVAL_OPTIONS: number[] = [3, 4, 5]

export const TAB_TITLES: string[] = ['计时器', '任务', '统计', '设置']
export const MODE_LABELS: Record<string, string> = {
  [SessionMode.FOCUS]: '专注',
  [SessionMode.SHORT_BREAK]: '短休息',
  [SessionMode.LONG_BREAK]: '长休息'
}

export const WHITE_NOISE_LABELS: Record<string, string> = {
  [WhiteNoiseType.NONE]: '关闭',
  [WhiteNoiseType.RAIN]: '雨声',
  [WhiteNoiseType.FOREST]: '森林',
  [WhiteNoiseType.CAFE]: '咖啡馆',
  [WhiteNoiseType.WAVES]: '海浪'
}
