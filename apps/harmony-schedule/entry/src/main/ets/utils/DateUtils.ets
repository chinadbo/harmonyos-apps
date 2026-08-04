import { EventModel } from '../models/EventModel';
import { TIMELINE_END_HOUR, TIMELINE_START_HOUR } from './Constants';

// 日期工具，封装月周日视图所需的日期计算逻辑
export interface CalendarDay {
  date: Date;
  dayOfMonth: number;
  dateKey: string;
  isCurrentMonth: boolean;
  isToday: boolean;
}

export interface HourSlot {
  hour: number;
  label: string;
  timestamp: number;
}

export function createDateKey(date: Date): string {
  const year: number = date.getFullYear();
  const month: number = date.getMonth() + 1;
  const day: number = date.getDate();
  return `${year}-${padNumber(month)}-${padNumber(day)}`;
}

export function formatDate(date: Date): string {
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
}

export function formatMonthTitle(date: Date): string {
  return `${date.getFullYear()}年${date.getMonth() + 1}月`;
}

export function formatTime(timestamp: number): string {
  const date: Date = new Date(timestamp);
  return `${padNumber(date.getHours())}:${padNumber(date.getMinutes())}`;
}

export function formatDateTime(timestamp: number): string {
  const date: Date = new Date(timestamp);
  return `${formatDate(date)} ${formatTime(timestamp)}`;
}

export function getMonthDays(currentMonth: Date): CalendarDay[] {
  const firstDay: Date = new Date(currentMonth.getFullYear(), currentMonth.getMonth(), 1);
  const startDay: Date = new Date(firstDay.getTime());
  startDay.setDate(firstDay.getDate() - firstDay.getDay());
  const todayKey: string = createDateKey(new Date());
  const result: CalendarDay[] = [];
  for (let index = 0; index < 42; index++) {
    const current: Date = new Date(startDay.getTime());
    current.setDate(startDay.getDate() + index);
    result.push({
      date: current,
      dayOfMonth: current.getDate(),
      dateKey: createDateKey(current),
      isCurrentMonth: current.getMonth() === currentMonth.getMonth(),
      isToday: createDateKey(current) === todayKey
    });
  }
  return result;
}

export function getWeekDays(targetDate: Date): Date[] {
  const start: Date = getStartOfWeek(targetDate);
  const result: Date[] = [];
  for (let index = 0; index < 7; index++) {
    const current: Date = new Date(start.getTime());
    current.setDate(start.getDate() + index);
    result.push(current);
  }
  return result;
}

export function getStartOfWeek(date: Date): Date {
  const current: Date = startOfDay(date);
  const dayOfWeek: number = current.getDay();
  current.setDate(current.getDate() - dayOfWeek);
  return current;
}

export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
}

export function endOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59, 59, 999);
}

export function addDays(date: Date, value: number): Date {
  const result: Date = new Date(date.getTime());
  result.setDate(result.getDate() + value);
  return result;
}

export function addMonths(date: Date, value: number): Date {
  return new Date(date.getFullYear(), date.getMonth() + value, 1);
}

export function getHourSlots(targetDate: Date): HourSlot[] {
  const result: HourSlot[] = [];
  for (let hour = TIMELINE_START_HOUR; hour <= TIMELINE_END_HOUR; hour++) {
    const current: Date = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), hour, 0, 0, 0);
    result.push({
      hour,
      label: `${padNumber(hour)}:00`,
      timestamp: current.getTime()
    });
  }
  return result;
}

export function filterEventsForDay(events: EventModel[], targetDate: Date): EventModel[] {
  const dayStart: number = startOfDay(targetDate).getTime();
  const dayEnd: number = endOfDay(targetDate).getTime();
  return events.filter((event: EventModel) => event.startTime <= dayEnd && event.endTime >= dayStart)
    .sort((first: EventModel, second: EventModel) => first.startTime - second.startTime);
}

export function filterEventsForRange(events: EventModel[], start: Date, end: Date): EventModel[] {
  const startTime: number = start.getTime();
  const endTime: number = end.getTime();
  return events.filter((event: EventModel) => event.startTime <= endTime && event.endTime >= startTime)
    .sort((first: EventModel, second: EventModel) => first.startTime - second.startTime);
}

export function getEventCountMap(events: EventModel[]): Map<string, number> {
  const map: Map<string, number> = new Map<string, number>();
  events.forEach((event: EventModel) => {
    const key: string = createDateKey(new Date(event.startTime));
    const currentValue: number = map.get(key) ?? 0;
    map.set(key, currentValue + 1);
  });
  return map;
}

export function cloneDate(date: Date): Date {
  return new Date(date.getTime());
}

function padNumber(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}
