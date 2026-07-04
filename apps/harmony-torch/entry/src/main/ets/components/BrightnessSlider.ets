import TorchService from '../services/TorchService';

@Component
export struct BrightnessSlider {
  @Prop brightness: number;
  @Prop isVisible: boolean;
  onBrightnessChange?: (value: number) => void;

  build() {
    Column() {
      if (this.isVisible) {
        Row() {
          Text('亮度')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .width(40)

          Slider({
            value: this.brightness,
            min: 0,
            max: 100,
            step: 1,
            style: SliderStyle.InSet
          })
            .width('70%')
            .trackColor('#333333')
            .selectedColor('#FFD700')
            .blockColor('#FFD700')
            .onChange((value: number) => {
              this.brightness = value;
              if (this.onBrightnessChange) {
                this.onBrightnessChange(value);
              }
            })

          Text(`${this.brightness}%`)
            .fontSize(14)
            .fontColor('#FFD700')
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })
        .height(60)
        .animation({
          duration: 200,
          curve: Curve.EaseInOut
        })
      }
    }
  }
}
