export function ymdString(year: number, month: number, day: number): string {
  const mm: string = month < 10 ? '0' + month : `${month}`;
  const dd: string = day < 10 ? '0' + day : `${day}`;
  return `${year}-${mm}-${dd}`;
}

export function formatYMD(ms: number): string {
  const d: Date = new Date(ms);
  return ymdString(d.getFullYear(), d.getMonth() + 1, d.getDate());
}

export function todayYMD(): string {
  return formatYMD(Date.now());
}

export function daysBeforeYMD(n: number): string {
  return formatYMD(Date.now() - n * 86400000);
}

export function dayDiff(from: string, to: string): number {
  const a: number = new Date(`${from}T00:00:00`).getTime();
  const b: number = new Date(`${to}T00:00:00`).getTime();
  return Math.round((b - a) / 86400000);
}

export function monthStartWeekday(ms: number): number {
  const d: Date = new Date(ms);
  return new Date(d.getFullYear(), d.getMonth(), 1).getDay();
}

export function monthDayCount(ms: number): number {
  const d: Date = new Date(ms);
  return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
}

export function weekdayChar(ms: number): string {
  const chars: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  return chars[new Date(ms).getDay()];
}
