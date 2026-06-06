import { ColorModel } from '../model/ColorModel';
import { PaletteScheme } from '../model/PaletteScheme';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct PaletteGrid {
  baseColor: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  schemes: Array<PaletteScheme> = [];
  onOpenDetail: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  build() {
    Column({ space: 14 }) {
      ForEach(this.schemes, (scheme: PaletteScheme) => {
        Column({ space: 12 }) {
          Column({ space: 4 }) {
            Text(scheme.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827');
            Text(scheme.description)
              .fontSize(13)
              .fontColor('#6B7280');
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%');

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(scheme.colors, (color: ColorModel) => {
              Column({ space: 8 }) {
                Column() {
                }
                .width('100%')
                .height(92)
                .borderRadius(18)
                .backgroundColor(color.argb)
                .onClick(() => {
                  this.onOpenDetail(color);
                });

                Text(color.hex)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111827');

                Row({ space: 6 }) {
                  Button('Copy')
                    .layoutWeight(1)
                    .height(32)
                    .fontSize(12)
                    .backgroundColor('#E5E7EB')
                    .fontColor('#111827')
                    .borderRadius(10)
                    .onClick(() => {
                      this.onCopy(color);
                    });
                  Button('Save')
                    .layoutWeight(1)
                    .height(32)
                    .fontSize(12)
                    .backgroundColor('#5B8CFF')
                    .fontColor(Color.White)
                    .borderRadius(10)
                    .onClick(() => {
                      this.onSave(color);
                    });
                }
                .width('100%');
              }
              .width('48%')
              .margin({ bottom: 12 });
            }, (color: ColorModel) => `${scheme.name}-${color.hex}`);
          }
          .width('100%');
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24);
      }, (scheme: PaletteScheme) => scheme.name);
    }
    .width('100%');
  }
}
