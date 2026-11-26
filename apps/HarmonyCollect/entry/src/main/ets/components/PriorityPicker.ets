/**
 * PriorityPicker.ets — 心愿优先级（1-3 星）
 */
import { PRIORITIES, priorityLabel, C_BRAND, C_LINE, C_SUB } from '../common/Constants';

@Component
export struct PriorityPicker {
  @Prop priority: number = 2;
  onChange: (priority: number) => void = (priority: number) => {};

  build() {
    Column() {
      Row() {
        ForEach(PRIORITIES, (level: number) => {
          Text(level <= this.priority ? '★' : '☆')
            .fontSize(30)
            .fontColor(level <= this.priority ? C_BRAND : C_LINE)
            .margin({ right: 10 })
            .onClick(() => this.onChange(level))
        }, (level: number) => level.toString())
        Text(priorityLabel(this.priority))
          .fontSize(13)
          .fontColor(C_SUB)
          .margin({ left: 6 })
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
