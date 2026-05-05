export interface HabitModel {
  id: number;
  name: string;
  icon: string;
  colorIndex: number;
  targetDays: string;
  reminderTime: string;
  reminderId: number;
  createdAt: number;
  isActive: number;
}

export function createDefaultHabit(): HabitModel {
  return {
    id: 0,
    name: '',
    icon: '✅',
    colorIndex: 0,
    targetDays: '1111111',
    reminderTime: '',
    reminderId: -1,
    createdAt: Date.now(),
    isActive: 1
  };
}
