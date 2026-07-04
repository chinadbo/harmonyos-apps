import { TorchMode, MODE_LABELS, MODE_ICONS } from '../models/TorchMode';

@Component
export struct ModeCard {
  @Prop mode: TorchMode;
  @Prop isSelected: boolean;
  onSelect?: (mode: TorchMode) => void;

  build() {
    Column() {
      Text(MODE_ICONS[this.mode])
        .fontSize(40)
        .margin({ bottom: 8 })

      Text(MODE_LABELS[this.mode])
        .fontSize(16)
        .fontColor(this.isSelected ? '#FFD700' : '#FFFFFF')
        .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height(120)
    .backgroundColor('#1E1E1E')
    .borderRadius(12)
    .border({
      width: this.isSelected ? 2 : 0,
      color: '#FFD700',
      style: BorderStyle.Solid
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.onSelect) {
        this.onSelect(this.mode);
      }
    })
  }
}
