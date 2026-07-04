import router from '@ohos.router';
import { TorchMode, DEFAULT_SETTINGS } from '../models/TorchMode';
import PreferenceUtil from '../utils/PreferenceUtil';

@Entry
@Component
struct SettingsPage {
  @State vibrationEnabled: boolean = true;
  @State keepScreenOn: boolean = false;
  @State defaultMode: TorchMode = TorchMode.STEADY;
  @State strobeFrequency: number = 5;

  aboutToAppear() {
    this.loadSettings();
  }

  async loadSettings() {
    try {
      const settings = await PreferenceUtil.loadSettings();
      this.vibrationEnabled = settings.vibrationEnabled;
      this.keepScreenOn = settings.keepScreenOn;
      this.defaultMode = settings.defaultMode;
      this.strobeFrequency = settings.strobeFrequency;
    } catch (err) {
      console.error('Failed to load settings: ' + JSON.stringify(err));
    }
  }

  async saveCurrentSettings() {
    try {
      await PreferenceUtil.saveSettings({
        vibrationEnabled: this.vibrationEnabled,
        keepScreenOn: this.keepScreenOn,
        defaultMode: this.defaultMode,
        strobeFrequency: this.strobeFrequency,
        screenBrightness: 80
      });
    } catch (err) {
      console.error('Failed to save settings: ' + JSON.stringify(err));
    }
  }

  resetSettings() {
    this.vibrationEnabled = DEFAULT_SETTINGS.vibrationEnabled;
    this.keepScreenOn = DEFAULT_SETTINGS.keepScreenOn;
    this.defaultMode = DEFAULT_SETTINGS.defaultMode;
    this.strobeFrequency = DEFAULT_SETTINGS.strobeFrequency;
    this.saveCurrentSettings();
  }

  @Builder
  SettingItem(title: string, description: string, @BuilderParam content: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#FFFFFF')

        Text(description)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      content()
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.saveCurrentSettings();
          router.back();
        })

        Text('设置')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 设置项列表
      List() {
        ListItem() {
          this.SettingItem('振动反馈', '开启/关闭手电筒开关时的振动反馈', () => {
            Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
              .selectedColor('#FFD700')
              .onChange((isOn: boolean) => {
                this.vibrationEnabled = isOn;
                this.saveCurrentSettings();
              })
          })
        }

        ListItem() {
          this.SettingItem('屏幕常亮', '使用手电筒时保持屏幕常亮', () => {
            Toggle({ type: ToggleType.Switch, isOn: this.keepScreenOn })
              .selectedColor('#FFD700')
              .onChange((isOn: boolean) => {
                this.keepScreenOn = isOn;
                this.saveCurrentSettings();
              })
          })
        }

        ListItem() {
          this.SettingItem('默认模式', '应用启动时的默认手电筒模式', () => {
            Text(this.defaultMode === TorchMode.STEADY ? '常亮' :
              this.defaultMode === TorchMode.SOS ? 'SOS' :
                this.defaultMode === TorchMode.STROBE ? '频闪' : '屏幕补光')
              .fontSize(14)
              .fontColor('#FFD700')
          })
        }
        .onClick(() => {
          // 可以弹窗选择默认模式，简化处理
          if (this.defaultMode === TorchMode.STEADY) {
            this.defaultMode = TorchMode.SOS;
          } else if (this.defaultMode === TorchMode.SOS) {
            this.defaultMode = TorchMode.STROBE;
          } else if (this.defaultMode === TorchMode.STROBE) {
            this.defaultMode = TorchMode.SCREEN;
          } else {
            this.defaultMode = TorchMode.STEADY;
          }
          this.saveCurrentSettings();
        })

        ListItem() {
          this.SettingItem('频闪频率', '频闪模式的闪烁频率 (Hz)', () => {
            Text(`${this.strobeFrequency} Hz`)
              .fontSize(14)
              .fontColor('#FFD700')
          })
        }
        .onClick(() => {
          // 循环切换频率 1-20
          this.strobeFrequency = (this.strobeFrequency % 20) + 1;
          this.saveCurrentSettings();
        })
      }
      .divider({ strokeWidth: 1, color: '#333333' })
      .padding({ top: 8 })
      .layoutWeight(1)

      // 重置按钮
      Button('恢复默认设置')
        .width('90%')
        .height(50)
        .backgroundColor('#333333')
        .fontColor('#FFFFFF')
        .fontSize(14)
        .borderRadius(25)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.resetSettings();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121212')
  }
}
