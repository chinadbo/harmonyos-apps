import { PRESET_COLORS } from '../data/CourseModel';

@Component
export struct ColorPicker {
  @Link selectedColor: string;

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      ForEach(PRESET_COLORS, (color: string) => {
        Row()
          .width(28)
          .height(28)
          .borderRadius(14)
          .backgroundColor(color)
          .margin({ right: 10, bottom: 10 })
          .border({ width: this.selectedColor === color ? 3 : 1, color: this.selectedColor === color ? Color.Black : '#22000000' })
          .onClick(() => {
            this.selectedColor = color;
          })
      }, (color: string) => color)
    }
    .width('100%')
  }
}
