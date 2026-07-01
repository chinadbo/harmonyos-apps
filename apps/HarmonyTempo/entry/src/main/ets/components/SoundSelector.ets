import { COLORS, SOUND_TYPES } from '../constants/AppConstants';

@Component
export struct SoundSelector {
  @Prop selected: string;
  onSelect?: (value: string) => void;

  build() {
    Column({ space: 12 }) {
      Text('Click Sound')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.textPrimary)

      Row({ space: 10 }) {
        ForEach(SOUND_TYPES, (item: string) => {
          Text(item.charAt(0).toUpperCase() + item.slice(1))
            .fontSize(16)
            .fontWeight(this.selected === item ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.selected === item ? COLORS.textPrimary : COLORS.textSecondary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.selected === item ? COLORS.primary : COLORS.surfaceAlt)
            .borderRadius(20)
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(item);
              }
            })
        })
      }
    }
    .padding(18)
    .backgroundColor(COLORS.surface)
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
