const WEEKDAYS = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

export function pad2(v: number): string {
  return v < 10 ? `0${v}` : `${v}`;
}

export function fmtDate(date: Date): string {
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
}

export function fmtWeekday(date: Date): string {
  return WEEKDAYS[date.getDay()];
}

export function fmtPercent(ratio: number): string {
  return `${Math.round(ratio * 100)}%`;
}

export function fmtKm(km: number): string {
  return km >= 10000 ? `${(km / 10000).toFixed(1)} 万公里` : `${km} 公里`;
}

export function fmtDays(days: number): string {
  const d = Math.floor(days);
  const h = Math.round((days - d) * 24);
  return `${d} 天 ${h} 小时`;
}

export function fmtAngle(deg: number, isRa: boolean): string {
  const h = Math.floor(deg / 15);
  const m = Math.floor(((deg / 15) - h) * 60);
  if (isRa) {
    return `${pad2(h)}h ${pad2(m)}m`;
  }
  const sign = deg >= 0 ? '+' : '-';
  const a = Math.abs(deg);
  return `${sign}${Math.floor(a)}° ${pad2(Math.floor((a - Math.floor(a)) * 60))}'`;
}

export function fmtMag(mag: number): string {
  if (mag === 0) {
    return '—（流星雨）';
  }
  return mag.toFixed(2);
}

export function seasonTip(date: Date): string {
  const month = date.getMonth() + 1;
  if (month === 12 || month <= 2) {
    return '冬季星空：猎户高悬，全天亮星最多的季节';
  }
  if (month <= 5) {
    return '春季星空：狮子当空，北斗指引寻找大角与角宿一';
  }
  if (month <= 8) {
    return '夏季星空：银河横贯，牛郎织女隔河相望';
  }
  return '秋季星空：四边形飞马座领衔，仙女星系正当时';
}
