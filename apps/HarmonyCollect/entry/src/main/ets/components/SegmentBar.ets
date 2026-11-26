/**
 * SegmentBar.ets — 通用分段选择控件
 */
import { C_BRAND, C_SUB, C_LINE, C_CARD } from '../common/Constants';

@Component
export struct SegmentBar {
  @Prop options: string[] = [];
  @Prop selectedIndex: number = 0;
  onChange: (index: number) => void = (index: number) => {};

  build() {
    Row() {
      ForEach(this.options, (label: string, index: number) => {
        Text(label)
          .fontSize(14)
          .fontColor(this.selectedIndex === index ? 0xFFFFFF : C_SUB)
          .fontWeight(this.selectedIndex === index ? FontWeight.Medium : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(34)
          .borderRadius(17)
          .backgroundColor(this.selectedIndex === index ? C_BRAND : Color.Transparent)
          .onClick(() => {
            if (this.selectedIndex !== index) {
              this.onChange(index);
            }
          })
      }, (label: string, index: number) => label + index.toString())
    }
    .width('100%')
    .padding(3)
    .backgroundColor(C_CARD)
    .borderRadius(20)
    .border({ width: 1, color: C_LINE })
  }
}
