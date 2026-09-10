export enum TimerStatus {
  IDLE = 'IDLE',
  RUNNING = 'RUNNING',
  PAUSED = 'PAUSED'
}

export enum ThemeMode {
  LIGHT = 'light',
  DARK = 'dark'
}

export enum PrecisionMode {
  HIGH = 'high',
  NORMAL = 'normal'
}

export interface LapRecord {
  id: number
  sessionId: number
  lapNumber: number
  lapTime: number
  totalTime: number
  createdAt: number
}

export interface SessionRecord {
  id: number
  name: string
  startTime: number
  endTime: number
  duration: number
  createdAt: number
}

export interface SessionDetail extends SessionRecord {
  laps: LapRecord[]
}

export interface WorkoutPlan {
  id: string
  name: string
  description: string
  intervals: number[]
}

export class AppConstants {
  static readonly APP_NAME: string = 'HarmonyChrono'
  static readonly DB_NAME: string = 'harmonychrono.db'
  static readonly SESSION_NAME_PREFIX: string = 'Stopwatch Session'
  static readonly NOTIFICATION_ID: number = 22001
  static readonly TIMER_INTERVAL_MS: number = 10
  static readonly NOTIFICATION_UPDATE_INTERVAL_MS: number = 1000
  static readonly MINUTE_PROGRESS_MS: number = 60000
  static readonly DEFAULT_SOUND_ENABLED: boolean = true
  static readonly DEFAULT_VIBRATION_ENABLED: boolean = true
  static readonly DEFAULT_THEME: ThemeMode = ThemeMode.LIGHT
  static readonly DEFAULT_PRECISION: PrecisionMode = PrecisionMode.HIGH
  static readonly SESSIONS_TABLE: string = 'sessions'
  static readonly LAPS_TABLE: string = 'laps'
  static readonly SETTINGS_TABLE: string = 'settings'
  static readonly STORAGE_TIMER_STATUS: string = 'chrono.timerStatus'
  static readonly STORAGE_ELAPSED_MS: string = 'chrono.elapsedMs'
  static readonly STORAGE_SESSION_ID: string = 'chrono.sessionId'
  static readonly STORAGE_SESSION_NAME: string = 'chrono.sessionName'
  static readonly STORAGE_LAPS: string = 'chrono.laps'
  static readonly STORAGE_THEME: string = 'chrono.theme'
  static readonly STORAGE_SOUND_ENABLED: string = 'chrono.soundEnabled'
  static readonly STORAGE_VIBRATION_ENABLED: string = 'chrono.vibrationEnabled'
  static readonly STORAGE_PRECISION: string = 'chrono.precision'
  static readonly STORAGE_SELECTED_WORKOUT_PLAN: string = 'chrono.selectedWorkoutPlan'
  static readonly STORAGE_CUSTOM_WORKOUT_PLAN: string = 'chrono.customWorkoutPlan'
  static readonly STORAGE_SEGMENT_START_TS: string = 'chrono.segmentStartTimestamp'
  static readonly STORAGE_START_TS: string = 'chrono.startTimestamp'
  static readonly STORAGE_ACCUMULATED_MS: string = 'chrono.accumulatedMs'
  static readonly STORAGE_LAST_NOTIFICATION_TS: string = 'chrono.lastNotificationTs'
  static readonly STORAGE_HISTORY_REFRESH_TOKEN: string = 'chrono.historyRefreshToken'
  static readonly STORAGE_ACTIVE_INTERVAL_INDEX: string = 'chrono.activeIntervalIndex'
  static readonly STORAGE_ACTIVE_INTERVAL_PROGRESS: string = 'chrono.activeIntervalProgress'
  static readonly STORAGE_ACTIVE_INTERVAL_TOTAL: string = 'chrono.activeIntervalTotal'
  static readonly SETTING_SOUND_ENABLED: string = 'soundEnabled'
  static readonly SETTING_VIBRATION_ENABLED: string = 'vibrationEnabled'
  static readonly SETTING_THEME: string = 'theme'
  static readonly SETTING_PRECISION: string = 'precision'
  static readonly SETTING_SELECTED_WORKOUT_PLAN: string = 'selectedWorkoutPlan'
  static readonly SETTING_CUSTOM_WORKOUT_PLAN: string = 'customWorkoutPlan'
  static readonly SETTING_TIMER_STATUS: string = 'timerStatus'
  static readonly SETTING_SESSION_ID: string = 'sessionId'
  static readonly SETTING_SESSION_NAME: string = 'sessionName'
  static readonly SETTING_START_TIMESTAMP: string = 'startTimestamp'
  static readonly SETTING_SEGMENT_START_TIMESTAMP: string = 'segmentStartTimestamp'
  static readonly SETTING_ACCUMULATED_MS: string = 'accumulatedMs'
  static readonly START_WINDOW_BACKGROUND: string = '#FFF6F8FB'
  static readonly BRAND_COLOR: string = '#FF4F7AF7'
  static readonly RUNNING_COLOR: string = '#FF22C55E'
  static readonly PAUSED_COLOR: string = '#FFF59E0B'
  static readonly FASTEST_LAP_COLOR: string = '#FFDCFCE7'
  static readonly SLOWEST_LAP_COLOR: string = '#FFFEE2E2'
  static readonly TRACK_COLOR: string = '#FFE5E7EB'
  static readonly SURFACE_COLOR: string = '#FFFFFFFF'
  static readonly SURFACE_ALT_COLOR: string = '#FFF3F5F7'
  static readonly TEXT_PRIMARY: string = '#FF1F2937'
  static readonly TEXT_SECONDARY: string = '#FF6B7280'
  static readonly DANGER_COLOR: string = '#FFEF4444'
  static readonly MAX_CUSTOM_INTERVALS: number = 6
}

export const CUSTOM_WORKOUT_PLAN_ID: string = 'custom'

export const DEFAULT_WORKOUT_PLANS: WorkoutPlan[] = [
  {
    id: 'classic_intervals',
    name: '1 min fast / 30 s slow',
    description: 'Alternate one minute hard efforts with thirty second recovery.',
    intervals: [60000, 30000, 60000, 30000, 60000, 30000]
  },
  {
    id: 'track_400s',
    name: '400 m intervals',
    description: 'A simple track workout with hard and easy blocks.',
    intervals: [90000, 60000, 90000, 60000, 90000, 60000]
  },
  {
    id: 'tempo_ladder',
    name: 'Tempo ladder',
    description: 'Build up and down through medium tempo efforts.',
    intervals: [45000, 60000, 90000, 60000, 45000]
  }
]

export const DEFAULT_CUSTOM_WORKOUT_PLAN: WorkoutPlan = {
  id: CUSTOM_WORKOUT_PLAN_ID,
  name: 'Custom plan',
  description: 'Edit the interval durations below.',
  intervals: [30000, 30000, 60000]
}
