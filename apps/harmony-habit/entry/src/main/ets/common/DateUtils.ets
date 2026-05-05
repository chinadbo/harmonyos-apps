export class DateUtils {
  static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = this.pad(date.getMonth() + 1);
    const day = this.pad(date.getDate());
    return `${year}-${month}-${day}`;
  }

  static today(): string {
    return this.formatDate(new Date());
  }

  static timeNow(): string {
    const now = new Date();
    return `${this.pad(now.getHours())}:${this.pad(now.getMinutes())}`;
  }

  static parseDate(value: string): Date {
    const parts: string[] = value.split('-');
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  }

  static shiftDate(value: string, offsetDays: number): string {
    const date = this.parseDate(value);
    date.setDate(date.getDate() + offsetDays);
    return this.formatDate(date);
  }

  static recentDates(days: number, endDate: string = DateUtils.today()): string[] {
    const result: string[] = [];
    for (let index = days - 1; index >= 0; index--) {
      result.push(this.shiftDate(endDate, -index));
    }
    return result;
  }

  static weekdayIndex(dateString: string): number {
    const day = this.parseDate(dateString).getDay();
    return day === 0 ? 6 : day - 1;
  }

  static weekdayIndexToday(): number {
    return this.weekdayIndex(this.today());
  }

  static isHabitScheduled(targetDays: string, dateString: string): boolean {
    const index = this.weekdayIndex(dateString);
    if (targetDays.length !== 7) {
      return true;
    }
    return targetDays.charAt(index) === '1';
  }

  static compareDate(a: string, b: string): number {
    if (a === b) {
      return 0;
    }
    return a > b ? 1 : -1;
  }
}
