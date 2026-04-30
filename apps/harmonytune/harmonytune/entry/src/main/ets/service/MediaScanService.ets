import common from '@ohos.app.ability.common';
import fileUri from '@ohos.file.fileuri';
import fs from '@ohos.file.fs';
import { SongEntity } from '../model/SongEntity';
import { SongDao } from '../database/SongDao';
import { FormatUtils } from '../utils/FormatUtils';

export class MediaScanService {
  private static instance: MediaScanService = new MediaScanService();
  private songDao: SongDao = new SongDao();
  private supportExtensions: string[] = ['.mp3', '.flac', '.aac', '.wav', '.m4a'];

  static getInstance(): MediaScanService {
    return MediaScanService.instance;
  }

  async scanLocalMusic(context: common.UIAbilityContext): Promise<SongEntity[]> {
    try {
      const roots: string[] = this.getCandidateRoots(context);
      const collected: SongEntity[] = [];
      for (const root of roots) {
        const items = await this.walkDir(root);
        collected.push(...items);
      }
      const uniqueSongs: SongEntity[] = FormatUtils.uniqueByPath(collected);
      const finalSongs = uniqueSongs.length ? uniqueSongs : this.createMockSongs();
      await this.songDao.batchUpsert(context, finalSongs);
      AppStorage.setOrCreate('librarySongs', finalSongs.map((song: SongEntity) => song.clone()));
      return finalSongs;
    } catch (error) {
      console.error(`[MediaScanService] scanLocalMusic failed: ${JSON.stringify(error)}`);
      const mockSongs = this.createMockSongs();
      await this.songDao.batchUpsert(context, mockSongs);
      AppStorage.setOrCreate('librarySongs', mockSongs.map((song: SongEntity) => song.clone()));
      return mockSongs;
    }
  }

  private getCandidateRoots(context: common.UIAbilityContext): string[] {
    const roots: string[] = [];
    try {
      roots.push(context.filesDir);
    } catch (_error) {
    }
    try {
      const uri = fileUri.getUriFromPath('/storage/Users/currentUser/Music');
      roots.push(fileUri.getPathFromUri(uri));
    } catch (_error) {
    }
    roots.push('/storage/Users/currentUser/Download');
    return Array.from(new Set<string>(roots));
  }

  private async walkDir(root: string): Promise<SongEntity[]> {
    const songs: SongEntity[] = [];
    try {
      const stat = await fs.stat(root);
      if (!stat.isDirectory()) {
        return songs;
      }
      const entries = await fs.listFile(root, { recursion: true, listNum: 999 });
      let index: number = 1;
      for (const entry of entries) {
        const lowerPath = entry.toLowerCase();
        if (!this.supportExtensions.some((suffix: string) => lowerPath.endsWith(suffix))) {
          continue;
        }
        const title = this.extractName(entry);
        songs.push(new SongEntity({
          id: Date.now() + index,
          title,
          artist: index % 2 === 0 ? 'Harmony Artist' : 'Daily Waves',
          album: index % 2 === 0 ? 'Night Drive' : 'Morning Bloom',
          duration: 180000 + index * 5000,
          path: entry,
          coverPath: '',
          addedAt: Date.now() - index * 3600000,
          playCount: 0,
          isFavorite: false
        }));
        index++;
      }
    } catch (error) {
      console.warn(`[MediaScanService] walkDir skipped ${root}: ${JSON.stringify(error)}`);
    }
    return songs;
  }

  private extractName(path: string): string {
    const fileName = path.split('/').pop() || path;
    return fileName.replace(/\.[^.]+$/, '');
  }

  createMockSongs(): SongEntity[] {
    return [
      new SongEntity({ id: 1, title: 'Aurora Pulse', artist: 'Harmony Artist', album: 'Nebula Dreams', duration: 248000, path: 'mock://aurora-pulse.mp3', coverPath: '', addedAt: Date.now() - 1000, playCount: 5, isFavorite: true }),
      new SongEntity({ id: 2, title: 'Midnight Transit', artist: 'Catclaw Studio', album: 'Night Routes', duration: 221000, path: 'mock://midnight-transit.flac', coverPath: '', addedAt: Date.now() - 2000, playCount: 3, isFavorite: false }),
      new SongEntity({ id: 3, title: 'Blue Frequency', artist: 'OpenClaw', album: 'Daily Signals', duration: 206000, path: 'mock://blue-frequency.aac', coverPath: '', addedAt: Date.now() - 3000, playCount: 8, isFavorite: true }),
      new SongEntity({ id: 4, title: 'Sunrise Echo', artist: 'Harmony Artist', album: 'Morning Bloom', duration: 194000, path: 'mock://sunrise-echo.wav', coverPath: '', addedAt: Date.now() - 4000, playCount: 2, isFavorite: false }),
      new SongEntity({ id: 5, title: 'Glass Horizon', artist: 'Daily Waves', album: 'Sea of Light', duration: 233000, path: 'mock://glass-horizon.mp3', coverPath: '', addedAt: Date.now() - 5000, playCount: 7, isFavorite: false }),
      new SongEntity({ id: 6, title: 'Static Bloom', artist: 'OpenClaw', album: 'Daily Signals', duration: 259000, path: 'mock://static-bloom.mp3', coverPath: '', addedAt: Date.now() - 6000, playCount: 1, isFavorite: false }),
      new SongEntity({ id: 7, title: 'Neon Rain', artist: 'Catclaw Studio', album: 'Night Routes', duration: 241000, path: 'mock://neon-rain.mp3', coverPath: '', addedAt: Date.now() - 7000, playCount: 6, isFavorite: true }),
      new SongEntity({ id: 8, title: 'Paper Moonlight', artist: 'Daily Waves', album: 'Sea of Light', duration: 212000, path: 'mock://paper-moonlight.mp3', coverPath: '', addedAt: Date.now() - 8000, playCount: 4, isFavorite: false }),
      new SongEntity({ id: 9, title: 'Gravity Sleep', artist: 'Harmony Artist', album: 'Nebula Dreams', duration: 228000, path: 'mock://gravity-sleep.mp3', coverPath: '', addedAt: Date.now() - 9000, playCount: 9, isFavorite: true }),
      new SongEntity({ id: 10, title: 'White Noise Heart', artist: 'OpenClaw', album: 'Daily Signals', duration: 236000, path: 'mock://white-noise-heart.mp3', coverPath: '', addedAt: Date.now() - 10000, playCount: 0, isFavorite: false })
    ];
  }
}
