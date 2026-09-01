import media from '@ohos.multimedia.media';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';

export class ThumbnailUtils {
  static async createVideoThumbnail(videoPath: string, outputPath: string): Promise<string> {
    const extractor: any = await media.createAVMetadataExtractor();
    const fileHandle: fs.File = await fs.open(videoPath, fs.OpenMode.READ_ONLY);
    const outputHandle: fs.File = await fs.open(outputPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);

    try {
      extractor.fdSrc = {
        fd: fileHandle.fd
      };
      const pixelMap: any = await extractor.fetchVideoScaledPixelMapByTime(0, -1, {
        width: 360,
        height: 240
      });
      const imagePacker: any = image.createImagePacker();
      const packed: ArrayBuffer = await imagePacker.packing(pixelMap, {
        format: 'image/jpeg',
        quality: 80
      });
      await fs.write(outputHandle.fd, packed);
      return outputPath;
    } finally {
      extractor.release();
      await fs.close(fileHandle);
      await fs.close(outputHandle);
    }
  }
}
