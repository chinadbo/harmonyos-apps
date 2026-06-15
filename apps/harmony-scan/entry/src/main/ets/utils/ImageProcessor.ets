import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import { CropRegion, ImageMode } from '../model/DocumentModel';

export class ImageProcessor {
  static async loadPixelMap(filePath: string): Promise<image.PixelMap> {
    const source = image.createImageSource(filePath);
    return await source.createPixelMap({ editable: true });
  }

  static async cropPixelMap(pixelMap: image.PixelMap, region: CropRegion): Promise<image.PixelMap> {
    const info = await pixelMap.getImageInfo();
    const width = info.size.width;
    const height = info.size.height;
    const cropRegion = {
      x: Math.max(0, Math.min(region.x, width - 1)),
      y: Math.max(0, Math.min(region.y, height - 1)),
      size: {
        width: Math.max(1, Math.min(region.width, width)),
        height: Math.max(1, Math.min(region.height, height))
      }
    };
    await pixelMap.crop(cropRegion);
    return pixelMap;
  }

  static async applyMode(pixelMap: image.PixelMap, mode: ImageMode): Promise<image.PixelMap> {
    if (mode === ImageMode.COLOR) {
      return pixelMap;
    }
    const bytes = pixelMap.getPixelBytesNumber();
    const buffer = new ArrayBuffer(bytes);
    const pixels = new Uint8Array(buffer);
    await pixelMap.readPixelsToBuffer(buffer);
    for (let index = 0; index < pixels.length; index += 4) {
      const red = pixels[index];
      const green = pixels[index + 1];
      const blue = pixels[index + 2];
      const gray = Math.min(255, Math.floor(red * 0.299 + green * 0.587 + blue * 0.114));
      if (mode === ImageMode.BINARY) {
        const binary = gray > 160 ? 255 : 0;
        pixels[index] = binary;
        pixels[index + 1] = binary;
        pixels[index + 2] = binary;
      } else {
        pixels[index] = gray;
        pixels[index + 1] = gray;
        pixels[index + 2] = gray;
      }
    }
    await pixelMap.writeBufferToPixels(buffer);
    return pixelMap;
  }

  static async saveJpeg(pixelMap: image.PixelMap, outputPath: string, quality: number = 92): Promise<void> {
    const packer = image.createImagePacker();
    const packed = await packer.packing(pixelMap, { format: 'image/jpeg', quality: quality });
    const file = fs.openSync(outputPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
    fs.writeSync(file.fd, packed);
    fs.closeSync(file);
  }

  static async cropAndEnhance(inputPath: string, outputPath: string, region: CropRegion, mode: ImageMode): Promise<image.ImageInfo> {
    const pixelMap = await this.loadPixelMap(inputPath);
    await this.cropPixelMap(pixelMap, region);
    await this.applyMode(pixelMap, mode);
    await this.saveJpeg(pixelMap, outputPath);
    const info = await pixelMap.getImageInfo();
    pixelMap.release();
    return info;
  }
}
