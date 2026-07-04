import router from '@ohos.router';
import { TorchMode, MODE_ICONS, MODE_LABELS } from '../models/TorchMode';
import TorchService from '../services/TorchService';
import PreferenceUtil from '../utils/PreferenceUtil';
import { TorchButton } from '../components/TorchButton';
import { BrightnessSlider } from '../components/BrightnessSlider';

@Entry
@Component
struct Index {
  @State isTorchOn: boolean = false;
  @State currentMode: TorchMode = TorchMode.STEADY;
  @State brightness: number = 80;
  @State vibrationEnabled: boolean = true;
  @State strobeFrequency: number = 5;
  @State isScreenMode: boolean = false;
  @State screenBrightness: number = 80;

  private service: TorchService = TorchService.getInstance();

  aboutToAppear() {
    this.loadSettings();
  }

  aboutToDisappear() {
    this.service.cleanup();
  }

  async loadSettings() {
    try {
      const settings = await PreferenceUtil.loadSettings();
      this.vibrationEnabled = settings.vibrationEnabled;
      this.currentMode = settings.defaultMode;
      this.strobeFrequency = settings.strobeFrequency;
      this.screenBrightness = settings.screenBrightness;
      this.brightness = settings.screenBrightness;
    } catch (err) {
      console.error('Failed to load settings: ' + JSON.stringify(err));
    }
  }

  onTorchStateChange(isOn: boolean) {
    this.isTorchOn = isOn;
    this.isScreenMode = this.service.isScreenMode();
  }

  onModeChange(mode: TorchMode) {
    if (this.currentMode === mode) return;

    this.currentMode = mode;

    if (this.isTorchOn) {
      this.service.turnOn(mode, this.strobeFrequency).then(() => {
        this.isScreenMode = this.service.isScreenMode();
      });
    }
  }

  onBrightnessChange(value: number) {
    this.brightness = value;
    this.screenBrightness = value;
    if (this.isTorchOn && this.currentMode === TorchMode.STEADY) {
      this.service.setBrightness(value);
    }
  }

  isBrightnessVisible(): boolean {
    return this.currentMode === TorchMode.STEADY || this.currentMode === TorchMode.STROBE;
  }

  @Builder
  ModeBarItem(mode: TorchMode) {
    Column() {
      Text(MODE_ICONS[mode])
        .fontSize(24)
        .margin({ bottom: 4 })

      Text(MODE_LABELS[mode])
        .fontSize(10)
        .fontColor(this.currentMode === mode ? '#FFD700' : '#888888')
    }
    .width('25%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onModeChange(mode);
    })
  }

  build() {
    Stack() {
      // 屏幕补光模式：全屏白色背景
      if (this.isScreenMode) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(`rgba(255, 255, 255, ${this.screenBrightness / 100})`)
      } else {
        // 暗色主题主背景
        Column() {
          // 标题栏
          Row() {
            Text('HarmonyTorch')
              .fontSize(20)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)

            Blank()

            Button() {
              Image($r('app.media.settings_icon'))
                .width(24)
                .height(24)
                .fillColor('#FFFFFF')
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' });
            })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          // 模式标签
          Text(MODE_LABELS[this.currentMode])
            .fontSize(16)
            .fontColor('#FFD700')
            .margin({ top: 20, bottom: 10 })

          // 主按钮
          TorchButton({
            isOn: this.isTorchOn,
            currentMode: this.currentMode,
            vibrationEnabled: this.vibrationEnabled,
            strobeFrequency: this.strobeFrequency,
            onStateChange: (isOn: boolean) => {
              this.onTorchStateChange(isOn);
            }
          })
            .margin({ top: 40 })

          // 亮度滑条
          BrightnessSlider({
            brightness: this.brightness,
            isVisible: this.isBrightnessVisible(),
            onBrightnessChange: (value: number) => {
              this.onBrightnessChange(value);
            }
          })
            .margin({ top: 40 })

          Blank()

          // 底部模式栏
          Row() {
            this.ModeBarItem(TorchMode.STEADY)
            this.ModeBarItem(TorchMode.SOS)
            this.ModeBarItem(TorchMode.STROBE)
            this.ModeBarItem(TorchMode.SCREEN)
          }
          .width('100%')
          .height(70)
          .backgroundColor('#1E1E1E')
          .justifyContent(FlexAlign.SpaceAround)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#121212')
      }

      // 屏幕补光模式下的亮度控制
      if (this.isScreenMode) {
        Column() {
          Row() {
            Text('亮度')
              .fontSize(14)
              .fontColor('#333333')
              .width(40)

            Slider({
              value: this.screenBrightness,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.InSet
            })
              .width('70%')
              .trackColor('#CCCCCC')
              .selectedColor('#FFD700')
              .blockColor('#FFD700')
              .onChange((value: number) => {
                this.screenBrightness = value;
              })

            Text(`${this.screenBrightness}%`)
              .fontSize(14)
              .fontColor('#333333')
              .width(50)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16 })
          .height(60)

          // 关闭按钮
          Button() {
            Text('关闭')
              .fontSize(16)
              .fontColor('#FFFFFF')
          }
          .width(120)
          .height(48)
          .backgroundColor('#FF4444')
          .borderRadius(24)
          .margin({ top: 20 })
          .onClick(() => {
            this.service.turnOff();
            this.isTorchOn = false;
            this.isScreenMode = false;
          })
        }
        .width('100%')
        .position({ x: 0, y: '90%' })
      }
    }
    .width('100%')
    .height('100%')
  }
}
