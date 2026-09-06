import { FilterPreset } from '../common/constants';
import { AppStyles } from '../common/styles';

@Component
export struct FilterItem {
  @Prop preset: FilterPreset;
  @Prop selected: boolean = false;
  @Prop onTap: () => void = () => {};

  build() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column() {
        }
        .width(96)
        .height(72)
        .borderRadius(AppStyles.radius.md)
        .backgroundColor(this.preset.previewColor)

        Text(this.preset.label)
          .fontSize(11)
          .fontColor('#FFFFFFFF')
          .backgroundColor('rgba(15,23,42,0.55)')
          .borderRadius(999)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ left: 8, bottom: 8 })
      }

      Text(this.preset.label)
        .fontSize(13)
        .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(AppStyles.colors.textPrimary)
        .maxLines(1)

      Text(this.preset.description)
        .fontSize(11)
        .fontColor(AppStyles.colors.textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(104)
    .padding(8)
    .backgroundColor(this.selected ? '#332563EB' : AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.md)
    .border({
      width: this.selected ? 1.5 : 1,
      color: this.selected ? AppStyles.colors.brandPrimary : AppStyles.colors.border
    })
    .onClick(() => this.onTap())
  }
}
