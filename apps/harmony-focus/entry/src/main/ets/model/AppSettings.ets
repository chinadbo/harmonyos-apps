import { AppDefaults, WhiteNoiseType } from '../common/Constants'

export class AppSettings {
  id: number
  focusMinutes: number
  shortBreakMinutes: number
  longBreakMinutes: number
  longBreakInterval: number
  whiteNoiseType: WhiteNoiseType
  notificationEnabled: boolean

  constructor(
    id: number = 1,
    focusMinutes: number = AppDefaults.FOCUS_MINUTES,
    shortBreakMinutes: number = AppDefaults.SHORT_BREAK_MINUTES,
    longBreakMinutes: number = AppDefaults.LONG_BREAK_MINUTES,
    longBreakInterval: number = AppDefaults.LONG_BREAK_INTERVAL,
    whiteNoiseType: WhiteNoiseType = WhiteNoiseType.NONE,
    notificationEnabled: boolean = true
  ) {
    this.id = id
    this.focusMinutes = focusMinutes
    this.shortBreakMinutes = shortBreakMinutes
    this.longBreakMinutes = longBreakMinutes
    this.longBreakInterval = longBreakInterval
    this.whiteNoiseType = whiteNoiseType
    this.notificationEnabled = notificationEnabled
  }

  static fromRow(row: Record<string, Object | number | string | boolean>): AppSettings {
    return new AppSettings(
      Number(row['id'] ?? 1),
      Number(row['focus_minutes'] ?? AppDefaults.FOCUS_MINUTES),
      Number(row['short_break_minutes'] ?? AppDefaults.SHORT_BREAK_MINUTES),
      Number(row['long_break_minutes'] ?? AppDefaults.LONG_BREAK_MINUTES),
      Number(row['long_break_interval'] ?? AppDefaults.LONG_BREAK_INTERVAL),
      String(row['white_noise_type'] ?? WhiteNoiseType.NONE) as WhiteNoiseType,
      Number(row['notification_enabled'] ?? 1) === 1
    )
  }
}
