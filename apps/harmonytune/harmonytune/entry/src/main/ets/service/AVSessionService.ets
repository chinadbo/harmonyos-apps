import avSession from '@ohos.multimedia.avsession';
import common from '@ohos.app.ability.common';
import { SongEntity } from '../model/SongEntity';

export class AVSessionService {
  private static instance: AVSessionService = new AVSessionService();
  private session?: avSession.AVSession;
  private controllerRegistered: boolean = false;

  static getInstance(): AVSessionService {
    return AVSessionService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.session) {
      return;
    }
    try {
      this.session = await avSession.createAVSession(context, 'HarmonyTuneSession', 'audio');
      await this.session.activate();
      this.registerControllers();
    } catch (error) {
      console.error(`[AVSessionService] init failed: ${JSON.stringify(error)}`);
    }
  }

  async updateMetaData(song: SongEntity): Promise<void> {
    if (!this.session) {
      return;
    }
    try {
      await this.session.setAVMetadata({
        assetId: `${song.id}`,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        mediaImage: song.coverPath
      });
    } catch (error) {
      console.error(`[AVSessionService] updateMetaData failed: ${JSON.stringify(error)}`);
    }
  }

  async updatePlaybackState(isPlaying: boolean, position: number, playMode: number): Promise<void> {
    if (!this.session) {
      return;
    }
    try {
      await this.session.setAVPlaybackState({
        state: isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        position: {
          elapsedTime: position,
          updateTime: Date.now()
        },
        loopMode: playMode
      });
    } catch (error) {
      console.error(`[AVSessionService] updatePlaybackState failed: ${JSON.stringify(error)}`);
    }
  }

  async destroy(): Promise<void> {
    if (!this.session) {
      return;
    }
    try {
      await this.session.destroy();
    } catch (error) {
      console.error(`[AVSessionService] destroy failed: ${JSON.stringify(error)}`);
    } finally {
      this.session = undefined;
      this.controllerRegistered = false;
    }
  }

  private registerControllers(): void {
    if (!this.session || this.controllerRegistered) {
      return;
    }
    this.controllerRegistered = true;
    this.session.on('play', () => {
      AppStorage.setOrCreate('playerCommand', 'play');
    });
    this.session.on('pause', () => {
      AppStorage.setOrCreate('playerCommand', 'pause');
    });
    this.session.on('playNext', () => {
      AppStorage.setOrCreate('playerCommand', 'next');
    });
    this.session.on('playPrevious', () => {
      AppStorage.setOrCreate('playerCommand', 'prev');
    });
    this.session.on('seek', (position: number) => {
      AppStorage.setOrCreate('playerSeekCommand', position);
    });
  }
}
