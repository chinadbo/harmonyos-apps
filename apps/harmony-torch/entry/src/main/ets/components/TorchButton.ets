import { TorchMode } from '../models/TorchMode';
import TorchService from '../services/TorchService';

@Component
export struct TorchButton {
  @Prop isOn: boolean;
  @Prop currentMode: TorchMode;
  @Prop vibrationEnabled: boolean;
  @Prop strobeFrequency: number;
  onStateChange?: (isOn: boolean) => void;

  @State private scaleValue: number = 1.0;

  private async toggleTorch(): Promise<void> {
    this.scaleValue = 0.9;
    setTimeout(() => {
      this.scaleValue = 1.0;
    }, 100);

    const service = TorchService.getInstance();
    if (this.isOn) {
      await service.turnOff();
      if (this.onStateChange) {
        this.onStateChange(false);
      }
    } else {
      if (this.vibrationEnabled) {
        await service.vibrate();
      }
      await service.turnOn(this.currentMode, this.strobeFrequency);
      if (this.onStateChange) {
        this.onStateChange(true);
      }
    }
  }

  build() {
    Column() {
      Button() {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Image($r('app.media.torch_icon'))
              .width(80)
              .height(80)
              .fillColor(this.isOn ? '#121212' : '#FFFFFF')
              .objectFit(ImageFit.Contain)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }
      .width(200)
      .height(200)
      .backgroundColor(this.isOn ? '#FFD700' : '#333333')
      .borderRadius(100)
      .shadow({
        radius: this.isOn ? 20 : 0,
        color: this.isOn ? '#FFD700' : '#000000',
        offsetX: 0,
        offsetY: this.isOn ? 4 : 0
      })
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .animation({
        duration: 100,
        curve: Curve.EaseInOut
      })
      .onClick(() => {
        this.toggleTorch();
      })
    }
  }
}
