import notificationManager from '@ohos.notificationManager'
import common from '@ohos.app.ability.common'
import { AppConstants, CUSTOM_WORKOUT_PLAN_ID, DEFAULT_CUSTOM_WORKOUT_PLAN, DEFAULT_WORKOUT_PLANS, PrecisionMode, ThemeMode, TimerStatus, WorkoutPlan } from '../common/constants'
import { formatStopwatchTime, getCurrentWorkoutProgress, parseWorkoutPlan } from '../common/utils'
import { dataStore } from '../model/DataStore'
import { sessionModel } from '../model/SessionModel'
import { TimerServiceModel } from '../model/TimerServiceModel'

export class TimerService {
  private static instance: TimerService = new TimerService()
  private timerModel: TimerServiceModel = new TimerServiceModel()
  private context?: common.UIAbilityContext

  private constructor() {
    this.timerModel.setTickListener((elapsed: number) => {
      this.handleTick(elapsed)
    })
  }

  static getInstance(): TimerService {
    return TimerService.instance
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  async initializeDefaults(): Promise<void> {
    const settingKeys = [
      AppConstants.SETTING_SOUND_ENABLED,
      AppConstants.SETTING_VIBRATION_ENABLED,
      AppConstants.SETTING_THEME,
      AppConstants.SETTING_PRECISION,
      AppConstants.SETTING_SELECTED_WORKOUT_PLAN,
      AppConstants.SETTING_CUSTOM_WORKOUT_PLAN,
      AppConstants.SETTING_TIMER_STATUS,
      AppConstants.SETTING_SESSION_ID,
      AppConstants.SETTING_SESSION_NAME,
      AppConstants.SETTING_START_TIMESTAMP,
      AppConstants.SETTING_SEGMENT_START_TIMESTAMP,
      AppConstants.SETTING_ACCUMULATED_MS
    ]
    const settings = await dataStore.getSettings(settingKeys)
    const soundEnabled = settings[AppConstants.SETTING_SOUND_ENABLED] || String(AppConstants.DEFAULT_SOUND_ENABLED)
    const vibrationEnabled = settings[AppConstants.SETTING_VIBRATION_ENABLED] || String(AppConstants.DEFAULT_VIBRATION_ENABLED)
    const theme = settings[AppConstants.SETTING_THEME] || AppConstants.DEFAULT_THEME
    const precision = settings[AppConstants.SETTING_PRECISION] || AppConstants.DEFAULT_PRECISION
    const selectedWorkoutPlan = settings[AppConstants.SETTING_SELECTED_WORKOUT_PLAN] || DEFAULT_WORKOUT_PLANS[0].id
    const customWorkoutPlan = settings[AppConstants.SETTING_CUSTOM_WORKOUT_PLAN] || JSON.stringify(DEFAULT_CUSTOM_WORKOUT_PLAN)
    const status = settings[AppConstants.SETTING_TIMER_STATUS] || TimerStatus.IDLE
    const sessionId = Number(settings[AppConstants.SETTING_SESSION_ID] || '0')
    const sessionName = settings[AppConstants.SETTING_SESSION_NAME] || ''
    const startTimestamp = Number(settings[AppConstants.SETTING_START_TIMESTAMP] || '0')
    const segmentStartTimestamp = Number(settings[AppConstants.SETTING_SEGMENT_START_TIMESTAMP] || '0')
    const accumulatedMilliseconds = Number(settings[AppConstants.SETTING_ACCUMULATED_MS] || '0')

    AppStorage.SetOrCreate(AppConstants.STORAGE_SOUND_ENABLED, soundEnabled === 'true')
    AppStorage.SetOrCreate(AppConstants.STORAGE_VIBRATION_ENABLED, vibrationEnabled === 'true')
    AppStorage.SetOrCreate(AppConstants.STORAGE_THEME, theme as ThemeMode)
    AppStorage.SetOrCreate(AppConstants.STORAGE_PRECISION, precision as PrecisionMode)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SELECTED_WORKOUT_PLAN, selectedWorkoutPlan)
    AppStorage.SetOrCreate(AppConstants.STORAGE_CUSTOM_WORKOUT_PLAN, customWorkoutPlan)
    AppStorage.SetOrCreate(AppConstants.STORAGE_TIMER_STATUS, status as TimerStatus)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, sessionId)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, sessionName)
    AppStorage.SetOrCreate(AppConstants.STORAGE_START_TS, startTimestamp)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SEGMENT_START_TS, segmentStartTimestamp)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACCUMULATED_MS, accumulatedMilliseconds)
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAST_NOTIFICATION_TS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_INDEX, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_PROGRESS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_TOTAL, AppConstants.MINUTE_PROGRESS_MS)
    this.timerModel.configure(precision as PrecisionMode)
  }

  async restore(): Promise<void> {
    const restored = await sessionModel.restoreSession()
    const status = AppStorage.Get(AppConstants.STORAGE_TIMER_STATUS) as TimerStatus
    const startTimestamp = Number(AppStorage.Get(AppConstants.STORAGE_START_TS) ?? 0)
    const segmentStartTimestamp = Number(AppStorage.Get(AppConstants.STORAGE_SEGMENT_START_TS) ?? 0)
    const accumulatedMilliseconds = Number(AppStorage.Get(AppConstants.STORAGE_ACCUMULATED_MS) ?? 0)
    this.timerModel.restore(startTimestamp, segmentStartTimestamp, accumulatedMilliseconds, status)
    const elapsed = this.timerModel.getCurrentElapsed()
    AppStorage.SetOrCreate(AppConstants.STORAGE_ELAPSED_MS, elapsed)
    this.updateWorkoutProgress(elapsed)
    if (status === TimerStatus.RUNNING && restored.session !== null) {
      await this.publishNotification('Stopwatch running', formatStopwatchTime(elapsed), true)
    }
  }

  async startOrResume(): Promise<void> {
    const status = AppStorage.Get(AppConstants.STORAGE_TIMER_STATUS) as TimerStatus
    const precision = AppStorage.Get(AppConstants.STORAGE_PRECISION) as PrecisionMode
    this.timerModel.configure(precision)
    await sessionModel.ensureSession()
    if (status === TimerStatus.PAUSED) {
      const startTimestamp = Number(AppStorage.Get(AppConstants.STORAGE_START_TS) ?? Date.now())
      const accumulatedMilliseconds = Number(AppStorage.Get(AppConstants.STORAGE_ACCUMULATED_MS) ?? 0)
      this.timerModel.start(startTimestamp > 0 ? startTimestamp : Date.now(), accumulatedMilliseconds)
    } else {
      const now = Date.now()
      this.timerModel.start(now, 0)
      AppStorage.SetOrCreate(AppConstants.STORAGE_START_TS, now)
      AppStorage.SetOrCreate(AppConstants.STORAGE_ACCUMULATED_MS, 0)
    }
    await this.persistRuntimeState()
    await this.publishNotification('Stopwatch running', formatStopwatchTime(this.timerModel.getCurrentElapsed()), true)
  }

  async pause(): Promise<void> {
    const elapsed = this.timerModel.pause()
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACCUMULATED_MS, elapsed)
    await sessionModel.syncActiveSession(elapsed)
    await this.persistRuntimeState()
    await this.publishNotification('Stopwatch paused', formatStopwatchTime(elapsed), true)
  }

  async reset(): Promise<void> {
    const elapsed = this.timerModel.getCurrentElapsed()
    if (elapsed > 0) {
      await sessionModel.finalizeSession(elapsed)
    }
    this.timerModel.reset()
    await sessionModel.resetSession(elapsed <= 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_TIMER_STATUS, TimerStatus.IDLE)
    this.updateWorkoutProgress(0)
    await this.persistRuntimeState()
    await this.cancelNotification()
  }

  async recordLap(): Promise<void> {
    const elapsed = this.timerModel.getCurrentElapsed()
    if (elapsed <= 0) {
      return
    }
    await sessionModel.recordLap(elapsed)
    await sessionModel.syncActiveSession(elapsed)
    await this.persistRuntimeState()
  }

  private handleTick(elapsed: number): void {
    const status = AppStorage.Get(AppConstants.STORAGE_TIMER_STATUS) as TimerStatus
    this.updateWorkoutProgress(elapsed)
    if (status === TimerStatus.RUNNING) {
      this.maybeUpdateNotification(elapsed)
    }
  }

  async updateSetting(key: string, value: string): Promise<void> {
    await dataStore.upsertSetting(key, value)
    if (key === AppConstants.SETTING_PRECISION) {
      this.timerModel.configure(value as PrecisionMode)
    }
    if (key === AppConstants.SETTING_SELECTED_WORKOUT_PLAN || key === AppConstants.SETTING_CUSTOM_WORKOUT_PLAN) {
      this.updateWorkoutProgress(this.timerModel.getCurrentElapsed())
    }
  }

  getSelectedWorkoutPlan(): WorkoutPlan {
    const selectedId = String(AppStorage.Get(AppConstants.STORAGE_SELECTED_WORKOUT_PLAN) ?? DEFAULT_WORKOUT_PLANS[0].id)
    const customPlanJson = String(AppStorage.Get(AppConstants.STORAGE_CUSTOM_WORKOUT_PLAN) ?? JSON.stringify(DEFAULT_CUSTOM_WORKOUT_PLAN))
    const customPlan = parseWorkoutPlan(customPlanJson)
    if (selectedId === CUSTOM_WORKOUT_PLAN_ID) {
      return customPlan
    }
    for (let index = 0; index < DEFAULT_WORKOUT_PLANS.length; index++) {
      if (DEFAULT_WORKOUT_PLANS[index].id === selectedId) {
        return DEFAULT_WORKOUT_PLANS[index]
      }
    }
    return DEFAULT_WORKOUT_PLANS[0]
  }

  destroy(): void {
    this.timerModel.destroy()
    this.cancelNotification()
  }

  private async persistRuntimeState(): Promise<void> {
    await dataStore.upsertSetting(AppConstants.SETTING_TIMER_STATUS, String(AppStorage.Get(AppConstants.STORAGE_TIMER_STATUS) ?? TimerStatus.IDLE))
    await dataStore.upsertSetting(AppConstants.SETTING_SESSION_ID, String(AppStorage.Get(AppConstants.STORAGE_SESSION_ID) ?? 0))
    await dataStore.upsertSetting(AppConstants.SETTING_SESSION_NAME, String(AppStorage.Get(AppConstants.STORAGE_SESSION_NAME) ?? ''))
    await dataStore.upsertSetting(AppConstants.SETTING_START_TIMESTAMP, String(AppStorage.Get(AppConstants.STORAGE_START_TS) ?? 0))
    await dataStore.upsertSetting(AppConstants.SETTING_SEGMENT_START_TIMESTAMP, String(AppStorage.Get(AppConstants.STORAGE_SEGMENT_START_TS) ?? 0))
    await dataStore.upsertSetting(AppConstants.SETTING_ACCUMULATED_MS, String(AppStorage.Get(AppConstants.STORAGE_ACCUMULATED_MS) ?? 0))
  }

  private updateWorkoutProgress(elapsed: number): void {
    const progressState = getCurrentWorkoutProgress(elapsed, this.getSelectedWorkoutPlan())
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_INDEX, progressState.activeIndex)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_PROGRESS, progressState.progress)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACTIVE_INTERVAL_TOTAL, progressState.activeTotal)
  }

  private async maybeUpdateNotification(elapsed: number): Promise<void> {
    const now = Date.now()
    const lastUpdate = Number(AppStorage.Get(AppConstants.STORAGE_LAST_NOTIFICATION_TS) ?? 0)
    if (now - lastUpdate < AppConstants.NOTIFICATION_UPDATE_INTERVAL_MS) {
      return
    }
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAST_NOTIFICATION_TS, now)
    await this.publishNotification('Stopwatch running', formatStopwatchTime(elapsed), true)
  }

  private async publishNotification(title: string, text: string, ongoing: boolean): Promise<void> {
    if (!this.context) {
      return
    }
    try {
      const request: notificationManager.NotificationRequest = {
        id: AppConstants.NOTIFICATION_ID,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title,
            text,
            additionalText: AppConstants.APP_NAME
          }
        },
        isOngoing: ongoing,
        slotType: notificationManager.SlotType.SERVICE_INFORMATION
      }
      await notificationManager.publish(request)
    } catch (error) {
      console.error(`publishNotification failed: ${JSON.stringify(error)}`)
    }
  }

  private async cancelNotification(): Promise<void> {
    try {
      await notificationManager.cancel(AppConstants.NOTIFICATION_ID)
    } catch (error) {
      console.error(`cancelNotification failed: ${JSON.stringify(error)}`)
    }
  }
}

export const timerService: TimerService = TimerService.getInstance()
