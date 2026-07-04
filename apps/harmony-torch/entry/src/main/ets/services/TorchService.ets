import camera from '@ohos.multimedia.camera';
import vibrator from '@ohos.sensor.vibrator';
import { TorchMode } from '../models/TorchMode';

export default class TorchService {
  private static instance: TorchService;
  private isTorchOn: boolean = false;
  private currentMode: TorchMode = TorchMode.STEADY;
  private screenMode: boolean = false;
  private sosInterval: number = -1;
  private strobeInterval: number = -1;
  private sosIndex: number = 0;
  private sosPattern: number[] = [200, 200, 200, 600, 600, 600, 200, 200, 200];
  private strobeFreq: number = 5;
  private strobeState: boolean = false;

  static getInstance(): TorchService {
    if (!TorchService.instance) {
      TorchService.instance = new TorchService();
    }
    return TorchService.instance;
  }

  private constructor() {}

  isOn(): boolean {
    return this.isTorchOn;
  }

  getCurrentMode(): TorchMode {
    return this.currentMode;
  }

  isScreenMode(): boolean {
    return this.screenMode;
  }

  async turnOn(mode: TorchMode = TorchMode.STEADY, freq: number = 5): Promise<void> {
    if (this.isTorchOn && this.currentMode === mode) {
      return;
    }

    this.turnOffInternal();
    this.currentMode = mode;
    this.strobeFreq = freq;

    if (mode === TorchMode.SCREEN) {
      this.screenMode = true;
      this.isTorchOn = true;
    } else {
      this.screenMode = false;
      try {
        let cameraManager = camera.getCameraManager(this.getContext());
        cameraManager.setTorchMode(true);
        this.isTorchOn = true;
      } catch (err) {
        console.error('Failed to turn on torch: ' + JSON.stringify(err));
        this.isTorchOn = false;
        return;
      }
    }

    if (mode === TorchMode.SOS) {
      this.startSOS();
    } else if (mode === TorchMode.STROBE) {
      this.startStrobe();
    }
  }

  async turnOff(): Promise<void> {
    this.turnOffInternal();
  }

  private turnOffInternal(): void {
    this.clearIntervals();

    if (!this.screenMode) {
      try {
        let cameraManager = camera.getCameraManager(this.getContext());
        cameraManager.setTorchMode(false);
      } catch (err) {
        console.error('Failed to turn off torch: ' + JSON.stringify(err));
      }
    }

    this.isTorchOn = false;
    this.screenMode = false;
    this.currentMode = TorchMode.STEADY;
    this.strobeState = false;
    this.sosIndex = 0;
  }

  private startSOS(): void {
    this.sosIndex = 0;
    this.sosInterval = setInterval(() => {
      if (!this.isTorchOn || this.currentMode !== TorchMode.SOS) {
        this.clearIntervals();
        return;
      }
      const duration = this.sosPattern[this.sosIndex % this.sosPattern.length];
      try {
        let cameraManager = camera.getCameraManager(this.getContext());
        cameraManager.setTorchMode(this.sosIndex % 2 === 0);
      } catch (err) {
        console.error('SOS toggle error: ' + JSON.stringify(err));
      }
      this.sosIndex++;
    }, 300);
  }

  private startStrobe(): void {
    this.strobeState = true;
    const intervalMs = Math.max(50, Math.floor(1000 / this.strobeFreq));
    this.strobeInterval = setInterval(() => {
      if (!this.isTorchOn || this.currentMode !== TorchMode.STROBE) {
        this.clearIntervals();
        return;
      }
      this.strobeState = !this.strobeState;
      try {
        let cameraManager = camera.getCameraManager(this.getContext());
        cameraManager.setTorchMode(this.strobeState);
      } catch (err) {
        console.error('Strobe toggle error: ' + JSON.stringify(err));
      }
    }, intervalMs);
  }

  private clearIntervals(): void {
    if (this.sosInterval !== -1) {
      clearInterval(this.sosInterval);
      this.sosInterval = -1;
    }
    if (this.strobeInterval !== -1) {
      clearInterval(this.strobeInterval);
      this.strobeInterval = -1;
    }
  }

  async setBrightness(value: number): Promise<void> {
    try {
      let cameraManager = camera.getCameraManager(this.getContext());
      // 部分设备可能不支持亮度调节，静默失败
      // API 12 中 setTorchMode 只支持 boolean，亮度调节通过其他方式
      // 此处预留扩展点
    } catch (err) {
      // 静默失败
      console.info('Brightness adjustment not supported on this device');
    }
  }

  async vibrate(): Promise<void> {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 50
      }, {
        usage: 'unknown'
      });
    } catch (err) {
      console.error('Vibration failed: ' + JSON.stringify(err));
    }
  }

  private getContext(): Context {
    // 获取 UIAbility 上下文
    // 在 EntryAbility 中通过 AbilityContext 获取
    // 这里使用 getContext() 作为通用方法
    return getContext() as Context;
  }

  cleanup(): void {
    this.turnOffInternal();
  }
}
