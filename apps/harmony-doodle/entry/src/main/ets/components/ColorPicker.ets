import { ToolType, TOOL_NAMES, ToolConfig, PRESET_COLORS } from '../models/Types';

@Component
export struct ColorPicker {
  @Link currentColor: string;
  @Link currentOpacity: number;
  private onColorChange?: (color: string) => void;
  private onOpacityChange?: (opacity: number) => void;

  build() {
    Column() {
      Text('Color')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(PRESET_COLORS, (color: string) => {
          Button()
            .width(32)
            .height(32)
            .backgroundColor(color)
            .borderRadius(16)
            .border({ width: this.currentColor === color ? 2 : 0, color: '#FFFFFF' })
            .margin(4)
            .onClick(() => {
              this.currentColor = color;
              this.onColorChange?.(color);
            })
        }, (color: string) => color)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text('Opacity: ' + Math.round(this.currentOpacity * 100) + '%')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 4 })

      Slider({ value: this.currentOpacity * 100, min: 10, max: 100, step: 5 })
        .width('100%')
        .onChange((value: number) => {
          this.currentOpacity = value / 100;
          this.onOpacityChange?.(this.currentOpacity);
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}
