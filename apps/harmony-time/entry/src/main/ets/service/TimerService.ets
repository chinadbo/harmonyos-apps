import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

const PREF_STORE_NAME = 'timer_prefs'
const KEY_RUNNING_PROJECT_ID = 'runningProjectId'
const KEY_TIMER_START_TIME = 'timerStartTime'
const KEY_PAUSED_DURATION = 'pausedDuration'
const KEY_RUNNING_ENTRY_ID = 'runningEntryId'

export class TimerService {
  private static instance: TimerService | null = null
  private intervalId: number = -1
  private timerStartTime: number = 0
  private pausedDuration: number = 0
  private isPaused: boolean = false
  private pauseStartTime: number = 0
  private context: common.UIAbilityContext | null = null

  private constructor() {}

  static getInstance(): TimerService {
    if (!TimerService.instance) {
      TimerService.instance = new TimerService()
    }
    return TimerService.instance
  }

  async start(projectId: number, entryId: number): Promise<void> {
    this.timerStartTime = Date.now()
    this.pausedDuration = 0
    this.isPaused = false

    AppStorage.SetOrCreate<number>('runningProjectId', projectId)
    AppStorage.SetOrCreate<number>('runningEntryId', entryId)
    AppStorage.SetOrCreate<number>('timerStartTime', this.timerStartTime)
    AppStorage.SetOrCreate<boolean>('isTimerRunning', true)
    AppStorage.SetOrCreate<number>('elapsedSeconds', 0)

    await this.saveToPreferences()
    this.startTicking()
  }

  pause(): void {
    if (this.isPaused) {
      return
    }
    this.isPaused = true
    this.pauseStartTime = Date.now()
    this.stopTicking()
  }

  resume(): void {
    if (!this.isPaused) {
      return
    }
    this.isPaused = false
    this.pausedDuration += Date.now() - this.pauseStartTime
    this.pauseStartTime = 0
    this.saveToPreferences()
    this.startTicking()
  }

  async stop(): Promise<number> {
    const elapsed = this.getElapsedSeconds()
    this.stopTicking()

    AppStorage.SetOrCreate<number>('runningProjectId', -1)
    AppStorage.SetOrCreate<number>('runningEntryId', -1)
    AppStorage.SetOrCreate<number>('timerStartTime', 0)
    AppStorage.SetOrCreate<boolean>('isTimerRunning', false)
    AppStorage.SetOrCreate<number>('elapsedSeconds', 0)

    this.timerStartTime = 0
    this.pausedDuration = 0
    this.isPaused = false
    this.pauseStartTime = 0

    await this.clearPreferences()
    return elapsed
  }

  getElapsedSeconds(): number {
    if (this.timerStartTime === 0) {
      return 0
    }
    let currentPausedDuration = this.pausedDuration
    if (this.isPaused) {
      currentPausedDuration += Date.now() - this.pauseStartTime
    }
    return Math.floor((Date.now() - this.timerStartTime - currentPausedDuration) / 1000)
  }

  async restoreFromPreferences(context: common.UIAbilityContext): Promise<void> {
    this.context = context
    try {
      const store = await preferences.getPreferences(context, PREF_STORE_NAME)
      const projectId = await store.get(KEY_RUNNING_PROJECT_ID, -1) as number
      const startTime = await store.get(KEY_TIMER_START_TIME, 0) as number
      const pausedDur = await store.get(KEY_PAUSED_DURATION, 0) as number
      const entryId = await store.get(KEY_RUNNING_ENTRY_ID, -1) as number

      if (projectId !== -1 && startTime > 0) {
        this.timerStartTime = startTime
        this.pausedDuration = pausedDur
        this.isPaused = false

        AppStorage.SetOrCreate<number>('runningProjectId', projectId)
        AppStorage.SetOrCreate<number>('runningEntryId', entryId)
        AppStorage.SetOrCreate<number>('timerStartTime', startTime)
        AppStorage.SetOrCreate<boolean>('isTimerRunning', true)
        AppStorage.SetOrCreate<number>('elapsedSeconds', this.getElapsedSeconds())

        this.startTicking()
      } else {
        AppStorage.SetOrCreate<number>('runningProjectId', -1)
        AppStorage.SetOrCreate<number>('runningEntryId', -1)
        AppStorage.SetOrCreate<number>('timerStartTime', 0)
        AppStorage.SetOrCreate<boolean>('isTimerRunning', false)
        AppStorage.SetOrCreate<number>('elapsedSeconds', 0)
      }
    } catch (err) {
      console.error('TimerService restoreFromPreferences error: ' + JSON.stringify(err))
    }
  }

  private startTicking(): void {
    this.stopTicking()
    this.intervalId = setInterval(() => {
      const elapsed = this.getElapsedSeconds()
      AppStorage.SetOrCreate<number>('elapsedSeconds', elapsed)
    }, 1000)
  }

  private stopTicking(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId)
      this.intervalId = -1
    }
  }

  private async saveToPreferences(): Promise<void> {
    if (!this.context) {
      return
    }
    try {
      const store = await preferences.getPreferences(this.context, PREF_STORE_NAME)
      const projectId = AppStorage.Get<number>('runningProjectId') ?? -1
      const entryId = AppStorage.Get<number>('runningEntryId') ?? -1
      await store.put(KEY_RUNNING_PROJECT_ID, projectId)
      await store.put(KEY_RUNNING_ENTRY_ID, entryId)
      await store.put(KEY_TIMER_START_TIME, this.timerStartTime)
      await store.put(KEY_PAUSED_DURATION, this.pausedDuration)
      await store.flush()
    } catch (err) {
      console.error('TimerService saveToPreferences error: ' + JSON.stringify(err))
    }
  }

  private async clearPreferences(): Promise<void> {
    if (!this.context) {
      return
    }
    try {
      const store = await preferences.getPreferences(this.context, PREF_STORE_NAME)
      await store.clear()
      await store.flush()
    } catch (err) {
      console.error('TimerService clearPreferences error: ' + JSON.stringify(err))
    }
  }
}
