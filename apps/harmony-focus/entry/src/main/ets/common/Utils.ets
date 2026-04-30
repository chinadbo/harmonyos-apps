import { AppDefaults, SessionMode } from './Constants'

export function padZero(value: number): string {
  return value < 10 ? `0${value}` : `${value}`
}

export function formatSeconds(totalSeconds: number): string {
  const safeSeconds: number = Math.max(0, totalSeconds)
  const minutes: number = Math.floor(safeSeconds / 60)
  const seconds: number = safeSeconds % 60
  return `${padZero(minutes)}:${padZero(seconds)}`
}

export function getTodayDateString(date: Date = new Date()): string {
  const year: number = date.getFullYear()
  const month: string = padZero(date.getMonth() + 1)
  const day: string = padZero(date.getDate())
  return `${year}-${month}-${day}`
}

export function getNowTimestamp(date: Date = new Date()): number {
  return date.getTime()
}

export function getSessionSeconds(mode: SessionMode, focusMinutes: number, shortBreakMinutes: number, longBreakMinutes: number): number {
  switch (mode) {
    case SessionMode.SHORT_BREAK:
      return shortBreakMinutes * 60
    case SessionMode.LONG_BREAK:
      return longBreakMinutes * 60
    case SessionMode.FOCUS:
    default:
      return focusMinutes * 60
  }
}

export function getDefaultSessionSeconds(mode: SessionMode): number {
  return getSessionSeconds(
    mode,
    AppDefaults.FOCUS_MINUTES,
    AppDefaults.SHORT_BREAK_MINUTES,
    AppDefaults.LONG_BREAK_MINUTES
  )
}

export function isToday(timestamp: number): boolean {
  return getTodayDateString(new Date(timestamp)) === getTodayDateString(new Date())
}

export function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}

export function toPercent(remainingSeconds: number, totalSeconds: number): number {
  if (totalSeconds <= 0) {
    return 0
  }
  return clamp((totalSeconds - remainingSeconds) / totalSeconds, 0, 1)
}

export function getModeColor(mode: SessionMode): string {
  return mode === SessionMode.FOCUS ? AppDefaults.FOCUS_COLOR : AppDefaults.REST_COLOR
}

export function getNextMode(currentMode: SessionMode, completedFocusPomodoros: number, longBreakInterval: number): SessionMode {
  if (currentMode !== SessionMode.FOCUS) {
    return SessionMode.FOCUS
  }
  if (completedFocusPomodoros % longBreakInterval === 0) {
    return SessionMode.LONG_BREAK
  }
  return SessionMode.SHORT_BREAK
}

export function getLastNDates(days: number): string[] {
  const values: string[] = []
  for (let index = days - 1; index >= 0; index--) {
    const date: Date = new Date()
    date.setDate(date.getDate() - index)
    values.push(getTodayDateString(date))
  }
  return values
}

export function formatMinutesLabel(value: number): string {
  return `${value} 分钟`
}
