import router from '@ohos.router';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { PrefsHelper } from '../data/PrefsHelper';
import { sensitivityToAlpha } from '../data/SensorEngine';
import { AppSettings, CalibOffset, formatAngle } from '../model/Measure';

@Entry
@Component
struct SettingsPage {
  @State settings: AppSettings = { sensitivity: 5, sound: true, keepScreenOn: true };
  @State calib: CalibOffset = { x: 0, y: 0 };
  private context: common.Context | null = null;

  aboutToAppear(): void {
    this.context = getContext(this) as common.Context;
    this.load();
  }

  onPageShow(): void {
    this.load();
  }

  private async load(): Promise<void> {
    this.settings = await PrefsHelper.getSettings(this.context!);
    this.calib = await PrefsHelper.getCalib(this.context!);
  }

  private async persist(): Promise<void> {
    await PrefsHelper.saveSettings(this.context!, this.settings);
  }

  private setSensitivity(value: number): void {
    this.settings = {
      sensitivity: value,
      sound: this.settings.sound,
      keepScreenOn: this.settings.keepScreenOn
    };
  }

  private setSound(on: boolean): void {
    this.settings = {
      sensitivity: this.settings.sensitivity,
      sound: on,
      keepScreenOn: this.settings.keepScreenOn
    };
    this.persist();
  }

  private setKeepScreenOn(on: boolean): void {
    this.settings = {
      sensitivity: this.settings.sensitivity,
      sound: this.settings.sound,
      keepScreenOn: on
    };
    this.persist();
    window.getLastWindow(this.context!)
      .then((win: window.Window) => {
        win.setWindowKeepScreenOn(on);
      })
      .catch((err: BusinessError) => {
        console.error(`[HarmonyLevel] setWindowKeepScreenOn failed: ${err.code} ${err.message}`);
      });
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('‹')
            .fontSize(26)
            .fontColor('#e8edf2')
            .padding({ left: 4, right: 12 })
            .onClick(() => {
              router.back();
            })
          Text('设置')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e8edf2')
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('灵敏度')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e8edf2')
          Row() {
            Text('低通滤波强度')
              .fontSize(13)
              .fontColor('#93a1b0')
            Blank()
            Text(`${this.settings.sensitivity} / 10`)
              .fontSize(13)
              .fontColor('#37c8f0')
          }
          .width('100%')
          Slider({
            value: this.settings.sensitivity,
            min: 1,
            max: 10,
            step: 1,
            style: SliderStyle.OutSet
          })
            .width('100%')
            .selectedColor('#35e08a')
            .trackColor('#2c3947')
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === SliderChangeMode.Begin || mode === SliderChangeMode.Moving) {
                this.setSensitivity(value);
              } else {
                this.setSensitivity(value);
                this.persist();
              }
            })
          Text(`数值越大响应越快、抖动越多（滤波系数 ${sensitivityToAlpha(this.settings.sensitivity).toFixed(2)}）`)
            .fontSize(11)
            .fontColor('#5c6b78')
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#1a222c')
        .border({ width: 1, color: '#2c3947' })
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Row() {
            Column({ space: 2 }) {
              Text('声音提示')
                .fontSize(15)
                .fontColor('#e8edf2')
              Text('接近水平 / 命中目标角度时短音提示')
                .fontSize(11)
                .fontColor('#93a1b0')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.settings.sound })
              .selectedColor('#35e08a')
              .onChange((isOn: boolean) => {
                this.setSound(isOn);
              })
          }
          .width('100%')

          Divider().color('#2c3947')

          Row() {
            Column({ space: 2 }) {
              Text('保持亮屏')
                .fontSize(15)
                .fontColor('#e8edf2')
              Text('测量页面持续保持屏幕常亮')
                .fontSize(11)
                .fontColor('#93a1b0')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.settings.keepScreenOn })
              .selectedColor('#35e08a')
              .onChange((isOn: boolean) => {
                this.setKeepScreenOn(isOn);
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#1a222c')
        .border({ width: 1, color: '#2c3947' })

        Column({ space: 10 }) {
          Text('校准基准')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e8edf2')
          Row() {
            Text(`左右偏移 ${formatAngle(this.calib.x)}°`)
              .fontSize(13)
              .fontColor('#93a1b0')
            Blank()
            Text(`前后偏移 ${formatAngle(this.calib.y)}°`)
              .fontSize(13)
              .fontColor('#93a1b0')
          }
          .width('100%')
          Button('重新校准')
            .width('100%')
            .backgroundColor('#2c3947')
            .fontColor('#e8edf2')
            .onClick(() => {
              router.pushUrl({ url: 'pages/CalibratePage' });
            })
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#1a222c')
        .border({ width: 1, color: '#2c3947' })
        .alignItems(HorizontalAlign.Start)

        Text('HarmonyLevel v1.0.0 · 纯传感器应用，无需任何权限')
          .fontSize(11)
          .fontColor('#5c6b78')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0e1319')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}
