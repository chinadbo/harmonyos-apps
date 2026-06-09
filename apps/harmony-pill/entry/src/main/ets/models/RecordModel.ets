export type RecordStatus = 0 | 1 | 2

export interface RecordItem {
  id: number
  medicineId: number
  scheduleId: number
  date: string
  time: string
  dose: string
  status: RecordStatus
}

export function createRecordItem(): RecordItem {
  return {
    id: 0,
    medicineId: 0,
    scheduleId: 0,
    date: '',
    time: '',
    dose: '',
    status: 1
  }
}
