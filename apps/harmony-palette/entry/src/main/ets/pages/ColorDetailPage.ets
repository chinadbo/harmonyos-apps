import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from '../utils/ColorConverter';

@Component
export struct ColorDetailPage {
  color: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  onBack: () => void = () => {};
  onCopy: () => void = () => {};
  onSave: () => void = () => {};

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('Back')
            .height(40)
            .fontSize(14)
            .backgroundColor('#E5E7EB')
            .fontColor('#111827')
            .borderRadius(12)
            .onClick(() => {
              this.onBack();
            });
          Blank();
        }
        .width('100%');

        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }
          .width('100%')
          .height(220)
          .borderRadius(28)
          .backgroundColor(this.color.argb);

          Column({ space: 8 }) {
            Text(this.color.displayName())
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(ColorConverter.contrastColor(this.color.argb));
            Text(this.color.hex)
              .fontSize(18)
              .fontColor(ColorConverter.contrastColor(this.color.argb));
          }
        }
        .width('100%');

        Column({ space: 12 }) {
          this.infoRow('HEX', this.color.hex);
          this.infoRow('RGB', ColorConverter.rgbString(this.color));
          this.infoRow('RGBA', ColorConverter.rgbaString(this.color));
          this.infoRow('HSV', ColorConverter.hsvString(this.color));
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24);

        Row({ space: 12 }) {
          Button('Copy')
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .backgroundColor('#111827')
            .fontColor(Color.White)
            .borderRadius(16)
            .onClick(() => {
              this.onCopy();
            });
          Button('Save')
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .backgroundColor('#5B8CFF')
            .fontColor(Color.White)
            .borderRadius(16)
            .onClick(() => {
              this.onSave();
            });
        }
        .width('100%');
      }
      .padding(16)
      .width('100%');
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F6F7FB');
  }

  @Builder
  private infoRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#6B7280');
      Blank();
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827');
    }
    .width('100%');
  }
}
