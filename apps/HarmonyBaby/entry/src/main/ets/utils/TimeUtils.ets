/**
 * 时间工具类：统一使用毫秒时间戳（Number）
 */
export class TimeUtils {
  static readonly SECOND: number = 1000;
  static readonly MINUTE: number = 60 * 1000;
  static readonly HOUR: number = 60 * 60 * 1000;
  static readonly DAY: number = 24 * 60 * 60 * 1000;

  private static pad(n: number): string {
    if (n < 10) {
      return '0' + n;
    }
    return '' + n;
  }

  /** HH:mm */
  static formatTime(ms: number): string {
    const d = new Date(ms);
    return TimeUtils.pad(d.getHours()) + ':' + TimeUtils.pad(d.getMinutes());
  }

  /** yyyy-MM-dd */
  static formatDate(ms: number): string {
    const d = new Date(ms);
    return d.getFullYear() + '-' + TimeUtils.pad(d.getMonth() + 1) + '-' + TimeUtils.pad(d.getDate());
  }

  /** MM-dd */
  static formatMonthDay(ms: number): string {
    const d = new Date(ms);
    return TimeUtils.pad(d.getMonth() + 1) + '-' + TimeUtils.pad(d.getDate());
  }

  /** MM-dd HH:mm */
  static formatMonthDayTime(ms: number): string {
    return TimeUtils.formatMonthDay(ms) + ' ' + TimeUtils.formatTime(ms);
  }

  /** X小时Y分钟 / Y分钟 / Y秒 */
  static formatDuration(ms: number): string {
    if (ms < 0) {
      ms = 0;
    }
    const h = Math.floor(ms / TimeUtils.HOUR);
    const m = Math.floor((ms % TimeUtils.HOUR) / TimeUtils.MINUTE);
    const s = Math.floor((ms % TimeUtils.MINUTE) / TimeUtils.SECOND);
    if (h > 0) {
      return h + '小时' + m + '分钟';
    }
    if (m > 0) {
      return m + '分钟';
    }
    return s + '秒';
  }

  /** X小时Y分（紧凑，用于统计卡片） */
  static formatDurationShort(ms: number): string {
    if (ms < 0) {
      ms = 0;
    }
    const h = Math.floor(ms / TimeUtils.HOUR);
    const m = Math.floor((ms % TimeUtils.HOUR) / TimeUtils.MINUTE);
    if (h > 0) {
      if (m > 0) {
        return h + 'h' + m + 'm';
      }
      return h + 'h';
    }
    if (m > 0) {
      return m + 'm';
    }
    return Math.floor(ms / TimeUtils.SECOND) + 's';
  }

  /** MM:SS（计时器显示） */
  static formatClock(ms: number): string {
    if (ms < 0) {
      ms = 0;
    }
    const totalSec = Math.floor(ms / TimeUtils.SECOND);
    const m = Math.floor(totalSec / 60);
    const s = totalSec % 60;
    return TimeUtils.pad(m) + ':' + TimeUtils.pad(s);
  }

  /** 当天 00:00:00.000 的时间戳 */
  static dayStart(ms: number): number {
    const d = new Date(ms);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  }

  static todayStart(): number {
    return TimeUtils.dayStart(Date.now());
  }

  /** 当天 23:59:59.999 */
  static dayEnd(ms: number): number {
    return TimeUtils.dayStart(ms) + TimeUtils.DAY - 1;
  }

  static addDays(ms: number, days: number): number {
    return ms + days * TimeUtils.DAY;
  }

  static sameDay(a: number, b: number): boolean {
    return TimeUtils.dayStart(a) === TimeUtils.dayStart(b);
  }

  /** 周一~周日 -> '一'...'日' */
  static weekdayShort(ms: number): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六'];
    return names[new Date(ms).getDay()];
  }

  static daysInMonth(year: number, month: number): number {
    // month: 0-11
    return new Date(year, month + 1, 0).getDate();
  }

  /** 该月 1 号是周几（0=周日） */
  static firstWeekday(year: number, month: number): number {
    return new Date(year, month, 1).getDay();
  }

  static monthStart(ms: number): number {
    const d = new Date(ms);
    d.setDate(1);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  }

  /** 宝宝年龄文案：出生 X 天 / X个月Y天 */
  static ageText(birthday: number, now: number): string {
    if (birthday <= 0) {
      return '未设置';
    }
    const b = new Date(birthday);
    const n = new Date(now);
    const totalDays = Math.floor((TimeUtils.dayStart(now) - TimeUtils.dayStart(birthday)) / TimeUtils.DAY);
    let months = (n.getFullYear() - b.getFullYear()) * 12 + (n.getMonth() - b.getMonth());
    if (n.getDate() < b.getDate()) {
      months--;
    }
    if (months < 1) {
      return '出生 ' + (totalDays + 1) + ' 天';
    }
    const anchor = new Date(b.getFullYear(), b.getMonth() + months, b.getDate());
    const remDays = Math.floor((TimeUtils.dayStart(now) - anchor.getTime()) / TimeUtils.DAY);
    if (remDays > 0) {
      return months + '个月' + remDays + '天';
    }
    return months + '个月';
  }

  /** 两个时间相差的人性化描述：X分钟前 / X小时前 / X天前 */
  static agoText(past: number, now: number): string {
    const diff = now - past;
    if (diff < TimeUtils.MINUTE) {
      return '刚刚';
    }
    if (diff < TimeUtils.HOUR) {
      return Math.floor(diff / TimeUtils.MINUTE) + ' 分钟前';
    }
    if (TimeUtils.sameDay(past, now)) {
      return Math.floor(diff / TimeUtils.HOUR) + ' 小时前';
    }
    const days = Math.floor(diff / TimeUtils.DAY);
    if (days < 30) {
      return days + ' 天前';
    }
    return TimeUtils.formatMonthDay(past);
  }
}
