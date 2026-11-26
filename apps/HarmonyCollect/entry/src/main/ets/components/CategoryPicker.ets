/**
 * CategoryPicker.ets — 品类选择（动态品类）
 */
import { Category } from '../model/Category';
import { categoryColor, C_SUB, C_LINE, C_CARD } from '../common/Constants';

@Component
export struct CategoryPicker {
  @Prop categories: Category[] = [];
  @Prop selected: string = 'other';
  onChange: (key: string) => void = (key: string) => {};

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      ForEach(this.categories, (cat: Category) => {
        Row() {
          Text(cat.icon)
            .fontSize(13)
            .fontColor(this.selected === cat.key ? 0xFFFFFF : categoryColor(cat.key))
            .margin({ right: 4 })
          Text(cat.name)
            .fontSize(13)
            .fontColor(this.selected === cat.key ? 0xFFFFFF : C_SUB)
        }
        .padding({ left: 14, right: 14, top: 7, bottom: 7 })
        .margin({ right: 8, bottom: 8 })
        .borderRadius(16)
        .backgroundColor(this.selected === cat.key ? categoryColor(cat.key) : C_CARD)
        .border({ width: 1, color: this.selected === cat.key ? categoryColor(cat.key) : C_LINE })
        .onClick(() => this.onChange(cat.key))
      }, (cat: Category) => cat.key)
    }
    .width('100%')
  }
}
