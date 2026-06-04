export function padTwo(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

export function todayString(): string {
  return dateToString(new Date());
}

export function dateToString(date: Date): string {
  const year: number = date.getFullYear();
  const month: string = padTwo(date.getMonth() + 1);
  const day: string = padTwo(date.getDate());
  return `${year}-${month}-${day}`;
}

export function addDays(baseDate: string, days: number): string {
  const date: Date = new Date(baseDate);
  date.setDate(date.getDate() + days);
  return dateToString(date);
}

export function formatDate(value: string): string {
  return value && value.length > 0 ? value : '--';
}

export function parseInteger(text: string, fallback: number = 0): number {
  const parsed: number = Number.parseInt(text, 10);
  return Number.isNaN(parsed) ? fallback : parsed;
}

export function parseBooleanNumber(value: boolean): number {
  return value ? 1 : 0;
}

export function parseNumber(value: string, fallback: number = 0): number {
  const parsed: number = Number(value);
  return Number.isNaN(parsed) ? fallback : parsed;
}

export function formatCurrencyFromCent(value: number): string {
  return `¥${(value / 100).toFixed(2)}`;
}

export function formatMileage(value: number): string {
  return `${value} km`;
}

export function stringifyStringArray(items: string[]): string {
  return JSON.stringify(items ?? []);
}

export function parseStringArray(text: string): string[] {
  if (!text || text.length === 0) {
    return [];
  }
  try {
    const parsed: Object = JSON.parse(text);
    return Array.isArray(parsed) ? parsed as string[] : [];
  } catch (_) {
    return [];
  }
}

export function notEmptyText(value: string, fallback: string): string {
  return value && value.trim().length > 0 ? value.trim() : fallback;
}
