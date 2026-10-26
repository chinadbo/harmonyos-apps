import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { SensorEngine } from '../data/SensorEngine';
import { PrefsHelper } from '../data/PrefsHelper';
import { AppSettings, CalibOffset, formatAngle } from '../model/Measure';
import { AngleBadge } from '../components/AngleBadge';

@Entry
@Component
struct CalibratePage {
  @State step: number = 1;
  @State pitch: number = 0;
  @State roll: number = 0;
  @State captured: CalibOffset = { x: 0, y: 0 };
  @State settings: AppSettings = { sensitivity: 5, sound: true, keepScreenOn: true };
  private engine: SensorEngine = new SensorEngine();
  private context: common.Context | null = null;
  private visible: boolean = false;

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.engine.setCallback((pitch: number, roll: number) => {
      this.pitch = pitch;
      this.roll = roll;
    });
  }

  onPageShow(): void {
    this.visible = true;
    PrefsHelper.getSettings(this.context!).then((settings: AppSettings) => {
      if (!this.visible) {
        return;
      }
      this.settings = settings;
      this.engine.applySettings(settings);
      this.engine.setOffset({ x: 0, y: 0 }); // 校准时读取的是未校准的原始角
      this.engine.start();
    });
  }

  onPageHide(): void {
    this.visible = false;
    this.engine.stop();
  }

  aboutToDisappear(): void {
    this.visible = false;
    this.engine.stop();
  }

  private capture(): void {
    this.captured = { x: this.roll, y: this.pitch };
    this.step = 3;
  }

  private async confirmSave(): Promise<void> {
    await PrefsHelper.saveCalib(this.context!, this.captured);
    promptAction.showToast({ message: '校准已保存' });
    setTimeout(() => {
      router.back();
    }, 600);
  }

  @Builder
  stepDots() {
    Row({ space: 8 }) {
      ForEach([1, 2, 3], (n: number) => {
        Circle({ width: 8, height: 8 })
          .fill(this.step >= n ? '#35e08a' : '#2c3947')
      }, (n: number) => n.toString())
    }
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#e8edf2')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('校准向导')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#e8edf2')
        Blank()
        this.stepDots()
      }
      .width('100%')

      if (this.step === 1) {
        Column({ space: 14 }) {
          Text('第 1 步 · 放置设备')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e8edf2')
          Text('将设备平放在待校准的基准面上（如水平桌面），保持静止 2 秒以上。校准将把该姿态记为 0° 基准。')
            .fontSize(14)
            .fontColor('#93a1b0')
            .lineHeight(22)
          Circle({ width: 120, height: 120 })
            .fill('#1a222c')
            .stroke('#35e08a')
            .strokeWidth(2)
          Blank()
          Button('开始读取')
            .width('100%')
            .backgroundColor('#35e08a')
            .fontColor('#0e1319')
            .onClick(() => {
              this.step = 2;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      } else if (this.step === 2) {
        Column({ space: 16 }) {
          Text('第 2 步 · 读取基准')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e8edf2')
          Text('保持设备静止，观察实时角度稳定后读取基准。')
            .fontSize(14)
            .fontColor('#93a1b0')
          Row({ space: 16 }) {
            AngleBadge({ text: formatAngle(this.roll), status: 'off', label: '左右原始角' })
            AngleBadge({ text: formatAngle(this.pitch), status: 'off', label: '前后原始角' })
          }
          .justifyContent(FlexAlign.SpaceEvenly)
          .width('100%')
          Blank()
          Button('读取基准')
            .width('100%')
            .backgroundColor('#35e08a')
            .fontColor('#0e1319')
            .onClick(() => {
              this.capture();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column({ space: 16 }) {
          Text('第 3 步 · 确认偏移')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e8edf2')
          Text('将写入以下校准偏移，之后所有测量以该基准为零点：')
            .fontSize(14)
            .fontColor('#93a1b0')
          Column({ space: 8 }) {
            Row() {
              Text('左右偏移 (roll)')
                .fontSize(14)
                .fontColor('#93a1b0')
              Blank()
              Text(`${formatAngle(this.captured.x)}°`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#37c8f0')
            }
            .width('100%')
            Row() {
              Text('前后偏移 (pitch)')
                .fontSize(14)
                .fontColor('#93a1b0')
              Blank()
              Text(`${formatAngle(this.captured.y)}°`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#37c8f0')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .borderRadius(12)
          .backgroundColor('#1a222c')
          Blank()
          Row({ space: 10 }) {
            Button('重新读取')
              .layoutWeight(1)
              .backgroundColor('#2c3947')
              .fontColor('#e8edf2')
              .onClick(() => {
                this.step = 2;
              })
            Button('确认并保存')
              .layoutWeight(1)
              .backgroundColor('#35e08a')
              .fontColor('#0e1319')
              .onClick(() => {
                this.confirmSave();
              })
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#0e1319')
  }
}
