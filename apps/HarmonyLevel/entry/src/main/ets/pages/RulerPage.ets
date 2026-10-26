import router from '@ohos.router';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import { SensorEngine } from '../data/SensorEngine';
import { PrefsHelper } from '../data/PrefsHelper';
import { SoundHelper } from '../data/SoundHelper';
import { AngleSolver } from '../data/AngleSolver';
import {
  AppSettings,
  CalibOffset,
  MeasureRecord,
  MODE_RULER,
  formatAngle,
  nextRecordId
} from '../model/Measure';
import { AngleBadge } from '../components/AngleBadge';
import { AngleRuler } from '../components/AngleRuler';
import { TargetRing } from '../components/TargetRing';

const LEVEL_TOL: number = 0.5;
const NEAR_TOL: number = 2.0;
const TARGET_OFF: number = -1;

@Entry
@Component
struct RulerPage {
  @State angle360: number = 0;
  @State axisLabel: string = '左右轴';
  @State target: number = TARGET_OFF;
  @State settings: AppSettings = { sensitivity: 5, sound: true, keepScreenOn: true };
  private engine: SensorEngine = new SensorEngine();
  private offset: CalibOffset = { x: 0, y: 0 };
  private sound: SoundHelper = SoundHelper.getInstance();
  private context: common.Context | null = null;
  private visible: boolean = false;

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.engine.setCallback((pitch: number, roll: number) => {
      this.onAngle(pitch, roll);
    });
  }

  onPageShow(): void {
    this.visible = true;
    this.loadPrefs().then(() => {
      if (!this.visible) {
        return;
      }
      this.engine.setOffset(this.offset);
      this.engine.applySettings(this.settings);
      this.engine.start();
      this.applyKeepScreenOn();
    });
  }

  onPageHide(): void {
    this.visible = false;
    this.engine.stop();
    this.clearKeepScreenOn();
  }

  aboutToDisappear(): void {
    this.visible = false;
    this.engine.stop();
  }

  private async loadPrefs(): Promise<void> {
    this.settings = await PrefsHelper.getSettings(this.context!);
    this.offset = await PrefsHelper.getCalib(this.context!);
  }

  private onAngle(pitch: number, roll: number): void {
    // 横竖两种姿态自动切换：|pitch|>|roll| 时以前后轴为主轴
    let primary: number = roll;
    if (Math.abs(pitch) > Math.abs(roll)) {
      primary = pitch;
      this.axisLabel = '前后轴';
    } else {
      this.axisLabel = '左右轴';
    }
    this.angle360 = AngleSolver.normalize360(primary);
    if (this.settings.sound && this.target >= 0) {
      const diff: number = Math.abs(AngleSolver.normalize180(this.angle360 - this.target));
      if (diff <= LEVEL_TOL) {
        this.sound.play(this.context!);
      }
    }
  }

  private applyKeepScreenOn(): void {
    window.getLastWindow(this.context!)
      .then((win: window.Window) => {
        win.setWindowKeepScreenOn(this.settings.keepScreenOn);
      })
      .catch((err: BusinessError) => {
        console.error(`[HarmonyLevel] setWindowKeepScreenOn failed: ${err.code} ${err.message}`);
      });
  }

  private clearKeepScreenOn(): void {
    window.getLastWindow(this.context!)
      .then((win: window.Window) => {
        win.setWindowKeepScreenOn(false);
      })
      .catch((err: BusinessError) => {
        console.error(`[HarmonyLevel] setWindowKeepScreenOn failed: ${err.code} ${err.message}`);
      });
  }

  private targetDiff(): number {
    if (this.target < 0) {
      return 999;
    }
    return Math.abs(AngleSolver.normalize180(this.angle360 - this.target));
  }

  private statusOf(): string {
    const diff: number = this.targetDiff();
    if (diff <= LEVEL_TOL) {
      return 'level';
    }
    if (diff <= NEAR_TOL) {
      return 'near';
    }
    return 'off';
  }

  private statusText(): string {
    if (this.target < 0) {
      return '自由测量';
    }
    const diff: number = this.targetDiff();
    if (diff <= LEVEL_TOL) {
      return `命中 ${this.target}°`;
    }
    if (diff <= NEAR_TOL) {
      return `接近 ${this.target}°`;
    }
    return `目标 ${this.target}°`;
  }

  private async saveRecord(): Promise<void> {
    const history: MeasureRecord[] = await PrefsHelper.getHistory(this.context!);
    const rec: MeasureRecord = {
      id: nextRecordId(history),
      mode: MODE_RULER,
      angleX: this.angle360,
      angleY: 0,
      ts: Date.now()
    };
    await PrefsHelper.addRecord(this.context!, rec);
    promptAction.showToast({ message: '已记录当前角度' });
  }

  @Builder
  targetButton(label: string, value: number) {
    Text(label)
      .fontSize(14)
      .fontColor(this.target === value ? '#0e1319' : '#e8edf2')
      .backgroundColor(this.target === value ? '#35e08a' : '#2c3947')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(10)
      .onClick(() => {
        this.target = value;
      })
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#e8edf2')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('角度尺')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#e8edf2')
        Blank()
        Text(this.statusText())
          .fontSize(12)
          .fontColor(this.statusOf() === 'level' ? '#35e08a' :
            (this.statusOf() === 'near' ? '#ffc14d' : '#93a1b0'))
      }
      .width('100%')

      AngleBadge({
        text: formatAngle(this.angle360),
        status: this.statusOf(),
        label: `${this.axisLabel} · 0-360°`
      })

      AngleRuler({ angle: this.angle360 })
        .width('100%')

      TargetRing({ angle: this.angle360, target: this.target })
        .width('62%')

      Row({ space: 10 }) {
        this.targetButton('0°', 0)
        this.targetButton('45°', 45)
        this.targetButton('90°', 90)
        this.targetButton('关闭', TARGET_OFF)
      }
      .justifyContent(FlexAlign.Center)

      Blank()

      Button('记录当前角度')
        .width('100%')
        .backgroundColor('#35e08a')
        .fontColor('#0e1319')
        .onClick(() => {
          this.saveRecord();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#0e1319')
  }
}
