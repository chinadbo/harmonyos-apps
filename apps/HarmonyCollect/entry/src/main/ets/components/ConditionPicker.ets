/**
 * ConditionPicker.ets — 成色选择（预置枚举）
 */
import { CONDITIONS, conditionColor, C_SUB, C_LINE, C_CARD } from '../common/Constants';

@Component
export struct ConditionPicker {
  @Prop selected: string = '全新';
  onChange: (condition: string) => void = (condition: string) => {};

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      ForEach(CONDITIONS, (cond: string) => {
        Text(cond)
          .fontSize(13)
          .fontColor(this.selected === cond ? 0xFFFFFF : C_SUB)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ right: 8, bottom: 8 })
          .borderRadius(16)
          .backgroundColor(this.selected === cond ? conditionColor(cond) : C_CARD)
          .border({ width: 1, color: this.selected === cond ? conditionColor(cond) : C_LINE })
          .onClick(() => this.onChange(cond))
      }, (cond: string) => cond)
    }
    .width('100%')
  }
}
