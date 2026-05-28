export interface SleepRecord {
  id: number;
  sleepTime: number;
  wakeTime: number;
  duration: number;
  quality: number;
  note: string;
  createdAt: number;
}

export interface UserSettings {
  targetDuration: number;
  reminderSleepHour: number;
  reminderSleepMin: number;
  reminderWakeHour: number;
  reminderWakeMin: number;
  isSleeping: boolean;
  sleepStartTime: number;
  sleepReminderId: number;
  wakeReminderId: number;
}

export function formatDuration(minutes: number): string {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m}分钟`;
  if (m === 0) return `${h}小时`;
  return `${h}h ${m}m`;
}

export function formatTime(timestamp: number): string {
  const d = new Date(timestamp);
  const hh = d.getHours().toString().padStart(2, '0');
  const mm = d.getMinutes().toString().padStart(2, '0');
  return `${hh}:${mm}`;
}

export function formatDate(timestamp: number): string {
  const d = new Date(timestamp);
  const month = (d.getMonth() + 1).toString().padStart(2, '0');
  const day = d.getDate().toString().padStart(2, '0');
  return `${month}/${day}`;
}
