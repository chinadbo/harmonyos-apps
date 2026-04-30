/**
 * 时间工具类
 */
export class DateUtils {
  /**
   * 解析 RSS/Atom 时间字符串为时间戳
   * 支持 RFC 2822（RSS）和 ISO 8601（Atom）
   */
  static parseDate(dateStr: string): number {
    if (!dateStr) return 0;
    try {
      const ts = Date.parse(dateStr);
      return isNaN(ts) ? 0 : ts;
    } catch {
      return 0;
    }
  }

  /**
   * 格式化时间戳为 "MM月DD日 HH:mm" 格式
   */
  static formatDateTime(timestamp: number): string {
    if (!timestamp) return '';
    const d = new Date(timestamp);
    const month = d.getMonth() + 1;
    const day = d.getDate();
    const hour = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${month}月${day}日 ${hour}:${min}`;
  }

  /**
   * 相对时间展示（如"3小时前"）
   */
  static getRelativeTime(timestamp: number): string {
    if (!timestamp) return '';
    const now = Date.now();
    const diff = now - timestamp;
    if (diff < 0) return DateUtils.formatDateTime(timestamp);

    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    return DateUtils.formatDateTime(timestamp);
  }

  /**
   * 是否是今天
   */
  static isToday(timestamp: number): boolean {
    const today = new Date();
    const d = new Date(timestamp);
    return today.getFullYear() === d.getFullYear() &&
      today.getMonth() === d.getMonth() &&
      today.getDate() === d.getDate();
  }
}
