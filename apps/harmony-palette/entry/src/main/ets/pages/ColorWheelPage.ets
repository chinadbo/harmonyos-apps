import { ColorWheel } from '../components/ColorWheel';
import { ColorCard } from '../components/ColorCard';
import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct ColorWheelPage {
  @Link currentColor: ColorModel;
  onColorSelected: (color: ColorModel) => void = () => {};
  onOpenDetail: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('Interactive HSV wheel')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text('Drag on the canvas to set hue and saturation, then inspect or save the selected tone.')
            .fontSize(14)
            .fontColor('#6B7280');
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%');

        ColorWheel({
          currentColor: this.currentColor,
          onColorChange: (color: ColorModel) => {
            this.currentColor = color;
            this.onColorSelected(color);
          }
        });

        ColorCard({
          color: this.currentColor,
          title: 'Selected Color',
          subtitle: `${ColorConverter.rgbString(this.currentColor)} · ${ColorConverter.hsvString(this.currentColor)}`,
          onOpenDetail: this.onOpenDetail,
          onCopy: this.onCopy,
          onSave: this.onSave
        });
      }
      .padding(16)
      .width('100%');
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F6F7FB');
  }
}
