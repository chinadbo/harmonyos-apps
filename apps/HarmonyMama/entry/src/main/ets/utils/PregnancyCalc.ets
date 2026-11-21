export interface PregnancyWeek {
  week: number;
  day: number;
  totalDays: number;
}

const DAY_MS: number = 24 * 60 * 60 * 1000;
const GESTATION_DAYS: number = 280;

function pad2(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

export function parseDate(dateStr: string): Date {
  const parts: string[] = dateStr.split('-');
  const year: number = parseInt(parts[0], 10);
  const month: number = parseInt(parts[1], 10);
  const day: number = parseInt(parts[2], 10);
  return new Date(year, month - 1, day);
}

export function formatDate(date: Date): string {
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;
}

export function todayStr(): string {
  return formatDate(new Date());
}

export function addDays(dateStr: string, days: number): string {
  const date: Date = parseDate(dateStr);
  date.setDate(date.getDate() + days);
  return formatDate(date);
}

function utcDayNumber(dateStr: string): number {
  const parts: string[] = dateStr.split('-');
  const year: number = parseInt(parts[0], 10);
  const month: number = parseInt(parts[1], 10) - 1;
  const day: number = parseInt(parts[2], 10);
  return Math.floor(Date.UTC(year, month, day) / DAY_MS);
}

export function diffDays(fromDate: string, toDate: string): number {
  return utcDayNumber(toDate) - utcDayNumber(fromDate);
}

export function calcDueDateFromLmp(lmp: string): string {
  return addDays(lmp, GESTATION_DAYS);
}

export function calcDueDateDirect(due: string): string {
  return formatDate(parseDate(due));
}

export function getPregnancyWeek(dueDate: string, today: string): PregnancyWeek {
  const remainDays: number = diffDays(today, dueDate);
  let totalDays: number = GESTATION_DAYS - remainDays;
  if (totalDays < 0) {
    totalDays = 0;
  }
  const result: PregnancyWeek = {
    week: Math.floor(totalDays / 7),
    day: totalDays % 7,
    totalDays: totalDays
  };
  return result;
}

export function getStage(week: number): string {
  if (week < 14) {
    return '孕早期';
  }
  if (week < 28) {
    return '孕中期';
  }
  return '孕晚期';
}

export function daysUntil(dueDate: string, today?: string): number {
  const base: string = today === undefined ? todayStr() : today;
  return diffDays(base, dueDate);
}

export function formatDateCN(dateStr: string): string {
  const parts: string[] = dateStr.split('-');
  const year: number = parseInt(parts[0], 10);
  const month: number = parseInt(parts[1], 10);
  const day: number = parseInt(parts[2], 10);
  return `${year}年${month}月${day}日`;
}

export function formatMonthDay(dateStr: string): string {
  const parts: string[] = dateStr.split('-');
  const month: number = parseInt(parts[1], 10);
  const day: number = parseInt(parts[2], 10);
  return `${month}月${day}日`;
}

export function getWeekdayCN(dateStr: string): string {
  const weekdays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  return weekdays[parseDate(dateStr).getDay()];
}

export function formatWeekDay(week: number, day: number): string {
  return `孕${week}周${day}天`;
}

export function formatDurationMin(minutes: number): string {
  const safe: number = minutes < 0 ? 0 : Math.floor(minutes);
  const hours: number = Math.floor(safe / 60);
  const mins: number = safe % 60;
  if (hours > 0) {
    return `${hours}小时${mins}分钟`;
  }
  return `${mins}分钟`;
}

export function formatTimer(totalSeconds: number): string {
  const safe: number = totalSeconds < 0 ? 0 : Math.floor(totalSeconds);
  return `${pad2(Math.floor(safe / 60))}:${pad2(safe % 60)}`;
}
