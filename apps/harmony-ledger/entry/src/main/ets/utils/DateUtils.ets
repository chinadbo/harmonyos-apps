export class DateUtils {
  static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  static toDateString(date: Date): string {
    return `${date.getFullYear()}-${this.pad(date.getMonth() + 1)}-${this.pad(date.getDate())}`;
  }

  static currentDateString(): string {
    return this.toDateString(new Date());
  }

  static currentMonthKey(): string {
    const now: Date = new Date();
    return `${now.getFullYear()}-${this.pad(now.getMonth() + 1)}`;
  }

  static displayDate(date: string): string {
    const parts: string[] = date.split('-');
    if (parts.length !== 3) {
      return date;
    }
    return `${parts[1]}月${parts[2]}日`;
  }

  static displayMonth(month: string): string {
    const parts: string[] = month.split('-');
    if (parts.length !== 2) {
      return month;
    }
    return `${parts[0]}年${parts[1]}月`;
  }

  static monthOf(date: string): string {
    return date.slice(0, 7);
  }

  static isSameMonth(date: string, month: string): boolean {
    return this.monthOf(date) === month;
  }

  static addDays(date: Date, days: number): Date {
    const next: Date = new Date(date.getTime());
    next.setDate(next.getDate() + days);
    return next;
  }

  static recentDates(days: number): string[] {
    const dates: string[] = [];
    for (let index: number = days - 1; index >= 0; index--) {
      dates.push(this.toDateString(this.addDays(new Date(), -index)));
    }
    return dates;
  }

  static compactDateString(date: string): string {
    return date.replace(/-/g, '');
  }
}
