import { ChartPoint } from '../model/GoalModel';

export class DateUtils {
  static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  static today(): string {
    return this.formatDate(new Date());
  }

  static now(): number {
    return Date.now();
  }

  static formatDate(date: Date): string {
    return `${date.getFullYear()}-${this.pad(date.getMonth() + 1)}-${this.pad(date.getDate())}`;
  }

  static parseDate(value: string): Date {
    if (!value || value.length === 0) {
      return new Date();
    }
    let parts: string[] = value.split('-');
    if (parts.length !== 3) {
      return new Date(value);
    }
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  }

  static formatMonthDay(value: string): string {
    let date: Date = this.parseDate(value);
    return `${this.pad(date.getMonth() + 1)}.${this.pad(date.getDate())}`;
  }

  static formatChineseDate(value: string): string {
    let date: Date = this.parseDate(value);
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
  }

  static isOverdue(value: string): boolean {
    let deadline: Date = this.parseDate(value);
    let today: Date = this.parseDate(this.today());
    return deadline.getTime() < today.getTime();
  }

  static daysRemaining(value: string): number {
    let deadline: Date = this.parseDate(value);
    let today: Date = this.parseDate(this.today());
    let difference: number = deadline.getTime() - today.getTime();
    return Math.ceil(difference / (24 * 60 * 60 * 1000));
  }

  static isSameDay(first: string, second: string): boolean {
    return this.normalizeDate(first) === this.normalizeDate(second);
  }

  static normalizeDate(value: string): string {
    return this.formatDate(this.parseDate(value));
  }

  static sortDateStrings(values: string[]): string[] {
    return values.sort((left: string, right: string) => this.parseDate(left).getTime() - this.parseDate(right).getTime());
  }

  static sortChartPoints(points: ChartPoint[]): ChartPoint[] {
    return points.sort((left: ChartPoint, right: ChartPoint) => {
      return this.parseDate(left.date).getTime() - this.parseDate(right.date).getTime();
    });
  }

  static buildContinuousChart(points: ChartPoint[]): ChartPoint[] {
    if (points.length === 0) {
      return [];
    }
    let sorted: ChartPoint[] = this.sortChartPoints(points.slice());
    let startDate: Date = this.parseDate(sorted[0].date);
    let endDate: Date = this.parseDate(sorted[sorted.length - 1].date);
    let valueMap: Map<string, number> = new Map<string, number>();
    sorted.forEach((point: ChartPoint) => {
      valueMap.set(this.normalizeDate(point.date), point.value);
    });

    let result: ChartPoint[] = [];
    let currentValue: number = sorted[0].value;
    let cursor: Date = new Date(startDate.getTime());
    while (cursor.getTime() <= endDate.getTime()) {
      let key: string = this.formatDate(cursor);
      if (valueMap.has(key)) {
        currentValue = valueMap.get(key) as number;
      }
      result.push({
        label: this.formatMonthDay(key),
        value: currentValue,
        date: key
      });
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  static nextDate(value: string, offsetDays: number): string {
    let date: Date = this.parseDate(value);
    date.setDate(date.getDate() + offsetDays);
    return this.formatDate(date);
  }
}
