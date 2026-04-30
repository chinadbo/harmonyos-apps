import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import util from '@ohos.util';
import { SongInfo } from '../model/SongInfo';

/**
 * MediaScanner — 本地音乐文件扫描服务
 *
 * P0 修复（2026-04-30）：
 * - 移除不存在的 fs.ListFileIterator 用法，改用 fs.listFile() 返回 string[]
 * - 移除不存在的 media.fetchAVFileDescriptor，改用 AVMetadataExtractor 获取 duration
 */
export class MediaScanner {
  private static instance: MediaScanner = new MediaScanner();
  private readonly extensions: string[] = ['.mp3', '.flac', '.wav', '.m4a', '.ogg'];

  static getInstance(): MediaScanner {
    return MediaScanner.instance;
  }

  async scanDirectory(directoryPath: string): Promise<SongInfo[]> {
    const result: SongInfo[] = [];
    await this.walk(directoryPath, result);
    result.sort((left: SongInfo, right: SongInfo) => left.title.localeCompare(right.title));
    return result;
  }

  private async walk(directoryPath: string, songs: SongInfo[]): Promise<void> {
    try {
      // fs.listFile 返回 string[]（文件名列表），不是迭代器
      const fileNames: string[] = fs.listFileSync(directoryPath);
      for (const fileName of fileNames) {
        const childPath: string = `${directoryPath}/${fileName}`;
        try {
          const stat = fs.statSync(childPath);
          if (stat.isDirectory()) {
            await this.walk(childPath, songs);
          } else if (this.isAudioFile(fileName)) {
            songs.push(await this.createSong(childPath, fileName));
          }
        } catch (_statError) {
          // 无法 stat 的文件跳过
        }
      }
    } catch (error) {
      console.error(`[MediaScanner] walk failed for ${directoryPath}: ${JSON.stringify(error)}`);
    }
  }

  private isAudioFile(fileName: string): boolean {
    const lowerCaseName: string = fileName.toLowerCase();
    return this.extensions.some((extension: string) => lowerCaseName.endsWith(extension));
  }

  private async createSong(filePath: string, fileName: string): Promise<SongInfo> {
    const song: SongInfo = new SongInfo();
    const parsed = this.parseTitleAndArtist(fileName.replace(/\.[^.]+$/, ''));
    song.id = this.hash(filePath);
    song.title = parsed.title;
    song.artist = parsed.artist;
    song.album = '未知专辑';
    song.uri = filePath;
    song.coverUri = '';
    song.lyricPath = filePath.replace(/\.[^.]+$/, '.lrc');
    song.duration = await this.readDuration(filePath);
    return song;
  }

  private parseTitleAndArtist(fileName: string): { title: string; artist: string } {
    const segments: string[] = fileName.split('-').map((item: string) => item.trim()).filter(Boolean);
    if (segments.length >= 2) {
      return {
        artist: segments[0],
        title: segments.slice(1).join(' - ')
      };
    }
    return {
      artist: '未知歌手',
      title: fileName
    };
  }

  /**
   * 使用 AVMetadataExtractor 读取音频时长
   * 替代已废弃 / 不存在的 media.fetchAVFileDescriptor
   */
  private async readDuration(filePath: string): Promise<number> {
    let extractor: media.AVMetadataExtractor | undefined;
    try {
      extractor = await media.createAVMetadataExtractor();
      // 打开文件描述符
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      extractor.fd = file.fd;
      const metadata = await extractor.fetchMetadata();
      fs.closeSync(file);
      const durationStr = metadata.duration;
      return durationStr !== undefined ? Number(durationStr) : 0;
    } catch (_error) {
      return 0;
    } finally {
      try {
        await extractor?.release();
      } catch (_e) { /* ignore */ }
    }
  }

  private hash(text: string): number {
    let hashValue: number = 0;
    for (let i = 0; i < text.length; i++) {
      hashValue = (hashValue * 31 + text.charCodeAt(i)) | 0;
    }
    return Math.abs(hashValue);
  }
}
