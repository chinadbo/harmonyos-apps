import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { RecordingFile } from '../model/RecordingFile';

export class FileUtils {
  static readonly RECORDING_DIR_NAME: string = 'recordings';
  static readonly GIF_DIR_NAME: string = 'gifs';
  static readonly THUMBNAIL_DIR_NAME: string = 'thumbnails';

  static async ensureAppSubDir(context: common.UIAbilityContext, dirName: string): Promise<string> {
    const baseDir: string = context.filesDir;
    const fullPath: string = `${baseDir}/${dirName}`;
    try {
      await fs.access(fullPath);
    } catch (_) {
      await fs.mkdir(fullPath);
    }
    return fullPath;
  }

  static async getRecordingDir(context: common.UIAbilityContext): Promise<string> {
    return this.ensureAppSubDir(context, this.RECORDING_DIR_NAME);
  }

  static async getGifDir(context: common.UIAbilityContext): Promise<string> {
    return this.ensureAppSubDir(context, this.GIF_DIR_NAME);
  }

  static async getThumbnailDir(context: common.UIAbilityContext): Promise<string> {
    return this.ensureAppSubDir(context, this.THUMBNAIL_DIR_NAME);
  }

  static createTimestampedName(prefix: string, extension: string): string {
    const now: Date = new Date();
    const safeTimestamp: string = now.toISOString().replace(/[:.]/g, '-');
    return `${prefix}_${safeTimestamp}.${extension}`;
  }

  static async buildRecordingPath(context: common.UIAbilityContext): Promise<string> {
    const recordingDir: string = await this.getRecordingDir(context);
    return `${recordingDir}/${this.createTimestampedName('recording', 'mp4')}`;
  }

  static async buildGifPath(context: common.UIAbilityContext): Promise<string> {
    const gifDir: string = await this.getGifDir(context);
    return `${gifDir}/${this.createTimestampedName('recording', 'gif')}`;
  }

  static async buildThumbnailPath(context: common.UIAbilityContext, recordingId: string): Promise<string> {
    const thumbnailDir: string = await this.getThumbnailDir(context);
    return `${thumbnailDir}/${recordingId}.jpg`;
  }

  static async listRecordings(context: common.UIAbilityContext): Promise<Array<RecordingFile>> {
    const recordingDir: string = await this.getRecordingDir(context);
    let fileNames: Array<string> = [];
    try {
      fileNames = await fs.listFile(recordingDir);
    } catch (_) {
      return [];
    }

    const items: Array<RecordingFile> = [];
    for (const fileName of fileNames) {
      const filePath: string = `${recordingDir}/${fileName}`;
      try {
        const stat: fs.Stat = await fs.stat(filePath);
        items.push({
          id: fileName,
          name: fileName,
          path: filePath,
          thumbnailPath: '',
          duration: 0,
          size: Number(stat.size),
          createdAt: new Date(Number(stat.mtime)).toISOString()
        });
      } catch (_) {
      }
    }

    return items.sort((left: RecordingFile, right: RecordingFile) => {
      return new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime();
    });
  }

  static async removeFile(filePath: string): Promise<void> {
    try {
      await fs.unlink(filePath);
    } catch (_) {
    }
  }
}
