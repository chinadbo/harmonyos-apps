export function pad2(n: number): string {
  if (n < 10) {
    return `0${n}`;
  }
  return `${n}`;
}

export function dateToString(d: Date): string {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}

export function todayStr(): string {
  return dateToString(new Date());
}

export function dayAgoStr(days: number): string {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return dateToString(d);
}

export function formatThousands(n: number): string {
  const neg = n < 0;
  let v = Math.abs(Math.round(n));
  let s = `${v}`;
  const parts: string[] = [];
  while (s.length > 3) {
    parts.unshift(s.slice(s.length - 3));
    s = s.slice(0, s.length - 3);
  }
  parts.unshift(s);
  let out = parts.join(',');
  if (neg) {
    out = `-${out}`;
  }
  return out;
}

export function clampN(n: number, lo: number, hi: number): number {
  if (n < lo) {
    return lo;
  }
  if (n > hi) {
    return hi;
  }
  return n;
}

export function timeStamp(): string {
  const d = new Date();
  return `${d.getFullYear()}${pad2(d.getMonth() + 1)}${pad2(d.getDate())}_${pad2(d.getHours())}${pad2(d.getMinutes())}${pad2(d.getSeconds())}`;
}

export function normalizeDateNumber(y: string, m: string, day: string): string {
  const mm = parseInt(m);
  const dd = parseInt(day);
  return `${y}-${pad2(mm)}-${pad2(dd)}`;
}
