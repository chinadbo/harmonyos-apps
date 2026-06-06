import { ColorModel } from '../model/ColorModel';
import { PaletteScheme } from '../model/PaletteScheme';
import { PaletteGrid } from '../components/PaletteGrid';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct PalettePage {
  @Link currentColor: ColorModel;
  @Link paletteSchemes: Array<PaletteScheme>;
  onOpenDetail: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  aboutToAppear(): void {
    this.paletteSchemes = ColorConverter.paletteSchemes(this.currentColor);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('Palette design studio')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text(`Palette source: ${this.currentColor.hex}`)
            .fontSize(14)
            .fontColor('#6B7280');
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%');

        PaletteGrid({
          baseColor: this.currentColor,
          schemes: this.paletteSchemes,
          onOpenDetail: this.onOpenDetail,
          onSave: this.onSave,
          onCopy: this.onCopy
        });
      }
      .padding(16)
      .width('100%');
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F6F7FB');
  }
}
