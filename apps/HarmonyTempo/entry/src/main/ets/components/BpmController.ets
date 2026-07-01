import { COLORS, MAX_BPM, MIN_BPM } from '../constants/AppConstants';

@Component
export struct BpmController {
  @Prop bpm: number;
  onDecrease?: () => void;
  onIncrease?: () => void;
  onChange?: (value: number) => void;

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('Tempo')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.textPrimary)
        Blank()
        Text(`${this.bpm} BPM`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('-')
          .width(52)
          .height(52)
          .fontSize(24)
          .backgroundColor(COLORS.surfaceAlt)
          .onClick(() => {
            if (this.onDecrease) {
              this.onDecrease();
            }
          })

        Slider({ value: this.bpm, min: MIN_BPM, max: MAX_BPM, step: 1, style: SliderStyle.OutSet })
          .blockColor(COLORS.primary)
          .trackColor(COLORS.border)
          .selectedColor(COLORS.primary)
          .layoutWeight(1)
          .onChange((value: number) => {
            if (this.onChange) {
              this.onChange(Math.round(value));
            }
          })

        Button('+')
          .width(52)
          .height(52)
          .fontSize(24)
          .backgroundColor(COLORS.surfaceAlt)
          .onClick(() => {
            if (this.onIncrease) {
              this.onIncrease();
            }
          })
      }
      .width('100%')
    }
    .padding(18)
    .backgroundColor(COLORS.surface)
    .borderRadius(24)
  }
}
