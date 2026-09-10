import { AppConstants, DEFAULT_CUSTOM_WORKOUT_PLAN, DEFAULT_WORKOUT_PLANS, LapRecord, PrecisionMode, WorkoutPlan } from './constants'

export interface LapStats {
  averageLap: number
  fastestLap: number
  slowestLap: number
  fastestLapNumber: number
  slowestLapNumber: number
}

export function padNumber(value: number, length: number): string {
  return value.toString().padStart(length, '0')
}

export function formatStopwatchTime(milliseconds: number): string {
  const safeMilliseconds = Math.max(0, Math.floor(milliseconds))
  const minutes = Math.floor(safeMilliseconds / 60000)
  const seconds = Math.floor((safeMilliseconds % 60000) / 1000)
  const millis = safeMilliseconds % 1000
  return `${padNumber(minutes, 2)}:${padNumber(seconds, 2)}.${padNumber(millis, 3)}`
}

export function formatDuration(milliseconds: number): string {
  const safeMilliseconds = Math.max(0, Math.floor(milliseconds))
  const totalSeconds = Math.floor(safeMilliseconds / 1000)
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60
  if (hours > 0) {
    return `${padNumber(hours, 2)}:${padNumber(minutes, 2)}:${padNumber(seconds, 2)}`
  }
  return `${padNumber(minutes, 2)}:${padNumber(seconds, 2)}`
}

export function formatSessionDate(timestamp: number): string {
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = padNumber(date.getMonth() + 1, 2)
  const day = padNumber(date.getDate(), 2)
  const hours = padNumber(date.getHours(), 2)
  const minutes = padNumber(date.getMinutes(), 2)
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

export function getLapStats(laps: LapRecord[]): LapStats {
  if (laps.length === 0) {
    return {
      averageLap: 0,
      fastestLap: 0,
      slowestLap: 0,
      fastestLapNumber: 0,
      slowestLapNumber: 0
    }
  }

  let total = 0
  let fastest = laps[0]
  let slowest = laps[0]
  for (let index = 0; index < laps.length; index++) {
    const lap = laps[index]
    total += lap.lapTime
    if (lap.lapTime < fastest.lapTime) {
      fastest = lap
    }
    if (lap.lapTime > slowest.lapTime) {
      slowest = lap
    }
  }

  return {
    averageLap: Math.floor(total / laps.length),
    fastestLap: fastest.lapTime,
    slowestLap: slowest.lapTime,
    fastestLapNumber: fastest.lapNumber,
    slowestLapNumber: slowest.lapNumber
  }
}

export function getProgressFromMinute(milliseconds: number): number {
  const progress = (Math.max(0, milliseconds) % AppConstants.MINUTE_PROGRESS_MS) / AppConstants.MINUTE_PROGRESS_MS
  return clampProgress(progress)
}

export function clampProgress(value: number): number {
  if (value < 0) {
    return 0
  }
  if (value > 1) {
    return 1
  }
  return value
}

export function precisionStep(mode: PrecisionMode): number {
  return mode === PrecisionMode.NORMAL ? 100 : 10
}

export function applyPrecision(milliseconds: number, mode: PrecisionMode): number {
  const step = precisionStep(mode)
  return Math.floor(Math.max(0, milliseconds) / step) * step
}

export function createSessionName(timestamp: number): string {
  const date = new Date(timestamp)
  const month = padNumber(date.getMonth() + 1, 2)
  const day = padNumber(date.getDate(), 2)
  const hours = padNumber(date.getHours(), 2)
  const minutes = padNumber(date.getMinutes(), 2)
  return `${AppConstants.SESSION_NAME_PREFIX} ${month}/${day} ${hours}:${minutes}`
}

export function getWorkoutPlans(customPlanJson: string): WorkoutPlan[] {
  const plans = [...DEFAULT_WORKOUT_PLANS]
  const customPlan = parseWorkoutPlan(customPlanJson)
  plans.push(customPlan)
  return plans
}

export function parseWorkoutPlan(value: string): WorkoutPlan {
  if (!value || value.trim().length === 0) {
    return DEFAULT_CUSTOM_WORKOUT_PLAN
  }
  try {
    const parsed = JSON.parse(value) as WorkoutPlan
    if (!parsed.intervals || parsed.intervals.length === 0) {
      return DEFAULT_CUSTOM_WORKOUT_PLAN
    }
    return {
      id: parsed.id || DEFAULT_CUSTOM_WORKOUT_PLAN.id,
      name: parsed.name || DEFAULT_CUSTOM_WORKOUT_PLAN.name,
      description: parsed.description || DEFAULT_CUSTOM_WORKOUT_PLAN.description,
      intervals: parsed.intervals
        .filter((interval) => Number(interval) > 0)
        .slice(0, AppConstants.MAX_CUSTOM_INTERVALS)
        .map((interval) => Number(interval))
    }
  } catch (error) {
    console.error(`parseWorkoutPlan failed: ${JSON.stringify(error)}`)
    return DEFAULT_CUSTOM_WORKOUT_PLAN
  }
}

export function serializeWorkoutPlan(plan: WorkoutPlan): string {
  return JSON.stringify(plan)
}

export function getCurrentWorkoutProgress(elapsedMs: number, workoutPlan: WorkoutPlan): { progress: number; activeIndex: number; activeTotal: number } {
  if (workoutPlan.intervals.length === 0) {
    return {
      progress: getProgressFromMinute(elapsedMs),
      activeIndex: 0,
      activeTotal: AppConstants.MINUTE_PROGRESS_MS
    }
  }
  let remaining = Math.max(0, elapsedMs)
  for (let index = 0; index < workoutPlan.intervals.length; index++) {
    const interval = workoutPlan.intervals[index]
    if (remaining <= interval) {
      return {
        progress: clampProgress(interval === 0 ? 0 : remaining / interval),
        activeIndex: index,
        activeTotal: interval
      }
    }
    remaining -= interval
  }
  const lastInterval = workoutPlan.intervals[workoutPlan.intervals.length - 1]
  return {
    progress: 1,
    activeIndex: workoutPlan.intervals.length - 1,
    activeTotal: lastInterval
  }
}
