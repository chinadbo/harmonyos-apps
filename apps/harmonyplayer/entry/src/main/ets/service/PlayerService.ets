import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';
import { SongInfo } from '../model/SongInfo';
import { PlayMode } from '../model/PlayMode';
import { LyricLine } from '../model/LyricLine';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { LyricParser } from './LyricParser';
import { AVSessionManager } from './AVSessionManager';
import { HistoryStore } from '../database/HistoryStore';

export class PlayerService {
  private static instance: PlayerService = new PlayerService();
  private player: media.AVPlayer | null = null;
  private playerState: string = 'idle';
  private queue: SongInfo[] = [];
  private currentIndex: number = -1;
  private lyrics: LyricLine[] = [];
  private context: common.UIAbilityContext | null = null;
  private historyStore: HistoryStore = new HistoryStore();

  static getInstance(): PlayerService {
    return PlayerService.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<PlayerService> {
    this.context = context;
    PlayerViewModel.initializeDefaults();
    await this.ensurePlayer(true);
    return this;
  }

  getQueue(): SongInfo[] {
    return this.queue;
  }

  getCurrentSong(): SongInfo | null {
    if (this.currentIndex < 0 || this.currentIndex >= this.queue.length) {
      return null;
    }
    return this.queue[this.currentIndex];
  }

  async setQueue(queue: SongInfo[], startIndex: number = 0): Promise<void> {
    this.queue = queue;
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_QUEUE, this.queue);
    if (queue.length === 0) {
      this.currentIndex = -1;
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_SONG, null as SongInfo | null);
      return;
    }
    this.currentIndex = Math.max(0, Math.min(startIndex, queue.length - 1));
  }

  async playSong(song: SongInfo, queue?: SongInfo[]): Promise<void> {
    if (queue !== undefined && queue.length > 0) {
      await this.setQueue(queue, queue.findIndex((item: SongInfo) => item.uri === song.uri));
    }
    const targetIndex: number = this.queue.findIndex((item: SongInfo) => item.uri === song.uri);
    if (targetIndex >= 0) {
      await this.playAt(targetIndex);
      return;
    }
    this.queue = [song];
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_QUEUE, this.queue);
    await this.playAt(0);
  }

  async playAt(index: number): Promise<void> {
    if (index < 0 || index >= this.queue.length) {
      return;
    }
    this.currentIndex = index;
    const song: SongInfo = this.queue[index];
    await this.ensurePlayer(true);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_SONG, song);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_TOTAL_TIME, song.duration);
    await this.loadLyrics(song.lyricPath);
    await AVSessionManager.getInstance().setAVMetadata(song);
    if (this.player !== null) {
      this.player.url = song.uri;
    }
    await this.historyStore.addHistory(song.uri);
  }

  async play(): Promise<void> {
    const currentSong: SongInfo | null = this.getCurrentSong();
    if (currentSong === null && this.queue.length > 0) {
      await this.playAt(0);
      return;
    }
    if (this.playerState === 'paused' && this.player !== null) {
      await this.player.play();
      return;
    }
    if (currentSong !== null && this.playerState === 'idle') {
      await this.playAt(this.currentIndex);
    }
  }

  async pause(): Promise<void> {
    if (this.player !== null && this.playerState === 'playing') {
      await this.player.pause();
    }
  }

  async stop(): Promise<void> {
    if (this.player !== null) {
      await this.player.stop();
    }
    this.playerState = 'stopped';
    AppStorage.setOrCreate(PlayerViewModel.KEY_IS_PLAYING, false);
  }

  async togglePlayPause(): Promise<void> {
    if (AppStorage.get(PlayerViewModel.KEY_IS_PLAYING) as boolean) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  async seekTo(ms: number): Promise<void> {
    if (this.player !== null) {
      await this.player.seek(ms);
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, ms);
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_LYRIC_INDEX, LyricParser.findCurrentLine(this.lyrics, ms));
      await AVSessionManager.getInstance().setAVPlaybackState(AppStorage.get(PlayerViewModel.KEY_IS_PLAYING) as boolean, ms);
    }
  }

  async next(): Promise<void> {
    if (this.queue.length === 0) {
      return;
    }
    const mode: PlayMode = AppStorage.get(PlayerViewModel.KEY_PLAY_MODE) as PlayMode;
    if (mode === PlayMode.SHUFFLE) {
      await this.playAt(Math.floor(Math.random() * this.queue.length));
      return;
    }
    if (this.currentIndex + 1 >= this.queue.length) {
      if (mode === PlayMode.REPEAT_ALL) {
        await this.playAt(0);
      }
      return;
    }
    await this.playAt(this.currentIndex + 1);
  }

  async previous(): Promise<void> {
    if (this.queue.length === 0) {
      return;
    }
    if (this.currentIndex - 1 < 0) {
      await this.playAt(0);
      return;
    }
    await this.playAt(this.currentIndex - 1);
  }

  async clearQueue(): Promise<void> {
    this.queue = [];
    this.currentIndex = -1;
    this.lyrics = [];
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_QUEUE, [] as SongInfo[]);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_SONG, null as SongInfo | null);
    AppStorage.setOrCreate(PlayerViewModel.KEY_LYRIC_LINES, [] as LyricLine[]);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_TOTAL_TIME, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_LYRIC_INDEX, 0);
    AppStorage.setOrCreate(PlayerViewModel.KEY_IS_PLAYING, false);
    await this.stop();
  }

  async setPlayMode(mode: PlayMode): Promise<void> {
    AppStorage.setOrCreate(PlayerViewModel.KEY_PLAY_MODE, mode);
  }

  private async ensurePlayer(recreate: boolean): Promise<void> {
    if (!recreate && this.player !== null) {
      return;
    }
    if (this.player !== null) {
      try {
        await this.player.release();
      } catch (_error) {
      }
    }
    this.player = await media.createAVPlayer();
    this.playerState = 'idle';
    this.bindPlayerEvents(this.player);
  }

  private bindPlayerEvents(player: media.AVPlayer): void {
    player.on('stateChange', async (state: string) => {
      this.playerState = state;
      if (state === 'initialized') {
        await player.prepare();
      } else if (state === 'prepared') {
        await player.play();
      } else if (state === 'playing') {
        AppStorage.setOrCreate(PlayerViewModel.KEY_IS_PLAYING, true);
        await AVSessionManager.getInstance().setAVPlaybackState(true, AppStorage.get(PlayerViewModel.KEY_CURRENT_TIME) as number);
      } else if (state === 'paused') {
        AppStorage.setOrCreate(PlayerViewModel.KEY_IS_PLAYING, false);
        await AVSessionManager.getInstance().setAVPlaybackState(false, AppStorage.get(PlayerViewModel.KEY_CURRENT_TIME) as number);
      } else if (state === 'completed') {
        await this.handleCompletion();
      }
    });
    player.on('timeUpdate', async (timeMs: number) => {
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_TIME, timeMs);
      if (player.duration > 0) {
        AppStorage.setOrCreate(PlayerViewModel.KEY_TOTAL_TIME, player.duration);
      }
      const lineIndex: number = LyricParser.findCurrentLine(this.lyrics, timeMs);
      AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_LYRIC_INDEX, lineIndex);
      await AVSessionManager.getInstance().setAVPlaybackState(AppStorage.get(PlayerViewModel.KEY_IS_PLAYING) as boolean, timeMs);
    });
    // P1 修复：移除 endOfStream 监听，仅依赖 stateChange 中的 completed 状态防止双重触发
    player.on('error', (error: Object) => {
      console.error(`player error: ${JSON.stringify(error)}`);
    });
  }

  private async handleCompletion(): Promise<void> {
    const mode: PlayMode = AppStorage.get(PlayerViewModel.KEY_PLAY_MODE) as PlayMode;
    if (mode === PlayMode.REPEAT_ONE) {
      await this.playAt(this.currentIndex);
      return;
    }
    await this.next();
  }

  private async loadLyrics(lyricPath: string): Promise<void> {
    this.lyrics = [];
    try {
      const stat = await fs.stat(lyricPath);
      if (stat !== null) {
        const file = await fs.open(lyricPath, fs.OpenMode.READ_ONLY);
        const buffer = new ArrayBuffer(stat.size);
        await fs.read(file.fd, buffer);
        await fs.close(file);
        const decoder = new util.TextDecoder('utf-8', { ignoreBOM: true });
        const content = decoder.decodeWithStream(new Uint8Array(buffer));
        this.lyrics = LyricParser.parse(content);
      }
    } catch (_error) {
      this.lyrics = [];
    }
    AppStorage.setOrCreate(PlayerViewModel.KEY_LYRIC_LINES, this.lyrics);
    AppStorage.setOrCreate(PlayerViewModel.KEY_CURRENT_LYRIC_INDEX, 0);
  }
}
