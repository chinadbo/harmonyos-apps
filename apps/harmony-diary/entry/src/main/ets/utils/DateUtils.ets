import { CalendarDay, DiaryListItem } from '../model/DiaryModel';

function pad(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

export function todayKey(): string {
  return formatDateKey(new Date());
}

export function formatDateKey(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

export function parseDateKey(dateKey: string): Date {
  const values: number[] = dateKey.split('-').map((item: string) => Number(item));
  return new Date(values[0], values[1] - 1, values[2]);
}

export function monthTitle(year: number, month: number): string {
  return `${year}年${pad(month)}月`;
}

export function monthRange(year: number, month: number): [string, string] {
  const lastDay = new Date(year, month, 0).getDate();
  return [`${year}-${pad(month)}-01`, `${year}-${pad(month)}-${pad(lastDay)}`];
}

export function previousMonth(year: number, month: number): [number, number] {
  if (month === 1) {
    return [year - 1, 12];
  }
  return [year, month - 1];
}

export function nextMonth(year: number, month: number): [number, number] {
  if (month === 12) {
    return [year + 1, 1];
  }
  return [year, month + 1];
}

export function addDays(dateKey: string, offset: number): string {
  const date = parseDateKey(dateKey);
  date.setDate(date.getDate() + offset);
  return formatDateKey(date);
}

export function buildExcerpt(content: string, length: number = 80): string {
  const normalized = content.replace(/\s+/g, ' ').trim();
  if (normalized.length <= length) {
    return normalized;
  }
  return `${normalized.slice(0, length)}…`;
}

export function buildCalendarDays(year: number, month: number, entries: DiaryListItem[]): CalendarDay[] {
  const firstDay = new Date(year, month - 1, 1);
  const daysInMonth = new Date(year, month, 0).getDate();
  const firstWeekday = (firstDay.getDay() + 6) % 7;
  const previousMonthLastDay = new Date(year, month - 1, 0).getDate();
  const today = todayKey();
  const entryMap: Map<string, DiaryListItem> = new Map();
  entries.forEach((item: DiaryListItem) => entryMap.set(item.date, item));
  const cells: CalendarDay[] = [];

  for (let index = 0; index < firstWeekday; index++) {
    const label = previousMonthLastDay - firstWeekday + index + 1;
    const prevDate = new Date(year, month - 2, label);
    cells.push({
      key: formatDateKey(prevDate),
      label,
      inCurrentMonth: false,
      isToday: false,
      hasEntry: false
    });
  }

  for (let day = 1; day <= daysInMonth; day++) {
    const key = `${year}-${pad(month)}-${pad(day)}`;
    const diary = entryMap.get(key);
    cells.push({
      key,
      label: day,
      inCurrentMonth: true,
      isToday: key === today,
      hasEntry: diary !== undefined,
      mood: diary?.mood
    });
  }

  while (cells.length % 7 !== 0) {
    const day = cells.length - (firstWeekday + daysInMonth) + 1;
    const nextDate = new Date(year, month, day);
    cells.push({
      key: formatDateKey(nextDate),
      label: day,
      inCurrentMonth: false,
      isToday: false,
      hasEntry: false
    });
  }

  return cells;
}

export function computeStreak(dateKeys: string[]): number {
  const uniqueKeys = Array.from(new Set(dateKeys)).sort((left: string, right: string) => right.localeCompare(left));
  if (uniqueKeys.length === 0) {
    return 0;
  }

  let streak = uniqueKeys[0] === todayKey() ? 1 : 0;
  if (streak === 0 && uniqueKeys[0] === addDays(todayKey(), -1)) {
    streak = 1;
  }
  if (streak === 0) {
    return 0;
  }

  let previousKey = uniqueKeys[0];
  for (let index = 1; index < uniqueKeys.length; index++) {
    if (uniqueKeys[index] === addDays(previousKey, -1)) {
      streak += 1;
      previousKey = uniqueKeys[index];
      continue;
    }
    break;
  }
  return streak;
}
