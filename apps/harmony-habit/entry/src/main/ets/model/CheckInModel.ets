export interface CheckInModel {
  id: number;
  habitId: number;
  checkDate: string;
  note: string;
  createdAt: number;
}

export function createCheckIn(habitId: number, checkDate: string, note: string = ''): CheckInModel {
  return {
    id: 0,
    habitId,
    checkDate,
    note,
    createdAt: Date.now()
  };
}
