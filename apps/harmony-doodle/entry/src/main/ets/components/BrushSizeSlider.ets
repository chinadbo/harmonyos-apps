import { ToolType } from '../models/Types';

@Component
export struct BrushSizeSlider {
  @Link size: number;
  private onChange?: (size: number) => void;

  build() {
    Row() {
      Text('Size: ' + this.size)
        .fontSize(14)
        .fontColor('#666666')
        .width(70)

      Slider({ value: this.size, min: 1, max: 50, step: 1 })
        .layoutWeight(1)
        .onChange((value: number) => {
          this.size = value;
          this.onChange?.(value);
        })

      Circle()
        .width(this.size + 8)
        .height(this.size + 8)
        .fill('#000000')
        .margin({ left: 12 })
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}
