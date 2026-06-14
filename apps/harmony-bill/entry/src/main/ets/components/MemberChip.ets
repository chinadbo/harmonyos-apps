import { ColorUtils } from '../utils/ColorUtils';

@Component
export struct MemberChip {
  @Prop name: string = '';
  @Prop colorIndex: number = 0;
  @Prop selected: boolean = false;

  build() {
    Row({ space: 8 }) {
      Text(ColorUtils.getInitial(this.name))
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFFFF')
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(ColorUtils.getColor(this.colorIndex))
        .borderRadius(16)
      Text(this.name)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
    }
    .padding({ left: 10, right: 12, top: 8, bottom: 8 })
    .backgroundColor(this.selected ? '#FFE8F1FF' : '#FFF9FAFB')
    .border({ width: 1, color: this.selected ? $r('app.color.brand_color') : $r('app.color.divider_color') })
    .borderRadius(18)
  }
}
