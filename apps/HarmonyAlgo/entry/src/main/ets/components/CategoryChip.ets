import { Theme } from '../common/Theme';

/** 分类筛选胶囊 */
@Component
export struct CategoryChip {
  @Prop label: string = '';
  @Prop selected: boolean = false;
  onSelect: () => void = () => {
  };

  build() {
    Text(this.label)
      .fontSize(13)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.selected ? '#FFFFFF' : Theme.text)
      .backgroundColor(this.selected ? Theme.primary : Theme.card)
      .borderRadius(16)
      .border({ width: 1, color: this.selected ? Theme.primary : Theme.border })
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .onClick(() => {
        this.onSelect();
      })
  }
}
