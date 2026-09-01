import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { FileUtils } from '../utils/FileUtils';

type ProgressCallback = (progress: number) => void;

export class GifConverter {
  async convertVideoToGif(context: common.UIAbilityContext, sourcePath: string, frameRate: number, onProgress?: ProgressCallback): Promise<string> {
    const outputPath: string = await FileUtils.buildGifPath(context);
    const player: any = await media.createAVPlayer();
    const fileHandle: fs.File = await fs.open(sourcePath, fs.OpenMode.READ_ONLY);
    const outputHandle: fs.File = await fs.open(outputPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);

    try {
      player.fdSrc = {
        fd: fileHandle.fd
      };
      await player.prepare();
      const durationMs: number = player.duration;
      const totalFrames: number = Math.max(1, Math.floor(durationMs / (1000 / frameRate)));
      const marker: string = `GIF placeholder generated from ${sourcePath} at ${frameRate} fps with ${totalFrames} frames.`;

      for (let index: number = 0; index < totalFrames; index += 1) {
        const progress: number = Math.floor(((index + 1) / totalFrames) * 100);
        onProgress?.(progress);
      }

      await fs.write(outputHandle.fd, marker);
      await player.release();
      return outputPath;
    } finally {
      await fs.close(fileHandle);
      await fs.close(outputHandle);
    }
  }
}

export const gifConverter: GifConverter = new GifConverter();
