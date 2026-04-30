import { AppDefaults, SessionMode, TimerStatus } from '../common/Constants'
import { getDefaultSessionSeconds, getNextMode, getTodayDateString } from '../common/Utils'
import { AppSettings } from '../model/AppSettings'
import { PomodoroRecord } from '../model/PomodoroRecord'
import { databaseService } from './DatabaseService'
import { notifyService } from './NotifyService'

export class TimerService {
  private static instance: TimerService = new TimerService()
  private intervalId: number = -1
  private sessionStartedAt: number = 0

  private constructor() {
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.IDLE)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, getDefaultSessionSeconds(SessionMode.FOCUS))
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TOTAL_SECONDS, getDefaultSessionSeconds(SessionMode.FOCUS))
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_TASK_ID, 0)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_TASK_NAME, '未关联任务')
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TODAY_POMODOROS, 0)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_MODE, SessionMode.FOCUS)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_LAST_TICK_AT, 0)
  }

  static getInstance(): TimerService {
    return TimerService.instance
  }

  async hydrateFromSettings(settings: AppSettings): Promise<void> {
    const mode: SessionMode = AppStorage.Get(AppDefaults.STORAGE_CURRENT_MODE) as SessionMode
    const totalSeconds: number = this.resolveSeconds(mode, settings)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TOTAL_SECONDS, totalSeconds)
    if ((AppStorage.Get(AppDefaults.STORAGE_TIMER_STATUS) as TimerStatus) === TimerStatus.IDLE) {
      AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, totalSeconds)
    }
  }

  setCurrentTask(taskId: number, taskName: string): void {
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_TASK_ID, taskId)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_TASK_NAME, taskName)
  }

  getStatus(): TimerStatus {
    return AppStorage.Get(AppDefaults.STORAGE_TIMER_STATUS) as TimerStatus
  }

  getMode(): SessionMode {
    return AppStorage.Get(AppDefaults.STORAGE_CURRENT_MODE) as SessionMode
  }

  start(mode: SessionMode, settings: AppSettings): void {
    this.clearTimer()
    const totalSeconds: number = this.resolveSeconds(mode, settings)
    this.sessionStartedAt = Date.now()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_MODE, mode)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.RUNNING)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TOTAL_SECONDS, totalSeconds)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, totalSeconds)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_LAST_TICK_AT, this.sessionStartedAt)
    this.startInterval(settings)
  }

  pause(): void {
    if (this.getStatus() !== TimerStatus.RUNNING) {
      return
    }
    this.clearTimer()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.PAUSED)
  }

  resume(settings: AppSettings): void {
    if (this.getStatus() !== TimerStatus.PAUSED) {
      return
    }
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.RUNNING)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_LAST_TICK_AT, Date.now())
    this.startInterval(settings)
  }

  stop(settings: AppSettings): void {
    this.clearTimer()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.IDLE)
    const mode: SessionMode = this.getMode()
    const totalSeconds: number = this.resolveSeconds(mode, settings)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TOTAL_SECONDS, totalSeconds)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, totalSeconds)
  }

  async skip(settings: AppSettings): Promise<void> {
    this.clearTimer()
    await this.completeCurrentSession(false, settings)
  }

  private startInterval(settings: AppSettings): void {
    this.intervalId = setInterval(async () => {
      const current: number = Number(AppStorage.Get(AppDefaults.STORAGE_REMAINING_SECONDS) ?? 0)
      if (current <= 1) {
        this.clearTimer()
        AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, 0)
        await this.completeCurrentSession(true, settings)
        return
      }
      AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, current - 1)
      AppStorage.SetOrCreate(AppDefaults.STORAGE_LAST_TICK_AT, Date.now())
    }, AppDefaults.TIMER_INTERVAL_MS) as unknown as number
  }

  private async completeCurrentSession(completed: boolean, settings: AppSettings): Promise<void> {
    const mode: SessionMode = this.getMode()
    const totalSeconds: number = Number(AppStorage.Get(AppDefaults.STORAGE_TOTAL_SECONDS) ?? 0)
    const taskId: number = Number(AppStorage.Get(AppDefaults.STORAGE_CURRENT_TASK_ID) ?? 0)
    const todayPomodoros: number = Number(AppStorage.Get(AppDefaults.STORAGE_TODAY_POMODOROS) ?? 0)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, completed ? TimerStatus.COMPLETED : TimerStatus.IDLE)
    if (completed && mode === SessionMode.FOCUS) {
      AppStorage.SetOrCreate(AppDefaults.STORAGE_TODAY_POMODOROS, todayPomodoros + 1)
      await databaseService.addRecord(new PomodoroRecord(
        0,
        taskId,
        mode,
        totalSeconds,
        this.sessionStartedAt,
        Date.now(),
        true,
        getTodayDateString()
      ))
      if (taskId > 0) {
        await databaseService.incrementTaskPomodoro(taskId)
      }
      await notifyService.publishTimerFinished('专注完成', '本轮专注已结束，可以休息一下。')
    } else if (completed) {
      await databaseService.addRecord(new PomodoroRecord(
        0,
        taskId,
        mode,
        totalSeconds,
        this.sessionStartedAt,
        Date.now(),
        true,
        getTodayDateString()
      ))
      await notifyService.publishTimerFinished('休息结束', '休息时间已结束，准备开始下一轮专注。')
    }
    const completedPomodoros: number = completed && mode === SessionMode.FOCUS ? todayPomodoros + 1 : todayPomodoros
    const nextMode: SessionMode = completed ? getNextMode(mode, completedPomodoros, settings.longBreakInterval) : SessionMode.FOCUS
    const nextSeconds: number = this.resolveSeconds(nextMode, settings)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_CURRENT_MODE, nextMode)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_TOTAL_SECONDS, nextSeconds)
    AppStorage.SetOrCreate(AppDefaults.STORAGE_REMAINING_SECONDS, nextSeconds)
    if (!completed) {
      AppStorage.SetOrCreate(AppDefaults.STORAGE_TIMER_STATUS, TimerStatus.IDLE)
    }
  }

  private resolveSeconds(mode: SessionMode, settings: AppSettings): number {
    switch (mode) {
      case SessionMode.SHORT_BREAK:
        return settings.shortBreakMinutes * 60
      case SessionMode.LONG_BREAK:
        return settings.longBreakMinutes * 60
      case SessionMode.FOCUS:
      default:
        return settings.focusMinutes * 60
    }
  }

  private clearTimer(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId)
      this.intervalId = -1
    }
  }
}

export const timerService: TimerService = TimerService.getInstance()
