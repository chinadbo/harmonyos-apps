import { AppConstants, PrecisionMode, TimerStatus } from '../common/constants'
import { applyPrecision } from '../common/utils'

export class TimerServiceModel {
  private intervalId: number = -1
  private startTimestamp: number = 0
  private segmentStartTimestamp: number = 0
  private accumulatedMilliseconds: number = 0
  private precisionMode: PrecisionMode = PrecisionMode.HIGH
  private tickListener?: (elapsed: number) => void

  configure(precisionMode: PrecisionMode): void {
    this.precisionMode = precisionMode
  }

  setTickListener(listener: (elapsed: number) => void): void {
    this.tickListener = listener
  }

  start(startTimestamp: number, accumulatedMilliseconds: number): void {
    this.clear()
    this.startTimestamp = startTimestamp
    this.segmentStartTimestamp = Date.now()
    this.accumulatedMilliseconds = accumulatedMilliseconds
    this.publishElapsed(TimerStatus.RUNNING)
    this.intervalId = setInterval(() => {
      this.publishElapsed(TimerStatus.RUNNING)
    }, AppConstants.TIMER_INTERVAL_MS)
  }

  pause(): number {
    const elapsed = this.getCurrentElapsed()
    this.accumulatedMilliseconds = elapsed
    this.clear()
    this.publishElapsed(TimerStatus.PAUSED)
    return elapsed
  }

  restore(startTimestamp: number, segmentStartTimestamp: number, accumulatedMilliseconds: number, status: TimerStatus): void {
    this.startTimestamp = startTimestamp
    this.segmentStartTimestamp = segmentStartTimestamp
    this.accumulatedMilliseconds = accumulatedMilliseconds
    if (status === TimerStatus.RUNNING) {
      this.clear()
      this.publishElapsed(TimerStatus.RUNNING)
      this.intervalId = setInterval(() => {
        this.publishElapsed(TimerStatus.RUNNING)
      }, AppConstants.TIMER_INTERVAL_MS)
      return
    }
    this.publishElapsed(status)
  }

  reset(): void {
    this.clear()
    this.startTimestamp = 0
    this.segmentStartTimestamp = 0
    this.accumulatedMilliseconds = 0
    AppStorage.SetOrCreate(AppConstants.STORAGE_ELAPSED_MS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_START_TS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SEGMENT_START_TS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACCUMULATED_MS, 0)
  }

  getCurrentElapsed(): number {
    const status = AppStorage.Get(AppConstants.STORAGE_TIMER_STATUS) as TimerStatus
    if (status === TimerStatus.RUNNING && this.segmentStartTimestamp > 0) {
      const delta = Date.now() - this.segmentStartTimestamp
      return applyPrecision(this.accumulatedMilliseconds + delta, this.precisionMode)
    }
    return applyPrecision(this.accumulatedMilliseconds, this.precisionMode)
  }

  destroy(): void {
    this.clear()
  }

  private publishElapsed(status: TimerStatus): void {
    const elapsed = this.getCurrentElapsed()
    AppStorage.SetOrCreate(AppConstants.STORAGE_TIMER_STATUS, status)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ELAPSED_MS, elapsed)
    AppStorage.SetOrCreate(AppConstants.STORAGE_START_TS, this.startTimestamp)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SEGMENT_START_TS, this.segmentStartTimestamp)
    AppStorage.SetOrCreate(AppConstants.STORAGE_ACCUMULATED_MS, this.accumulatedMilliseconds)
    if (this.tickListener) {
      this.tickListener(elapsed)
    }
  }

  private clear(): void {
    if (this.intervalId >= 0) {
      clearInterval(this.intervalId)
      this.intervalId = -1
    }
  }
}
