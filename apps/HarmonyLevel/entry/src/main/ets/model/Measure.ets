export interface MeasureRecord {
  id: number;
  mode: string; // 'bubble' | 'ruler'
  angleX: number; // X 轴倾角（roll，度）
  angleY: number; // Y 轴倾角（pitch，度）
  ts: number; // 记录时间戳（毫秒）
}

export interface CalibOffset {
  x: number; // roll 基准角（度）
  y: number; // pitch 基准角（度）
}

export interface AppSettings {
  sensitivity: number; // 1-10，越大滤波越弱、响应越快
  sound: boolean;
  keepScreenOn: boolean;
}

export const MODE_BUBBLE: string = 'bubble';
export const MODE_RULER: string = 'ruler';

export const HISTORY_LIMIT: number = 200;

export const DEFAULT_SETTINGS: AppSettings = {
  sensitivity: 5,
  sound: true,
  keepScreenOn: true
};

export const DEFAULT_OFFSET: CalibOffset = { x: 0, y: 0 };

export function modeLabel(mode: string): string {
  if (mode === MODE_BUBBLE) {
    return '气泡仪';
  }
  if (mode === MODE_RULER) {
    return '角度尺';
  }
  return mode;
}

export function formatAngle(value: number): string {
  return value.toFixed(1);
}

export function formatTs(ts: number): string {
  const d: Date = new Date(ts);
  const pad = (n: number): string => (n < 10 ? '0' + n.toString() : n.toString());
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function nextRecordId(list: MeasureRecord[]): number {
  let max: number = 0;
  for (let i = 0; i < list.length; i++) {
    if (list[i].id > max) {
      max = list[i].id;
    }
  }
  return max + 1;
}
