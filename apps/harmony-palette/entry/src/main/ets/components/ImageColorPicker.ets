import { ColorModel } from '../model/ColorModel';
import { ColorCard } from './ColorCard';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct ImageColorPicker {
  imageUri: string = '';
  colors: Array<ColorModel> = [];
  currentColor: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  onSelectColor: (color: ColorModel) => void = () => {};
  onOpenDetail: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  build() {
    Column({ space: 16 }) {
      if (this.imageUri.length > 0) {
        Image(this.imageUri)
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(24);
      } else {
        Column({ space: 8 }) {
          Text('No image selected')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827');
          Text('Choose a photo to extract dominant colors and turn them into palettes.')
            .fontSize(13)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center);
        }
        .width('100%')
        .padding(28)
        .backgroundColor(Color.White)
        .borderRadius(24)
        .alignItems(HorizontalAlign.Center);
      }

      if (this.colors.length > 0) {
        Column({ space: 12 }) {
          Text('Detected colors')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .width('100%');

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.colors, (color: ColorModel) => {
              Column({ space: 8 }) {
                Stack({ alignContent: Alignment.BottomEnd }) {
                  Column() {
                  }
                  .width('100%')
                  .height(82)
                  .borderRadius(18)
                  .backgroundColor(color.argb)
                  .onClick(() => {
                    this.onSelectColor(color);
                  });

                  if (this.currentColor.hex === color.hex) {
                    Text('Active')
                      .fontSize(10)
                      .fontColor(Color.White)
                      .backgroundColor('#111827')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(12)
                      .margin({ right: 8, bottom: 8 });
                  }
                }
                .width('100%');

                Text(color.hex)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111827');
              }
              .width('31%')
              .margin({ bottom: 12 });
            }, (color: ColorModel) => color.hex);
          }
          .width('100%');

          ColorCard({
            color: this.currentColor,
            title: 'Current extracted color',
            subtitle: `${ColorConverter.rgbString(this.currentColor)} · ${ColorConverter.hsvString(this.currentColor)}`,
            onOpenDetail: this.onOpenDetail,
            onCopy: this.onCopy,
            onSave: this.onSave
          });
        }
        .width('100%');
      }
    }
    .width('100%');
  }
}
