import image from '@ohos.multimedia.image';
import filePicker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { ColorModel } from '../model/ColorModel';
import { ColorConverter } from './ColorConverter';

interface PixelAggregate {
  red: number;
  green: number;
  blue: number;
  count: number;
}

export class ColorExtractor {
  static async pickImageUri(): Promise<string | null> {
    const picker = new filePicker.PhotoViewPicker();
    const options = new filePicker.PhotoSelectOptions();
    options.maxSelectNumber = 1;
    options.MIMEType = filePicker.PhotoViewMIMETypes.IMAGE_TYPE;
    const result = await picker.select(options);
    if (!result.photoUris || result.photoUris.length === 0) {
      return null;
    }
    return result.photoUris[0];
  }

  static async extractFromUri(uri: string, maxColors: number = 8): Promise<Array<ColorModel>> {
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    try {
      const imageSource = image.createImageSource(file.fd);
      const pixelMap = await imageSource.createPixelMap({ editable: false });
      const info = await pixelMap.getImageInfo();
      const bufferSize: number = info.size.width * info.size.height * 4;
      const buffer = new ArrayBuffer(bufferSize);
      await pixelMap.readPixels(buffer);
      return this.extractDominantColors(new Uint8Array(buffer), info.size.width, info.size.height, maxColors);
    } finally {
      fs.closeSync(file);
    }
  }

  private static extractDominantColors(buffer: Uint8Array, width: number, height: number, maxColors: number): Array<ColorModel> {
    const sampleGap: number = Math.max(1, Math.floor(Math.sqrt((width * height) / 2400)));
    const palette = new Map<string, PixelAggregate>();
    for (let y = 0; y < height; y += sampleGap) {
      for (let x = 0; x < width; x += sampleGap) {
        const index: number = (y * width + x) * 4;
        const red: number = buffer[index];
        const green: number = buffer[index + 1];
        const blue: number = buffer[index + 2];
        const alpha: number = buffer[index + 3];
        if (alpha < 120) {
          continue;
        }
        const key: string = `${Math.floor(red / 24)}-${Math.floor(green / 24)}-${Math.floor(blue / 24)}`;
        const current: PixelAggregate | undefined = palette.get(key);
        if (current) {
          current.red += red;
          current.green += green;
          current.blue += blue;
          current.count += 1;
        } else {
          palette.set(key, { red, green, blue, count: 1 });
        }
      }
    }

    return Array.from(palette.values())
      .sort((left: PixelAggregate, right: PixelAggregate) => right.count - left.count)
      .slice(0, maxColors)
      .map((aggregate: PixelAggregate, index: number) => {
        const red: number = Math.round(aggregate.red / aggregate.count);
        const green: number = Math.round(aggregate.green / aggregate.count);
        const blue: number = Math.round(aggregate.blue / aggregate.count);
        return ColorConverter.fromRgba(red, green, blue, 255, `Extracted ${index + 1}`);
      });
  }
}
