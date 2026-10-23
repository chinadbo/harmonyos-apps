import { SunTimes, MoonTimes, RiseSetInfo } from '../model/models';
import { julianFromDate, deg2rad, rad2deg } from './astro';

const DAY_MS = 86400000;
const SIN_H0_SUN = Math.sin(deg2rad(-0.833)); // 含大气折射 + 太阳视半径
const SIN_H0_CIVIL = Math.sin(deg2rad(-6));
const SIN_H0_MOON = Math.sin(deg2rad(0.125));
const J1970 = 2440588;
const J2000 = 2451545;
const OBLIQUITY = deg2rad(23.4397);

function toDays(date: Date): number {
  return date.valueOf() / DAY_MS - 0.5 + J1970 - J2000;
}

function fromJulian(j: number): Date {
  return new Date((j + J2000 - J1970 + 0.5) * DAY_MS);
}

function solarMeanAnomaly(d: number): number {
  return deg2rad(357.5291 + 0.98560028 * d);
}

function eclipticLongitude(m: number): number {
  const c = deg2rad(1.9148 * Math.sin(m) + 0.02 * Math.sin(2 * m) + 0.0003 * Math.sin(3 * m));
  const p = deg2rad(102.9372);
  return m + c + p + Math.PI;
}

function declination(l: number, b: number): number {
  return Math.asin(Math.sin(b) * Math.cos(OBLIQUITY) + Math.cos(b) * Math.sin(OBLIQUITY) * Math.sin(l));
}

function rightAscension(l: number, b: number): number {
  return Math.atan2(Math.sin(l) * Math.cos(OBLIQUITY) - Math.tan(b) * Math.sin(OBLIQUITY), Math.cos(l));
}

function siderealTime(d: number, lw: number): number {
  return deg2rad(280.16 + 360.9856235 * d) - lw;
}

function sunCoords(d: number): { dec: number; ra: number } {
  const m = solarMeanAnomaly(d);
  const l = eclipticLongitude(m);
  return { dec: declination(l, 0), ra: rightAscension(l, 0) };
}

function moonCoords(d: number): { ra: number; dec: number } {
  const l = deg2rad(218.316 + 13.176396 * d);
  const m = deg2rad(134.963 + 13.064993 * d);
  const f = deg2rad(93.272 + 13.229350 * d);
  const lon = l + deg2rad(6.289 * Math.sin(m));
  const lat = deg2rad(5.128 * Math.sin(f));
  return { ra: rightAscension(lon, lat), dec: declination(lon, lat) };
}

// 通用升落计算：返回目标天体过中天时刻（自当日起的儒略日数）± 半日弧
function riseSet(transit: number, dec: number, phi: number, sinH0: number): { rise: number | null; set: number | null } {
  const cosH = (sinH0 - Math.sin(phi) * Math.sin(dec)) / (Math.cos(phi) * Math.cos(dec));
  if (cosH > 1 || cosH < -1) {
    return { rise: null, set: null };
  }
  const w = Math.acos(cosH) / (2 * Math.PI);
  return { rise: transit - w, set: transit + w };
}

export interface SunCalcTimes {
  solarNoon: Date | null;
  sunrise: Date | null;
  sunset: Date | null;
  civilDawn: Date | null;
  civilDusk: Date | null;
  noonAltDeg: number;
}

export function getSunTimes(date: Date, lat: number, lon: number): SunCalcTimes {
  const lw = deg2rad(-lon);
  const phi = deg2rad(lat);
  const d = toDays(date);
  const n = Math.round(d - 0.5) + 0.5; // 当日本地 0:00
  const sd = sunCoords(d);
  const solarNoon = n - (siderealTime(d, lw) - sd.ra) / (2 * Math.PI);
  const noonAlt = rad2deg(Math.asin(Math.sin(phi) * Math.sin(sd.dec) + Math.cos(phi) * Math.cos(sd.dec)));

  const main = riseSet(solarNoon, sd.dec, phi, SIN_H0_SUN);
  const civil = riseSet(solarNoon, sd.dec, phi, SIN_H0_CIVIL);
  return {
    solarNoon: fromJulian(solarNoon),
    sunrise: main.rise === null ? null : fromJulian(main.rise),
    sunset: main.set === null ? null : fromJulian(main.set),
    civilDawn: civil.rise === null ? null : fromJulian(civil.rise),
    civilDusk: civil.set === null ? null : fromJulian(civil.set),
    noonAltDeg: noonAlt
  };
}

export function getMoonTimes(date: Date, lat: number, lon: number): { moonRise: Date | null; moonSet: Date | null } {
  const lw = deg2rad(-lon);
  const phi = deg2rad(lat);
  const d = toDays(date);
  const n = Math.round(d - 0.5) + 0.5;
  const mc = moonCoords(d);
  // 月过中天近似：正午 12:00 附近用恒星时差修正
  const transit = n + 0.5 + (siderealTime(n + 0.5, lw) - mc.ra) / (2 * Math.PI);
  const rs = riseSet(transit, mc.dec, phi, SIN_H0_MOON);
  return {
    moonRise: rs.rise === null ? null : fromJulian(rs.rise),
    moonSet: rs.set === null ? null : fromJulian(rs.set)
  };
}

function pad2(v: number): string {
  return v < 10 ? `0${v}` : `${v}`;
}

export function fmtTime(d: Date | null): string {
  if (d === null) {
    return '—';
  }
  return `${pad2(d.getHours())}:${pad2(d.getMinutes())}`;
}

function fmtDuration(ms: number): string {
  const totalMin = Math.round(ms / 60000);
  return `${Math.floor(totalMin / 60)}小时${pad2(totalMin % 60)}分`;
}

export function getSunTimesView(date: Date, lat: number, lon: number): SunTimes {
  const t = getSunTimes(date, lat, lon);
  const polarNote = (t.sunrise === null || t.sunset === null)
    ? (t.noonAltDeg > 0 ? '极昼：太阳整日不落' : '极夜：太阳整日不升')
    : '';
  const dayLength = (t.sunrise !== null && t.sunset !== null)
    ? fmtDuration(t.sunset.valueOf() - t.sunrise.valueOf())
    : '—';
  return {
    sunrise: fmtTime(t.sunrise),
    sunset: fmtTime(t.sunset),
    dayLength: dayLength,
    solarNoon: fmtTime(t.solarNoon),
    civilDawn: fmtTime(t.civilDawn),
    civilDusk: fmtTime(t.civilDusk),
    polarNote: polarNote
  };
}

export function getMoonTimesView(date: Date, lat: number, lon: number): MoonTimes {
  const t = getMoonTimes(date, lat, lon);
  return {
    moonRise: fmtTime(t.moonRise),
    moonSet: fmtTime(t.moonSet),
    polarNote: (t.moonRise === null || t.moonSet === null) ? '今日月球始终在地平线以上/以下' : ''
  };
}

export function getRiseAzimuth(date: Date, lat: number, isMoon: boolean): RiseSetInfo {
  const phi = deg2rad(lat);
  const d = toDays(date);
  const dec = isMoon ? moonCoords(d).dec : sunCoords(d).dec;
  const h = isMoon ? deg2rad(0.125) : deg2rad(-0.833);
  const az = Math.acos((Math.sin(dec) - Math.sin(h) * Math.sin(phi)) / (Math.cos(h) * Math.cos(phi)));
  return {
    time: fmtTime(isMoon ? getMoonTimes(date, lat, 0).moonRise : getSunTimes(date, lat, 0).sunrise),
    azimuthDeg: Math.round(rad2deg(az))
  };
}

export function moonPhaseForWidget(date: Date): number {
  const p = (julianFromDate(date) - 2451550.26) / 29.530588853;
  return ((p % 1) + 1) % 1;
}
