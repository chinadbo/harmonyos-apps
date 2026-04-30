export class FormatUtils {
  static formatDuration(duration: number): string {
    const totalSeconds: number = Math.max(0, Math.floor(duration / 1000));
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  static formatRelativeTime(timestamp: number): string {
    const diff: number = Date.now() - timestamp;
    const minute: number = 60 * 1000;
    const hour: number = 60 * minute;
    const day: number = 24 * hour;
    if (diff < minute) {
      return '刚刚';
    }
    if (diff < hour) {
      return `${Math.floor(diff / minute)} 分钟前`;
    }
    if (diff < day) {
      return `${Math.floor(diff / hour)} 小时前`;
    }
    return `${Math.floor(diff / day)} 天前`;
  }

  static safeText(value: string, fallback: string): string {
    return value?.trim()?.length ? value : fallback;
  }

  static uniqueByPath<T extends { path: string }>(items: T[]): T[] {
    const seen: Set<string> = new Set<string>();
    return items.filter((item: T) => {
      if (seen.has(item.path)) {
        return false;
      }
      seen.add(item.path);
      return true;
    });
  }

  static groupCountLabel(count: number): string {
    return `${count} 首歌曲`;
  }
}
