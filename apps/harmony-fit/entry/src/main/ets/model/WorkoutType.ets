export enum WorkoutType {
  WALK = 'walk',
  RUN = 'run',
  CYCLING = 'cycling',
  SWIM = 'swim',
  GYM = 'gym',
  OTHER = 'other'
}

export interface WorkoutTypeInfo {
  type: WorkoutType
  name: string
  icon: string
  color: string
}

export const WORKOUT_TYPE_MAP: Map<WorkoutType, WorkoutTypeInfo> = new Map([
  [WorkoutType.WALK, { type: WorkoutType.WALK, name: '步行', icon: '🚶', color: '#4CAF50' }],
  [WorkoutType.RUN, { type: WorkoutType.RUN, name: '跑步', icon: '🏃', color: '#FF5722' }],
  [WorkoutType.CYCLING, { type: WorkoutType.CYCLING, name: '骑行', icon: '🚴', color: '#2196F3' }],
  [WorkoutType.SWIM, { type: WorkoutType.SWIM, name: '游泳', icon: '🏊', color: '#00BCD4' }],
  [WorkoutType.GYM, { type: WorkoutType.GYM, name: '健身', icon: '💪', color: '#FF9800' }],
  [WorkoutType.OTHER, { type: WorkoutType.OTHER, name: '其他', icon: '🏅', color: '#9C27B0' }],
])
