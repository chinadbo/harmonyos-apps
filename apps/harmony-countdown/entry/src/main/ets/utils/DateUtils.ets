import { CalendarDayItem, CountdownDayInfo, CountdownEvent } from '../model/CountdownEvent';

export class DateUtils {
  static parseDate(dateText: string): Date {
    let parts: string[] = dateText.split('-');
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]), 0, 0, 0, 0);
  }

  static formatDate(date: Date): string {
    return `${date.getFullYear()}-${this.pad(date.getMonth() + 1)}-${this.pad(date.getDate())}`;
  }

  static formatDisplayDate(dateText: string): string {
    let date: Date = this.parseDate(dateText);
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
  }

  static calculateDayInfo(event: CountdownEvent): CountdownDayInfo {
    let now: Date = new Date();
    let today: Date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    let target: Date = this.getEffectiveTargetDate(event, today);
    let dayCount: number = Math.ceil((target.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    if (dayCount === 0) {
      return {
        label: '今天',
        dayCount: 0,
        displayText: '就是今天！',
        isToday: true,
        isPast: false
      };
    }
    if (dayCount < 0) {
      return {
        label: '已过',
        dayCount: Math.abs(dayCount),
        displayText: `已过${Math.abs(dayCount)}天`,
        isToday: false,
        isPast: true
      };
    }
    return {
      label: '还有',
      dayCount: dayCount,
      displayText: `还有${dayCount}天`,
      isToday: false,
      isPast: false
    };
  }

  static getEffectiveTargetDate(event: CountdownEvent, fromDate?: Date): Date {
    let baseDate: Date = fromDate ? new Date(fromDate.getTime()) : new Date();
    let target: Date = this.parseDate(event.targetDate);
    if (!event.isRepeatYearly) {
      return target;
    }
    let normalized: Date = new Date(baseDate.getFullYear(), target.getMonth(), target.getDate(), 0, 0, 0, 0);
    let today: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate(), 0, 0, 0, 0);
    if (normalized.getTime() < today.getTime()) {
      normalized.setFullYear(normalized.getFullYear() + 1);
    }
    return normalized;
  }

  static sortEvents(events: CountdownEvent[]): CountdownEvent[] {
    let copied: CountdownEvent[] = events.slice();
    copied.sort((left: CountdownEvent, right: CountdownEvent) => {
      let leftInfo: CountdownDayInfo = this.calculateDayInfo(left);
      let rightInfo: CountdownDayInfo = this.calculateDayInfo(right);
      if (leftInfo.isPast !== rightInfo.isPast) {
        return leftInfo.isPast ? 1 : -1;
      }
      return leftInfo.dayCount - rightInfo.dayCount;
    });
    return copied;
  }

  static buildMonthGrid(year: number, month: number, events: CountdownEvent[]): CalendarDayItem[] {
    let firstDay: Date = new Date(year, month, 1);
    let startWeekday: number = firstDay.getDay();
    let gridStart: Date = new Date(year, month, 1 - startWeekday);
    let list: CalendarDayItem[] = [];
    let todayText: string = this.formatDate(new Date());
    for (let index = 0; index < 42; index++) {
      let current: Date = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + index);
      let fullDate: string = this.formatDate(current);
      let count: number = events.filter((item: CountdownEvent) => {
        if (item.isRepeatYearly) {
          let itemDate: Date = this.parseDate(item.targetDate);
          return itemDate.getMonth() === current.getMonth() && itemDate.getDate() === current.getDate();
        }
        return item.targetDate === fullDate;
      }).length;
      list.push({
        dateText: `${current.getDate()}`,
        fullDate: fullDate,
        isCurrentMonth: current.getMonth() === month,
        isToday: fullDate === todayText,
        hasEvent: count > 0,
        eventCount: count
      });
    }
    return list;
  }

  static filterByDate(events: CountdownEvent[], fullDate: string): CountdownEvent[] {
    let target: Date = this.parseDate(fullDate);
    return events.filter((item: CountdownEvent) => {
      if (item.isRepeatYearly) {
        let itemDate: Date = this.parseDate(item.targetDate);
        return itemDate.getMonth() === target.getMonth() && itemDate.getDate() === target.getDate();
      }
      return item.targetDate === fullDate;
    });
  }

  static getWeekTitles(): string[] {
    return ['日', '一', '二', '三', '四', '五', '六'];
  }

  static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }
}
