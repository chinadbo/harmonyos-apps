import avsession from '@ohos.multimedia.avsession';
import common from '@ohos.app.ability.common';
import { SongInfo } from '../model/SongInfo';
import { PlayerService } from './PlayerService';

export class AVSessionManager {
  private static instance: AVSessionManager = new AVSessionManager();
  private session: any = null;
  private playerService: PlayerService | null = null;

  static getInstance(): AVSessionManager {
    return AVSessionManager.instance;
  }

  async initialize(context: common.UIAbilityContext, playerService: PlayerService): Promise<void> {
    this.playerService = playerService;
    if (this.session !== null) {
      return;
    }
    try {
      this.session = await avsession.createAVSession(context, 'HarmonyPlayer', 'audio');
      this.bindSystemControls();
      await this.session.activate();
    } catch (error) {
      console.error(`AVSession initialize failed: ${JSON.stringify(error)}`);
    }
  }

  async setAVMetadata(song: SongInfo | null): Promise<void> {
    if (this.session === null || song === null) {
      return;
    }
    await this.session.setAVMetadata({
      assetId: `${song.id}`,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      mediaImage: song.coverUri
    });
  }

  async setAVPlaybackState(isPlaying: boolean, position: number): Promise<void> {
    if (this.session === null) {
      return;
    }
    await this.session.setAVPlaybackState({
      state: isPlaying ? avsession.PlaybackState.PLAYING : avsession.PlaybackState.PAUSED,
      position: { elapsedTime: position },
      speed: isPlaying ? 1 : 0
    });
  }

  private bindSystemControls(): void {
    if (this.session === null) {
      return;
    }
    this.session.on('play', async () => {
      await this.playerService?.play();
    });
    this.session.on('pause', async () => {
      await this.playerService?.pause();
    });
    this.session.on('playNext', async () => {
      await this.playerService?.next();
    });
    this.session.on('playPrevious', async () => {
      await this.playerService?.previous();
    });
    this.session.on('seek', async (position: number) => {
      await this.playerService?.seekTo(position);
    });
  }
}
