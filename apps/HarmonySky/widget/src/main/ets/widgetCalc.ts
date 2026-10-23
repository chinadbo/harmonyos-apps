// Widget 专用精简月相计算（与 entry/engine 同源算法的独立副本，避免跨模块依赖）
const SYNODIC_MONTH = 29.530588853;
const NEW_MOON_J2000 = 2451550.26;

export interface MoonWidgetCalc {
  phase: number;
  phaseName: string;
  illuminationPercent: number;
  ageDays: number;
  dateLabel: string;
}

function julianFromDate(date: Date): number {
  return date.getTime() / 86400000 + 2440587.5;
}

export function moonWidgetCalc(date: Date): MoonWidgetCalc {
  const jd = julianFromDate(date);
  let p = (jd - NEW_MOON_J2000) / SYNODIC_MONTH;
  p = ((p % 1) + 1) % 1;
  const age = p * SYNODIC_MONTH;
  const ill = (1 - Math.cos(2 * Math.PI * p)) / 2;

  const b = 1 / SYNODIC_MONTH;
  let name = '娥眉月';
  if (p < 1.5 * b || p > 1 - 1.5 * b) {
    name = '朔（新月）';
  } else if (Math.abs(p - 0.25) < 2.5 * b) {
    name = '上弦月';
  } else if (Math.abs(p - 0.5) < 1.5 * b) {
    name = '望（满月）';
  } else if (Math.abs(p - 0.75) < 2.5 * b) {
    name = '下弦月';
  } else if (p < 0.25) {
    name = '娥眉月';
  } else if (p < 0.5) {
    name = '盈凸月';
  } else if (p < 0.75) {
    name = '亏凸月';
  } else {
    name = '残月';
  }

  const pad = (v: number): string => (v < 10 ? `0${v}` : `${v}`);
  return {
    phase: p,
    phaseName: name,
    illuminationPercent: Math.round(ill * 100),
    ageDays: age,
    dateLabel: `${date.getMonth() + 1}月${date.getDate()}日`
  };
}
