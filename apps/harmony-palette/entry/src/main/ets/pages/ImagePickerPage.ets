import { ColorModel } from '../model/ColorModel';
import { ImageColorPicker } from '../components/ImageColorPicker';
import { ColorExtractor } from '../utils/ColorExtractor';

@Component
export struct ImagePickerPage {
  @Link currentColor: ColorModel;
  @Link extractedColors: Array<ColorModel>;
  @State imageUri: string = '';
  @State loading: boolean = false;
  @State hintText: string = 'Pick an image to sample its dominant colors.';
  onColorSelected: (color: ColorModel) => void = () => {};
  onColorsExtracted: (colors: Array<ColorModel>) => void = () => {};
  onOpenDetail: (color: ColorModel) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  private async selectImage(): Promise<void> {
    try {
      this.loading = true;
      const uri = await ColorExtractor.pickImageUri();
      if (!uri) {
        this.hintText = 'Image selection was cancelled.';
        return;
      }
      this.imageUri = uri;
      const colors = await ColorExtractor.extractFromUri(uri, 8);
      this.extractedColors = colors;
      this.onColorsExtracted(colors);
      this.hintText = colors.length > 0 ? `Extracted ${colors.length} dominant colors.` : 'No dominant colors were detected.';
    } catch (error) {
      this.hintText = 'Failed to read colors from the selected image.';
    } finally {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('Image palette extraction')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text(this.hintText)
            .fontSize(14)
            .fontColor('#6B7280');
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%');

        Button(this.loading ? 'Analyzing...' : 'Choose Image')
          .enabled(!this.loading)
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#5B8CFF')
          .fontColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.selectImage();
          });

        ImageColorPicker({
          imageUri: this.imageUri,
          colors: this.extractedColors,
          currentColor: this.currentColor,
          onSelectColor: (color: ColorModel) => {
            this.currentColor = color;
            this.onColorSelected(color);
          },
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
