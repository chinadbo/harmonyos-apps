import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import { SongEntity } from '../model/SongEntity';
import { SongDao } from '../database/SongDao';
import { AVSessionService } from './AVSessionService';

export enum PlayerStatus {
  IDLE = 'Idle',
  PREPARED = 'Prepared',
  PLAYING = 'Playing',
  PAUSED = 'Paused',
  STOPPED = 'Stopped'
}

export enum PlayMode {
  SEQUENCE = 0,
  SHUFFLE = 1,
  REPEAT_ONE = 2
}

@ObservedV2
export class PlayerState {
  status: PlayerStatus = PlayerStatus.IDLE;
  currentSong: SongEntity = SongEntity.empty();
  currentTime: number = 0;
  duration: number = 0;
  isPlaying: boolean = false;
  playMode: PlayMode = PlayMode.SEQUENCE;
  queue: SongEntity[] = [];
  queueIndex: number = -1;
  recentSongs: SongEntity[] = [];

  constructor(init?: Partial<PlayerState>) {
    Object.assign(this, init);
  }
}

export class PlayerService {
  private static instance: PlayerService = new PlayerService();
  private avPlayer?: media.AVPlayer;
  private playerState: PlayerState = new PlayerState();
  private songDao: SongDao = new SongDao();
  private avSessionService: AVSessionService = AVSessionService.getInstance();
  private context?: common.UIAbilityContext;
  private listenersBound: boolean = false;

  private constructor() {
    this.bootstrapStorage();
  }

  static getInstance(): PlayerService {
    return PlayerService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    await this.ensurePlayer();
    await this.avSessionService.init(context);
  }

  getState(): PlayerState {
    return this.playerState;
  }

  setQueue(queue: SongEntity[], index: number = 0): void {
    this.playerState.queue = queue.map((song: SongEntity) => song.clone());
    this.playerState.queueIndex = queue.length ? Math.max(0, Math.min(index, queue.length - 1)) : -1;
    this.syncStorage();
  }

  async play(song: SongEntity): Promise<void> {
    try {
      const player = await this.ensurePlayer();
      this.playerState.currentSong = song.clone();
      this.playerState.currentTime = 0;
      this.playerState.duration = song.duration;
      this.playerState.status = PlayerStatus.IDLE;
      player.url = song.path;
      player.prepare();
      this.updateRecentSongs(song);
      this.syncStorage();
    } catch (error) {
      console.error(`[PlayerService] play failed: ${JSON.stringify(error)}`);
    }
  }

  async pause(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.pause();
      this.playerState.status = PlayerStatus.PAUSED;
      this.playerState.isPlaying = false;
      this.syncStorage();
      await this.avSessionService.updatePlaybackState(false, this.playerState.currentTime, this.playerState.playMode);
    } catch (error) {
      console.error(`[PlayerService] pause failed: ${JSON.stringify(error)}`);
    }
  }

  async resume(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.play();
      this.playerState.status = PlayerStatus.PLAYING;
      this.playerState.isPlaying = true;
      this.syncStorage();
      await this.avSessionService.updatePlaybackState(true, this.playerState.currentTime, this.playerState.playMode);
    } catch (error) {
      console.error(`[PlayerService] resume failed: ${JSON.stringify(error)}`);
    }
  }

  async stop(): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.stop();
      this.playerState.status = PlayerStatus.STOPPED;
      this.playerState.isPlaying = false;
      this.playerState.currentTime = 0;
      this.syncStorage();
      await this.avSessionService.updatePlaybackState(false, 0, this.playerState.playMode);
    } catch (error) {
      console.error(`[PlayerService] stop failed: ${JSON.stringify(error)}`);
    }
  }

  async next(): Promise<void> {
    if (!this.playerState.queue.length) {
      return;
    }
    let nextIndex = this.playerState.queueIndex;
    if (this.playerState.playMode === PlayMode.SHUFFLE) {
      nextIndex = Math.floor(Math.random() * this.playerState.queue.length);
    } else if (this.playerState.playMode === PlayMode.REPEAT_ONE) {
      nextIndex = this.playerState.queueIndex < 0 ? 0 : this.playerState.queueIndex;
    } else {
      nextIndex = (this.playerState.queueIndex + 1 + this.playerState.queue.length) % this.playerState.queue.length;
    }
    this.playerState.queueIndex = nextIndex;
    await this.play(this.playerState.queue[nextIndex]);
  }

  async prev(): Promise<void> {
    if (!this.playerState.queue.length) {
      return;
    }
    let prevIndex = this.playerState.queueIndex;
    if (this.playerState.playMode === PlayMode.SHUFFLE) {
      prevIndex = Math.floor(Math.random() * this.playerState.queue.length);
    } else if (this.playerState.playMode === PlayMode.REPEAT_ONE) {
      prevIndex = this.playerState.queueIndex < 0 ? 0 : this.playerState.queueIndex;
    } else {
      prevIndex = (this.playerState.queueIndex - 1 + this.playerState.queue.length) % this.playerState.queue.length;
    }
    this.playerState.queueIndex = prevIndex;
    await this.play(this.playerState.queue[prevIndex]);
  }

  async seekTo(position: number): Promise<void> {
    if (!this.avPlayer) {
      return;
    }
    try {
      await this.avPlayer.seek(position);
      this.playerState.currentTime = position;
      this.syncStorage();
      await this.avSessionService.updatePlaybackState(this.playerState.isPlaying, position, this.playerState.playMode);
    } catch (error) {
      console.error(`[PlayerService] seekTo failed: ${JSON.stringify(error)}`);
    }
  }

  setPlayMode(mode: PlayMode): void {
    this.playerState.playMode = mode;
    this.syncStorage();
    void this.avSessionService.updatePlaybackState(this.playerState.isPlaying, this.playerState.currentTime, this.playerState.playMode);
  }

  cyclePlayMode(): PlayMode {
    const nextMode = (this.playerState.playMode + 1) % 3;
    this.setPlayMode(nextMode);
    return this.playerState.playMode;
  }

  async toggleFavorite(): Promise<void> {
    if (!this.context || !this.playerState.currentSong.id) {
      return;
    }
    const nextFavorite = !this.playerState.currentSong.isFavorite;
    this.playerState.currentSong.isFavorite = nextFavorite;
    this.syncStorage();
    try {
      await this.songDao.toggleFavorite(this.context, this.playerState.currentSong.id, nextFavorite);
      const librarySongs = (AppStorage.get('librarySongs') as SongEntity[] || []).map((song: SongEntity) => {
        if (song.id === this.playerState.currentSong.id) {
          song.isFavorite = nextFavorite;
        }
        return song;
      });
      AppStorage.setOrCreate('librarySongs', librarySongs);
    } catch (error) {
      console.error(`[PlayerService] toggleFavorite failed: ${JSON.stringify(error)}`);
    }
  }

  async handleRemoteCommand(command: string): Promise<void> {
    if (command === 'play') {
      await this.resume();
      return;
    }
    if (command === 'pause') {
      await this.pause();
      return;
    }
    if (command === 'next') {
      await this.next();
      return;
    }
    if (command === 'prev') {
      await this.prev();
    }
  }

  private async ensurePlayer(): Promise<media.AVPlayer> {
    if (this.avPlayer) {
      return this.avPlayer;
    }
    this.avPlayer = await media.createAVPlayer();
    this.bindPlayerEvents(this.avPlayer);
    return this.avPlayer;
  }

  private bindPlayerEvents(player: media.AVPlayer): void {
    if (this.listenersBound) {
      return;
    }
    this.listenersBound = true;
    player.on('stateChange', async (state: string) => {
      if (state === 'prepared') {
        this.playerState.status = PlayerStatus.PREPARED;
        this.playerState.duration = this.playerState.currentSong.duration;
        this.syncStorage();
        await player.play();
        return;
      }
      if (state === 'playing') {
        this.playerState.status = PlayerStatus.PLAYING;
        this.playerState.isPlaying = true;
        this.syncStorage();
        await this.avSessionService.updateMetaData(this.playerState.currentSong);
        await this.avSessionService.updatePlaybackState(true, this.playerState.currentTime, this.playerState.playMode);
        if (this.context && this.playerState.currentSong.id) {
          await this.songDao.incrementPlayCount(this.context, this.playerState.currentSong.id);
        }
        return;
      }
      if (state === 'paused') {
        this.playerState.status = PlayerStatus.PAUSED;
        this.playerState.isPlaying = false;
        this.syncStorage();
        await this.avSessionService.updatePlaybackState(false, this.playerState.currentTime, this.playerState.playMode);
        return;
      }
      if (state === 'stopped') {
        this.playerState.status = PlayerStatus.STOPPED;
        this.playerState.isPlaying = false;
        this.playerState.currentTime = 0;
        this.syncStorage();
      }
    });
    player.on('timeUpdate', async (time: number) => {
      this.playerState.currentTime = Number(time || 0);
      this.syncStorage();
      await this.avSessionService.updatePlaybackState(this.playerState.isPlaying, this.playerState.currentTime, this.playerState.playMode);
    });
    player.on('endOfStream', async () => {
      await this.next();
    });
  }

  private updateRecentSongs(song: SongEntity): void {
    const current = this.playerState.recentSongs.filter((item: SongEntity) => item.path !== song.path);
    current.unshift(song.clone());
    this.playerState.recentSongs = current.slice(0, 10);
  }

  private bootstrapStorage(): void {
    AppStorage.setOrCreate('playerState', this.playerState);
    AppStorage.setOrCreate('currentSong', SongEntity.empty());
    AppStorage.setOrCreate('currentTime', 0);
    AppStorage.setOrCreate('currentDuration', 0);
    AppStorage.setOrCreate('isPlaying', false);
    AppStorage.setOrCreate('playMode', PlayMode.SEQUENCE);
    AppStorage.setOrCreate('librarySongs', []);
    AppStorage.setOrCreate('recentSongs', []);
    AppStorage.setOrCreate('playerCommand', '');
    AppStorage.setOrCreate('playerSeekCommand', -1);
  }

  private syncStorage(): void {
    AppStorage.setOrCreate('playerState', this.playerState);
    AppStorage.setOrCreate('currentSong', this.playerState.currentSong.clone());
    AppStorage.setOrCreate('currentTime', this.playerState.currentTime);
    AppStorage.setOrCreate('currentDuration', this.playerState.duration);
    AppStorage.setOrCreate('isPlaying', this.playerState.isPlaying);
    AppStorage.setOrCreate('playMode', this.playerState.playMode);
    AppStorage.setOrCreate('recentSongs', this.playerState.recentSongs.map((song: SongEntity) => song.clone()));
  }
}
