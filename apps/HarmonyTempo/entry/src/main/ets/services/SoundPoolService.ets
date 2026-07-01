import media from '@ohos.multimedia.media';
import audio from '@ohos.multimedia.audio';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';

const DOMAIN = 0xFF12;
const TAG = 'SoundPoolService';

export class SoundPoolService {
  private static instance: SoundPoolService = new SoundPoolService();
  private context?: common.UIAbilityContext;
  private pool?: media.SoundPool;
  private initialized: boolean = false;
  private accentIds: Map<string, number> = new Map();
  private beatIds: Map<string, number> = new Map();

  private constructor() {
  }

  static getInstance(): SoundPoolService {
    return SoundPoolService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized) {
      return;
    }
    this.context = context;
    const rendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };
    this.pool = await media.createSoundPool(2, rendererInfo);
    await this.preload();
    this.initialized = true;
  }

  private async preload(): Promise<void> {
    await this.loadPair('classic');
    await this.loadPair('wood');
    await this.loadPair('digital');
  }

  private async loadPair(name: string): Promise<void> {
    const accentId: number = await this.loadRawFile(`sounds/${name}_accent.wav`);
    const beatId: number = await this.loadRawFile(`sounds/${name}_beat.wav`);
    this.accentIds.set(name, accentId);
    this.beatIds.set(name, beatId);
  }

  private async loadRawFile(path: string): Promise<number> {
    if (!this.context || !this.pool) {
      return -1;
    }
    const rawFd = await this.context.resourceManager.getRawFd(path);
    const soundId: number = await this.pool.load(rawFd.fd, rawFd.offset, rawFd.length);
    await this.context.resourceManager.closeRawFd(path);
    return soundId;
  }

  playAccent(soundType: string): void {
    this.playById(this.accentIds.get(soundType));
  }

  playBeat(soundType: string): void {
    this.playById(this.beatIds.get(soundType));
  }

  private playById(soundId?: number): void {
    if (!this.pool || soundId === undefined || soundId < 0) {
      return;
    }
    try {
      this.pool.play(soundId, {
        loop: 0,
        rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
        leftVolume: 1,
        rightVolume: 1,
        priority: 1
      });
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'play failed: %{public}s', JSON.stringify(error));
    }
  }

  async release(): Promise<void> {
    if (!this.pool) {
      return;
    }
    try {
      await this.pool.release();
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'release failed: %{public}s', JSON.stringify(error));
    }
    this.accentIds.clear();
    this.beatIds.clear();
    this.pool = undefined;
    this.initialized = false;
  }
}

export const soundPoolService: SoundPoolService = SoundPoolService.getInstance();
