/**
 * Format.ets — 日期、金额、文本格式化工具
 */

export class Format {
  /** 补零 */
  static pad2(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString();
  }

  /** Date → YYYY-MM-DD */
  static dateToStr(date: Date): string {
    return date.getFullYear().toString() + '-' + Format.pad2(date.getMonth() + 1) + '-' + Format.pad2(date.getDate());
  }

  /** YYYY-MM-DD → Date（解析失败回退为今天） */
  static strToDate(text: string): Date {
    if (text.length >= 10) {
      const parts: string[] = text.split('-');
      if (parts.length === 3) {
        const y = parseInt(parts[0]);
        const m = parseInt(parts[1]);
        const d = parseInt(parts[2]);
        if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
          return new Date(y, m - 1, d);
        }
      }
    }
    return new Date();
  }

  static todayStr(): string {
    return Format.dateToStr(new Date());
  }

  /** 时间戳 → YYYY-MM-DD HH:mm */
  static timestampToStr(ts: number): string {
    if (ts <= 0) {
      return '—';
    }
    const d = new Date(ts);
    return Format.dateToStr(d) + ' ' + Format.pad2(d.getHours()) + ':' + Format.pad2(d.getMinutes());
  }

  /** 千分位金额，例如 ¥12,350.00 */
  static money(value: number): string {
    const sign = value < 0 ? '-' : '';
    const abs = Math.abs(value);
    const fixed = abs.toFixed(2);
    const dot = fixed.indexOf('.');
    const intPart = fixed.substring(0, dot);
    const decPart = fixed.substring(dot);
    let grouped = '';
    let count = 0;
    for (let i = intPart.length - 1; i >= 0; i--) {
      grouped = intPart.charAt(i) + grouped;
      count++;
      if (count % 3 === 0 && i > 0) {
        grouped = ',' + grouped;
      }
    }
    return sign + '¥' + grouped + decPart;
  }

  /** 无符号金额（图表轴标签使用），例如 1.2万 */
  static moneyShort(value: number): string {
    const abs = Math.abs(value);
    if (abs >= 10000) {
      return (abs / 10000).toFixed(abs >= 100000 ? 0 : 1) + '万';
    }
    if (abs >= 1000) {
      return (abs / 1000).toFixed(1) + 'k';
    }
    return abs.toFixed(0);
  }

  /** 数字千分位 */
  static number(value: number): string {
    return Format.money(value).replace('¥', '');
  }

  /** 百分比，保留 1 位小数 */
  static percent(part: number, total: number): string {
    if (total <= 0) {
      return '0%';
    }
    return ((part / total) * 100).toFixed(1) + '%';
  }

  /** 文本截断 */
  static ellipsis(text: string, max: number): string {
    if (text.length <= max) {
      return text;
    }
    return text.substring(0, max) + '…';
  }

  /** 标签字符串 → 数组 */
  static parseTags(tags: string): string[] {
    const result: string[] = [];
    if (tags.length === 0) {
      return result;
    }
    const parts: string[] = tags.split(',');
    for (let i = 0; i < parts.length; i++) {
      const t = parts[i].trim();
      if (t.length > 0) {
        result.push(t);
      }
    }
    return result;
  }

  /** 数组 → 标签字符串（去重、去空） */
  static joinTags(tags: string[]): string {
    const result: string[] = [];
    for (let i = 0; i < tags.length; i++) {
      const t = tags[i].trim();
      if (t.length > 0 && result.indexOf(t) < 0) {
        result.push(t);
      }
    }
    return result.join(',');
  }
}
