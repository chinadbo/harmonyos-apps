import { MoonInfo } from '../model/models';

const DEG = Math.PI / 180;
const SYNODIC_MONTH = 29.530588853;
// 2000-01-06 18:14 UTC 朔点对应的儒略日
const NEW_MOON_J2000 = 2451550.26;

export function toJulian(year: number, month: number, day: number, hour: number, minute: number): number {
  const ut = hour + minute / 60;
  const jd = 367 * year
    - Math.floor(7 * (year + Math.floor((month + 9) / 12)) / 4)
    + Math.floor(275 * month / 9)
    + day + 1721013.5 + ut / 24;
  return jd;
}

export function julianFromDate(date: Date): number {
  return toJulian(date.getUTCFullYear(), date.getUTCMonth() + 1, date.getUTCDate(),
    date.getUTCHours(), date.getUTCMinutes()) + date.getUTCSeconds() / 86400;
}

export function dateFromJulian(jd: number): Date {
  return new Date((jd - 2440587.5) * 86400000);
}

export function deg2rad(d: number): number {
  return d * DEG;
}

export function rad2deg(r: number): number {
  return r / DEG;
}

function normalize(x: number): number {
  let v = x % 1;
  if (v < 0) {
    v += 1;
  }
  return v;
}

// 太阳几何黄经（度），低精度展开式（NASA 近似）
export function sunEclipticLongitude(jd: number): number {
  const t = (jd - 2451545.0) / 36525;
  const meanLon = normalize(280.46646 + 36000.76983 * t + 0.0003032 * t * t) * 360;
  const meanAnom = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) % 360;
  const center = (1.914602 - 0.004817 * t - 0.000014 * t * t) * Math.sin(deg2rad(meanAnom))
    + (0.019993 - 0.000101 * t) * Math.sin(deg2rad(2 * meanAnom))
    + 0.000289 * Math.sin(deg2rad(3 * meanAnom));
  return normalize((meanLon + center) / 360) * 360;
}

// 月亮相位角（0=朔, 0.5=望）
export function moonPhase(jd: number): number {
  const phase = normalize((jd - NEW_MOON_J2000) / SYNODIC_MONTH);
  // 叠加主要修正项（近点月/交点月扰动近似）
  const t = (jd - 2451545.0) / 36525;
  const correction = -0.0000330 * Math.sin(deg2rad(124.8 - 1934.1 * t))
    - 0.0000290 * Math.sin(deg2rad(231.2 + 20.2 * t))
    - 0.0000075 * Math.sin(deg2rad(359.4 + 329.6 * t));
  return normalize(phase + correction);
}

export function moonAgeDays(jd: number): number {
  return moonPhase(jd) * SYNODIC_MONTH;
}

export function illuminationOf(phase: number): number {
  return (1 - Math.cos(2 * Math.PI * phase)) / 2;
}

export function phaseNameOf(phase: number): string {
  const b = 1 / 29.530588853;
  const f = phase;
  if (f < 0.5 * b * 3 || f > 1 - 0.5 * b * 3) {
    return '朔（新月）';
  }
  if (Math.abs(f - 0.25) < b * 2.5) {
    return '上弦月';
  }
  if (Math.abs(f - 0.5) < b * 3) {
    return '望（满月）';
  }
  if (Math.abs(f - 0.75) < b * 2.5) {
    return '下弦月';
  }
  if (f < 0.25) {
    return '娥眉月';
  }
  if (f < 0.5) {
    return '盈凸月';
  }
  if (f < 0.75) {
    return '亏凸月';
  }
  return '残月';
}

export function phaseEmojiOf(phase: number): string {
  const b = 1 / 29.530588853;
  const f = phase;
  if (f < 0.5 * b * 3 || f > 1 - 0.5 * b * 3) {
    return '🌑';
  }
  if (Math.abs(f - 0.25) < b * 2.5) {
    return '🌓';
  }
  if (Math.abs(f - 0.5) < b * 3) {
    return '🌕';
  }
  if (Math.abs(f - 0.75) < b * 2.5) {
    return '🌗';
  }
  if (f < 0.25) {
    return '🌒';
  }
  if (f < 0.5) {
    return '🌔';
  }
  if (f < 0.75) {
    return '🌖';
  }
  return '🌘';
}

// 距下一次朔/望的天数
export function daysToNextNewMoon(jd: number): number {
  const p = moonPhase(jd);
  return (1 - p) * SYNODIC_MONTH;
}

export function daysToNextFullMoon(jd: number): number {
  const p = moonPhase(jd);
  const target = 0.5;
  const diff = target - p;
  return (diff > 0 ? diff : diff + 1) * SYNODIC_MONTH;
}

// 地月距离（km）与视直径（度），低精度
export function moonDistanceKm(jd: number): number {
  const t = (jd - 2451545.0) / 36525;
  const d = (218.316 + 13.176396 * (jd - 2451545)) * DEG;
  const m = (134.963 + 13.064993 * (jd - 2451545)) * DEG;
  const f = (93.272 + 13.229350 * (jd - 2451545)) * DEG;
  const dist = 385000.56
    - 20905.355 * Math.cos(d)
    - 3699.111 * Math.cos(2 * d - m)
    - 2955.968 * Math.cos(2 * d)
    - 569.925 * Math.cos(2 * m);
  void t;
  void f;
  return dist;
}

export function moonAngularDiameterDeg(distKm: number): number {
  return 2 * rad2deg(Math.atan(1737.4 / distKm));
}

export function computeMoonInfo(date: Date): MoonInfo {
  const jd = julianFromDate(date);
  const phase = moonPhase(jd);
  const dist = moonDistanceKm(jd);
  return {
    julianDay: jd,
    phase: phase,
    phaseName: phaseNameOf(phase),
    phaseEmoji: phaseEmojiOf(phase),
    ageDays: phase * SYNODIC_MONTH,
    illumination: illuminationOf(phase),
    distanceKm: Math.round(dist),
    angularDiameterDeg: moonAngularDiameterDeg(dist),
    nextNewMoonDays: daysToNextNewMoon(jd),
    nextFullMoonDays: daysToNextFullMoon(jd)
  };
}
