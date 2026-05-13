export interface CountdownEvent {
  id: number
  title: string
  targetDate: string
  note: string
  icon: string
  color: string
  isReminderEnabled: boolean
  reminderHour: number
  reminderMinute: number
  isRepeatYearly: boolean
  createdAt: number
  updatedAt: number
}

export interface CountdownDayInfo {
  label: string
  dayCount: number
  displayText: string
  isToday: boolean
  isPast: boolean
}

export interface CalendarDayItem {
  dateText: string
  fullDate: string
  isCurrentMonth: boolean
  isToday: boolean
  hasEvent: boolean
  eventCount: number
}

export function createDefaultEvent(): CountdownEvent {
  let now: number = Date.now();
  let date: Date = new Date(now + 24 * 60 * 60 * 1000);
  return {
    id: 0,
    title: '',
    targetDate: `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`,
    note: '',
    icon: 'heart',
    color: '#FF5B4D',
    isReminderEnabled: false,
    reminderHour: 9,
    reminderMinute: 0,
    isRepeatYearly: false,
    createdAt: now,
    updatedAt: now
  };
}

function pad(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}
