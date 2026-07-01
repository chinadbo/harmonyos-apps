import { COLORS, TIME_SIGNATURES } from '../constants/AppConstants';

@Component
export struct TimeSignatureSelector {
  @Prop selected: string;
  onSelect?: (value: string) => void;

  build() {
    Column({ space: 12 }) {
      Text('Time Signature')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.textPrimary)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        ForEach(TIME_SIGNATURES, (item: string) => {
          Text(item)
            .fontSize(16)
            .fontWeight(this.selected === item ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.selected === item ? COLORS.textPrimary : COLORS.textSecondary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .margin({ right: 10, bottom: 10 })
            .backgroundColor(this.selected === item ? COLORS.primary : COLORS.surfaceAlt)
            .borderRadius(20)
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(item);
              }
            })
        })
      }
      .width('100%')
    }
    .padding(18)
    .backgroundColor(COLORS.surface)
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }
}
