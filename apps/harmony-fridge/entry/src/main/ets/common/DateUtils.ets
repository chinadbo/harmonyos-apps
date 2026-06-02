import { Constants } from './Constants';

export class DateUtils {
  static today(): Date {
    return this.startOfDay(new Date());
  }

  static startOfDay(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  static toDate(dateText: string): Date {
    if (!dateText || dateText.length === 0) {
      return this.today();
    }
    const parsed = new Date(dateText);
    if (Number.isNaN(parsed.getTime())) {
      return this.today();
    }
    return this.startOfDay(parsed);
  }

  static toDateText(date: Date): string {
    const year: string = date.getFullYear().toString();
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static todayText(): string {
    return this.toDateText(this.today());
  }

  static formatDate(dateText: string): string {
    const date: Date = this.toDate(dateText);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  static daysUntil(dateText: string): number {
    const target: number = this.toDate(dateText).getTime();
    const current: number = this.today().getTime();
    return Math.floor((target - current) / (24 * 60 * 60 * 1000));
  }

  static expiryLevel(dateText: string): string {
    const days: number = this.daysUntil(dateText);
    if (days < Constants.EXPIRED_DAYS) {
      return 'expired';
    }
    if (days <= Constants.URGENT_DAYS) {
      return 'urgent';
    }
    if (days <= Constants.WARNING_DAYS) {
      return 'warning';
    }
    return 'fresh';
  }

  static expiryColor(dateText: string): string {
    const level: string = this.expiryLevel(dateText);
    if (level === 'expired') {
      return '#D9485F';
    }
    if (level === 'urgent') {
      return '#F08C2E';
    }
    if (level === 'warning') {
      return '#D9A404';
    }
    return '#37A86E';
  }

  static expiryText(dateText: string): string {
    const days: number = this.daysUntil(dateText);
    if (days < 0) {
      return `已过期 ${Math.abs(days)} 天`;
    }
    if (days === 0) {
      return '今天到期';
    }
    return `${days} 天后到期`;
  }

  static formatTimestamp(timestamp: number): string {
    if (timestamp <= 0) {
      return '--';
    }
    const date: Date = new Date(timestamp);
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${date.getDate()}`.padStart(2, '0');
    const hour: string = `${date.getHours()}`.padStart(2, '0');
    const minute: string = `${date.getMinutes()}`.padStart(2, '0');
    return `${month}-${day} ${hour}:${minute}`;
  }
}
