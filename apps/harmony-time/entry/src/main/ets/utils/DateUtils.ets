export class DateUtils {
  static getStartOfDay(timestamp: number): number {
    const date: Date = new Date(timestamp);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }

  static getEndOfDay(timestamp: number): number {
    const date: Date = new Date(timestamp);
    date.setHours(23, 59, 59, 999);
    return date.getTime();
  }

  static getStartOfWeek(timestamp: number): number {
    const date: Date = new Date(timestamp);
    const day: number = date.getDay();
    const diff: number = day === 0 ? -6 : 1 - day;
    date.setDate(date.getDate() + diff);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }

  static getDateLabel(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return `${month}-${day}`;
  }

  static getWeekDayShort(timestamp: number): string {
    const days: string[] = ['日', '一', '二', '三', '四', '五', '六'];
    return `周${days[new Date(timestamp).getDay()]}`;
  }

  static isSameDay(left: number, right: number): boolean {
    return this.getStartOfDay(left) === this.getStartOfDay(right);
  }
}
