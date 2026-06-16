import { Contact } from '../model/Contact';

export interface UpcomingBirthdayItem {
  contact: Contact;
  daysUntil: number;
  nextDate: Date;
}

export interface CalendarSection {
  month: string;
  items: UpcomingBirthdayItem[];
}

export class DateUtils {
  private static readonly DAYS_PER_MONTH: number[] = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  static normalizeBirthday(value: string): string {
    let match = value.trim().match(/^(\d{1,2})-(\d{1,2})$/);
    if (!match) {
      return value.trim();
    }
    let month = Number(match[1]);
    let day = Number(match[2]);
    return `${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
  }

  static validateBirthday(value: string): boolean {
    let normalized = this.normalizeBirthday(value);
    let match = normalized.match(/^(\d{2})-(\d{2})$/);
    if (!match) {
      return false;
    }
    let month = Number(match[1]);
    let day = Number(match[2]);
    if (month < 1 || month > 12) {
      return false;
    }
    return day >= 1 && day <= this.DAYS_PER_MONTH[month - 1];
  }

  static formatMonthDay(birthday: string): string {
    let normalized = this.normalizeBirthday(birthday);
    let [month, day] = normalized.split('-');
    return `${month}月${day}日`;
  }

  static getNextBirthdayDate(birthday: string, today: Date = new Date()): Date {
    let normalized = this.normalizeBirthday(birthday);
    let [monthText, dayText] = normalized.split('-');
    let month = Number(monthText) - 1;
    let day = Number(dayText);
    let base = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    let target = new Date(base.getFullYear(), month, day);
    if (target.getTime() < base.getTime()) {
      target = new Date(base.getFullYear() + 1, month, day);
    }
    return target;
  }

  static getDaysUntilBirthday(birthday: string, today: Date = new Date()): number {
    let base = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
    let target = this.getNextBirthdayDate(birthday, today).getTime();
    return Math.floor((target - base) / (24 * 60 * 60 * 1000));
  }

  static getReminderDate(birthday: string, daysBefore: number, today: Date = new Date()): Date {
    let nextBirthday = this.getNextBirthdayDate(birthday, today);
    let reminderDate = new Date(nextBirthday.getTime());
    reminderDate.setDate(reminderDate.getDate() - daysBefore);
    if (reminderDate.getTime() < new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime()) {
      let nextYearBase = new Date(today.getFullYear() + 1, today.getMonth(), today.getDate());
      let nextBirthdayYear = this.getNextBirthdayDate(birthday, nextYearBase);
      reminderDate = new Date(nextBirthdayYear.getTime());
      reminderDate.setDate(reminderDate.getDate() - daysBefore);
    }
    reminderDate.setHours(9, 0, 0, 0);
    return reminderDate;
  }

  static formatCountdown(days: number): string {
    if (days <= 0) {
      return '今天';
    }
    if (days === 1) {
      return '明天';
    }
    return `${days}天后`;
  }

  static sortContactsByUpcoming(contacts: Contact[]): UpcomingBirthdayItem[] {
    return contacts
      .map((contact: Contact) => {
        return {
          contact,
          daysUntil: this.getDaysUntilBirthday(contact.birthday),
          nextDate: this.getNextBirthdayDate(contact.birthday)
        } as UpcomingBirthdayItem;
      })
      .sort((left: UpcomingBirthdayItem, right: UpcomingBirthdayItem) => left.daysUntil - right.daysUntil);
  }

  static buildCalendarSections(contacts: Contact[]): CalendarSection[] {
    let upcoming = this.sortContactsByUpcoming(contacts);
    let sections: Map<string, UpcomingBirthdayItem[]> = new Map();
    upcoming.forEach((item: UpcomingBirthdayItem) => {
      let key = `${item.nextDate.getMonth() + 1}月`;
      if (!sections.has(key)) {
        sections.set(key, []);
      }
      sections.get(key)?.push(item);
    });
    let result: CalendarSection[] = [];
    sections.forEach((items: UpcomingBirthdayItem[], month: string) => {
      result.push({ month, items });
    });
    return result;
  }

  static buildReminderLabel(days: number[]): string {
    return days.slice().sort((a: number, b: number) => a - b).map((day: number) => `${day}天`).join(' / ');
  }
}
