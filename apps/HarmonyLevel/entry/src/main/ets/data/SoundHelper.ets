import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

const PLAY_THROTTLE_MS: number = 400;

// 提示音：AVPlayer 播放 rawfile 短音频（fdSrc），播放完成即 release；
// 内部带节流，防止接近水平角时高频触发连响。
export class SoundHelper {
  private static instance: SoundHelper | null = null;
  private lastPlay: number = 0;
  private playing: boolean = false;

  static getInstance(): SoundHelper {
    if (SoundHelper.instance === null) {
      SoundHelper.instance = new SoundHelper();
    }
    return SoundHelper.instance;
  }

  isPlaying(): boolean {
    return this.playing;
  }

  play(context: common.Context): void {
    const now: number = Date.now();
    if (this.playing || now - this.lastPlay < PLAY_THROTTLE_MS) {
      return;
    }
    this.lastPlay = now;
    this.playing = true;
    this.startPlay(context);
  }

  private async startPlay(context: common.Context): Promise<void> {
    let player: media.AVPlayer;
    try {
      player = await media.createAVPlayer();
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] createAVPlayer failed: ${e.code} ${e.message}`);
      this.playing = false;
      return;
    }

    const finish = (): void => {
      this.playing = false;
    };

    player.on('stateChange', (state: string) => {
      switch (state) {
        case 'idle': {
          try {
            player.fdSrc = context.resourceManager.getRawFd('beep.wav');
          } catch (err) {
            const e = err as BusinessError;
            console.error(`[HarmonyLevel] getRawFd failed: ${e.code} ${e.message}`);
            this.safeRelease(player);
            finish();
          }
          break;
        }
        case 'initialized': {
          player.prepare().catch(() => {
            this.safeRelease(player);
            finish();
          });
          break;
        }
        case 'prepared': {
          player.play().catch(() => {
            this.safeRelease(player);
            finish();
          });
          break;
        }
        case 'completed': {
          this.safeRelease(player);
          break;
        }
        case 'released': {
          finish();
          break;
        }
        default:
          break;
      }
    });

    player.on('error', (err: BusinessError) => {
      console.error(`[HarmonyLevel] avPlayer error: ${err.code} ${err.message}`);
      this.safeRelease(player);
      finish();
    });
  }

  private safeRelease(player: media.AVPlayer): void {
    try {
      player.release();
    } catch (err) {
      console.error('[HarmonyLevel] avPlayer release failed');
      this.playing = false;
    }
  }
}
