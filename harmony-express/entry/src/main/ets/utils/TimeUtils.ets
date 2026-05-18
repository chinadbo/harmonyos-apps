export function padNumber(value: number): string {
  return value < 10 ? `0${value}` : `${value}`;
}

export function formatDate(date: Date): string {
  return `${date.getFullYear()}-${padNumber(date.getMonth() + 1)}-${padNumber(date.getDate())} ${padNumber(date.getHours())}:${padNumber(date.getMinutes())}`;
}

export function nowString(): string {
  return formatDate(new Date());
}

export function minutesAgo(time: string): string {
  const date: Date = new Date(time.replace(/-/g, '/'));
  const diffMinutes: number = Math.max(0, Math.floor((Date.now() - date.getTime()) / 60000));
  if (diffMinutes < 60) {
    return `${diffMinutes} 分钟前`;
  }
  const diffHours: number = Math.floor(diffMinutes / 60);
  if (diffHours < 24) {
    return `${diffHours} 小时前`;
  }
  const diffDays: number = Math.floor(diffHours / 24);
  return `${diffDays} 天前`;
}

export function plusMinutes(baseTime: Date, minutes: number): string {
  return formatDate(new Date(baseTime.getTime() + minutes * 60000));
}
