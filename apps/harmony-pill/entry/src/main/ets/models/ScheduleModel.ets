export type ScheduleFrequency = 'DAILY' | 'EVERY_OTHER_DAY' | 'WEEKLY'

export interface Schedule {
  id: number
  medicineId: number
  hour: number
  minute: number
  dose: string
  frequency: ScheduleFrequency
  weekDays: string
  reminderId: number
  enabled: number
}

export function createEmptySchedule(): Schedule {
  return {
    id: 0,
    medicineId: 0,
    hour: 8,
    minute: 0,
    dose: '1',
    frequency: 'DAILY',
    weekDays: '',
    reminderId: 0,
    enabled: 1
  }
}
