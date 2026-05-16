export interface WorkoutRecord {
  id?: number
  type: string
  duration: number
  calories: number
  steps: number
  date: string
  startTime: number
  note: string
}

export interface DailyStats {
  date: string
  totalSteps: number
  totalCalories: number
  totalDuration: number
  recordCount: number
}
