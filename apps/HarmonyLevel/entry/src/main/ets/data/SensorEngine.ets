import sensor from '@ohos.sensor';
import { BusinessError } from '@ohos.base';
import { AngleSolver } from './AngleSolver';
import { LowPassFilter } from './Filter';
import { AppSettings, CalibOffset, DEFAULT_OFFSET } from '../model/Measure';

export type AngleCallback = (pitch: number, roll: number) => void;

const EMIT_INTERVAL_MS: number = 30;

// 传感器回调频率极高：原始数据先经低通滤波，再按固定间隔节流后才回调页面，
// 页面侧不做任何解算，避免在高频回调里直接触发 build。
export class SensorEngine {
  private fx: LowPassFilter = new LowPassFilter(0.3);
  private fy: LowPassFilter = new LowPassFilter(0.3);
  private fz: LowPassFilter = new LowPassFilter(0.3);
  private callback: AngleCallback | null = null;
  private offset: CalibOffset = DEFAULT_OFFSET;
  private alpha: number = 0.3;
  private running: boolean = false;
  private lastEmit: number = 0;

  private onData = (data: sensor.AccelerometerResponse): void => {
    const x: number = this.fx.update(data.x);
    const y: number = this.fy.update(data.y);
    const z: number = this.fz.update(data.z);
    const now: number = Date.now();
    if (now - this.lastEmit < EMIT_INTERVAL_MS) {
      return;
    }
    this.lastEmit = now;
    const pitch: number = AngleSolver.normalize180(AngleSolver.pitchDeg(x, y, z) - this.offset.y);
    const roll: number = AngleSolver.normalize180(AngleSolver.rollDeg(x, y, z) - this.offset.x);
    if (this.callback !== null) {
      this.callback(pitch, roll);
    }
  };

  setCallback(callback: AngleCallback): void {
    this.callback = callback;
  }

  setOffset(offset: CalibOffset): void {
    this.offset = offset;
  }

  applySettings(settings: AppSettings): void {
    // sensitivity 1-10 → 滤波系数 0.1-0.55：数值越大滤波越弱、响应越灵敏
    this.alpha = 0.1 + (settings.sensitivity - 1) * 0.05;
    this.fx.setAlpha(this.alpha);
    this.fy.setAlpha(this.alpha);
    this.fz.setAlpha(this.alpha);
  }

  isRunning(): boolean {
    return this.running;
  }

  start(): boolean {
    if (this.running) {
      return true;
    }
    try {
      // interval 单位为纳秒：20000000ns = 20ms ≈ 50Hz
      sensor.on(sensor.SensorId.ACCELEROMETER, this.onData, { interval: 20000000 });
      this.running = true;
      this.lastEmit = 0;
      return true;
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] sensor.on failed: ${e.code} ${e.message}`);
      this.running = false;
      return false;
    }
  }

  stop(): void {
    if (!this.running) {
      return;
    }
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER);
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] sensor.off failed: ${e.code} ${e.message}`);
    }
    this.running = false;
    this.fx.reset();
    this.fy.reset();
    this.fz.reset();
  }
}

export function sensitivityToAlpha(sensitivity: number): number {
  const s: number = sensitivity < 1 ? 1 : (sensitivity > 10 ? 10 : sensitivity);
  return 0.1 + (s - 1) * 0.05;
}

