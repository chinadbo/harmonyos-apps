import { addDays, todayString } from '../utils/Formatters';

export interface ReminderItem {
  id: number;
  vehicleId: number;
  reminderId: number;
  type: string;
  title: string;
  content: string;
  triggerDate: string;
  targetMileage: number;
  isActive: boolean;
  createdAt: string;
}

export function createEmptyReminder(vehicleId: number = 0): ReminderItem {
  const today: string = todayString();
  return {
    id: 0,
    vehicleId,
    reminderId: 0,
    type: '保养',
    title: '',
    content: '',
    triggerDate: addDays(today, 30),
    targetMileage: 0,
    isActive: true,
    createdAt: today
  };
}

export function createDemoReminders(): ReminderItem[] {
  const today: string = todayString();
  return [
    {
      id: 1,
      vehicleId: 1,
      reminderId: 9001,
      type: '保养',
      title: 'M7 下次保养',
      content: '请在到期前预约机油保养。',
      triggerDate: addDays(today, 30),
      targetMileage: 22000,
      isActive: true,
      createdAt: today
    },
    {
      id: 2,
      vehicleId: 2,
      reminderId: 9002,
      type: '保险',
      title: '唐 DM-i 保险续费',
      content: '保险即将到期，请提前续保。',
      triggerDate: addDays(today, 60),
      targetMileage: 0,
      isActive: true,
      createdAt: today
    }
  ];
}
