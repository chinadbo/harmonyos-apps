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
  MODE_BUBBLE,
  formatAngle,
  nextRecordId
} from '../model/Measure';
import { BubbleDial } from '../components/BubbleDial';
import { AngleBadge } from '../components/AngleBadge';

const LEVEL_TOL: number = 1.0;
const NEAR_TOL: number = 3.0;

@Entry
@Component
struct BubblePage {
  @State pitch: number = 0;
  @State roll: number = 0;
  @State locked: boolean = false;
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

  // 数据已在 SensorEngine 内滤波+节流，此处仅消费结果
  private onAngle(pitch: number, roll: number): void {
    if (this.locked) {
      return;
    }
    this.pitch = pitch;
    this.roll = roll;
    if (this.settings.sound && AngleSolver.isLevel(pitch, roll, LEVEL_TOL)) {
      this.sound.play(this.context!);
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

  private statusOf(): string {
    if (AngleSolver.isLevel(this.pitch, this.roll, LEVEL_TOL)) {
      return 'level';
    }
    if (AngleSolver.isLevel(this.pitch, this.roll, NEAR_TOL)) {
      return 'near';
    }
    return 'off';
  }

  private statusText(): string {
    if (this.statusOf() === 'level') {
      return '已水平';
    }
    if (this.statusOf() === 'near') {
      return '接近水平';
    }
    return '倾斜';
  }

  private toggleLock(): void {
    this.locked = !this.locked;
  }

  private quickZero(): void {
    this.offset = {
      x: AngleSolver.normalize180(this.offset.x + this.roll),
      y: AngleSolver.normalize180(this.offset.y + this.pitch)
    };
    this.engine.setOffset(this.offset);
    promptAction.showToast({ message: '已按当前姿态置零（相对测量）' });
  }

  private async saveRecord(): Promise<void> {
    const history: MeasureRecord[] = await PrefsHelper.getHistory(this.context!);
    const rec: MeasureRecord = {
      id: nextRecordId(history),
      mode: MODE_BUBBLE,
      angleX: this.roll,
      angleY: this.pitch,
      ts: Date.now()
    };
    await PrefsHelper.addRecord(this.context!, rec);
    promptAction.showToast({ message: '已记录当前角度' });
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
        Text('气泡水平仪')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#e8edf2')
        Blank()
        Text(this.locked ? '已锁定' : '实时')
          .fontSize(12)
          .fontColor(this.locked ? '#ffc14d' : '#35e08a')
      }
      .width('100%')

      Text(this.statusText())
        .fontSize(14)
        .fontColor(this.statusOf() === 'level' ? '#35e08a' :
          (this.statusOf() === 'near' ? '#ffc14d' : '#93a1b0'))

      BubbleDial({ pitch: this.pitch, roll: this.roll })
        .width('100%')

      Row({ space: 12 }) {
        AngleBadge({
          text: formatAngle(this.roll),
          status: this.statusOf(),
          label: '左右倾角'
        })
        AngleBadge({
          text: formatAngle(this.pitch),
          status: this.statusOf(),
          label: '前后倾角'
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      Blank()

      Row({ space: 10 }) {
        Button(this.locked ? '解锁' : '锁定')
          .layoutWeight(1)
          .backgroundColor('#2c3947')
          .fontColor('#e8edf2')
          .onClick(() => {
            this.toggleLock();
          })
        Button('置零')
          .layoutWeight(1)
          .backgroundColor('#2c3947')
          .fontColor('#e8edf2')
          .onClick(() => {
            this.quickZero();
          })
        Button('记录')
          .layoutWeight(1)
          .backgroundColor('#35e08a')
          .fontColor('#0e1319')
          .onClick(() => {
            this.saveRecord();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#0e1319')
  }
}
