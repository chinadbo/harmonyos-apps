import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct ColorCard {
  color: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  title: string = 'Color';
  subtitle: string = '';
  onOpenDetail: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};

  build() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Column() {
        }
        .width(72)
        .height(72)
        .borderRadius(20)
        .backgroundColor(this.color.argb);

        Column({ space: 4 }) {
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text(this.color.hex)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#374151');
          if (this.subtitle.length > 0) {
            Text(this.subtitle)
              .fontSize(13)
              .fontColor('#6B7280')
              .maxLines(2);
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      Row({ space: 8 }) {
        Button('Details')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#111827')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.onOpenDetail(this.color);
          });
        Button('Copy')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#E5E7EB')
          .fontColor('#111827')
          .borderRadius(12)
          .onClick(() => {
            this.onCopy(this.color);
          });
        Button('Save')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#5B8CFF')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.onSave(this.color);
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(22);
  }
}
