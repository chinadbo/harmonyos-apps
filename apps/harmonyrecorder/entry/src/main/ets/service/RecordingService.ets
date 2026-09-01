import common from '@ohos.app.ability.common';
import screenCapture from '@ohos.screenCapture';
import { RecordingConfig, DEFAULT_RECORDING_CONFIG } from '../model/RecordingConfig';
import { RecordingFile } from '../model/RecordingFile';
import { RecordingState } from '../model/RecordingState';
import { FileUtils } from '../utils/FileUtils';
import { PermissionUtils } from '../utils/PermissionUtils';

type RecordingListener = (state: RecordingState, remainingSeconds: number, durationMs: number) => void;

export class RecordingService {
  private static instance?: RecordingService;
  private config: RecordingConfig = DEFAULT_RECORDING_CONFIG;
  private state: RecordingState = RecordingState.IDLE;
  private countdownValue: number = 0;
  private durationMs: number = 0;
  private timerId: number = -1;
  private durationTimerId: number = -1;
  private outputPath: string = '';
  private recordingSession: any = null;
  private listeners: Array<RecordingListener> = [];

  static getInstance(): RecordingService {
    if (!this.instance) {
      this.instance = new RecordingService();
    }
    return this.instance;
  }

  getConfig(): RecordingConfig {
    return this.config;
  }

  updateConfig(config: RecordingConfig): void {
    this.config = { ...config };
  }

  getState(): RecordingState {
    return this.state;
  }

  getCountdownValue(): number {
    return this.countdownValue;
  }

  getDurationMs(): number {
    return this.durationMs;
  }

  subscribe(listener: RecordingListener): () => void {
    this.listeners.push(listener);
    listener(this.state, this.countdownValue, this.durationMs);
    return () => {
      this.listeners = this.listeners.filter((item: RecordingListener) => item !== listener);
    };
  }

  private notify(): void {
    this.listeners.forEach((listener: RecordingListener) => listener(this.state, this.countdownValue, this.durationMs));
  }

  async startRecording(context: common.UIAbilityContext): Promise<void> {
    if (this.state !== RecordingState.IDLE) {
      return;
    }

    await PermissionUtils.ensurePermissions(context);
    this.outputPath = await FileUtils.buildRecordingPath(context);
    this.durationMs = 0;

    if (this.config.countdownSeconds > 0) {
      await this.startCountdown();
    }

    await this.startCapture(context);
  }

  private async startCountdown(): Promise<void> {
    this.state = RecordingState.COUNTING;
    this.countdownValue = this.config.countdownSeconds;
    this.notify();

    await new Promise<void>((resolve: () => void) => {
      this.timerId = globalThis.setInterval(() => {
        this.countdownValue -= 1;
        this.notify();
        if (this.countdownValue <= 0) {
          globalThis.clearInterval(this.timerId);
          this.timerId = -1;
          resolve();
        }
      }, 1000);
    });
  }

  private async startCapture(_: common.UIAbilityContext): Promise<void> {
    const audioConfig: Record<string, Object | number | string> | undefined = this.config.enableAudio ? {
      audioSampleRate: 48000,
      audioChannels: 2,
      audioSource: 'mic'
    } : undefined;

    const captureConfig: Record<string, Object | number | string | undefined> = {
      captureMode: 'homeScreen',
      dataType: 'file',
      audioInfo: audioConfig,
      recorderInfo: {
        url: this.outputPath,
        fileFormat: 'mp4',
        videoCodec: 'h264',
        videoFrameRate: this.config.frameRate,
        videoBitrate: this.config.resolution === '720p' ? 4_000_000 : 8_000_000,
        audioCodec: 'aac'
      }
    };

    const factory: ((config?: Object) => Promise<any>) | undefined = (screenCapture as Record<string, ((config?: Object) => Promise<any>) | undefined>).createScreenCapture;
    if (!factory) {
      throw new Error('screenCapture.createScreenCapture is unavailable in the current SDK.');
    }

    this.recordingSession = await factory(captureConfig);
    const startMethod: (() => Promise<void>) | undefined = this.recordingSession.startScreenCapture?.bind(this.recordingSession)
      ?? this.recordingSession.start?.bind(this.recordingSession);
    if (!startMethod) {
      throw new Error('No screen capture start method is available.');
    }

    await startMethod();
    this.state = RecordingState.RECORDING;
    this.countdownValue = 0;
    this.notify();
    this.startDurationTicker();
  }

  private startDurationTicker(): void {
    this.durationTimerId = globalThis.setInterval(() => {
      this.durationMs += 1000;
      this.notify();
    }, 1000);
  }

  async pauseRecording(): Promise<void> {
    if (this.state !== RecordingState.RECORDING || !this.recordingSession) {
      return;
    }
    const pauseMethod: (() => Promise<void>) | undefined = this.recordingSession.pauseScreenCapture?.bind(this.recordingSession)
      ?? this.recordingSession.pause?.bind(this.recordingSession);
    await pauseMethod?.();
    this.state = RecordingState.PAUSED;
    globalThis.clearInterval(this.durationTimerId);
    this.durationTimerId = -1;
    this.notify();
  }

  async resumeRecording(): Promise<void> {
    if (this.state !== RecordingState.PAUSED || !this.recordingSession) {
      return;
    }
    const resumeMethod: (() => Promise<void>) | undefined = this.recordingSession.resumeScreenCapture?.bind(this.recordingSession)
      ?? this.recordingSession.resume?.bind(this.recordingSession);
    await resumeMethod?.();
    this.state = RecordingState.RECORDING;
    this.startDurationTicker();
    this.notify();
  }

  async stopRecording(): Promise<RecordingFile | undefined> {
    if (!this.recordingSession) {
      return undefined;
    }

    globalThis.clearInterval(this.timerId);
    globalThis.clearInterval(this.durationTimerId);
    this.timerId = -1;
    this.durationTimerId = -1;

    const stopMethod: (() => Promise<void>) | undefined = this.recordingSession.stopScreenCapture?.bind(this.recordingSession)
      ?? this.recordingSession.stop?.bind(this.recordingSession);
    await stopMethod?.();
    await this.recordingSession.release?.();
    this.recordingSession = null;

    const recordingFile: RecordingFile = {
      id: this.outputPath.substring(this.outputPath.lastIndexOf('/') + 1),
      name: this.outputPath.substring(this.outputPath.lastIndexOf('/') + 1),
      path: this.outputPath,
      thumbnailPath: '',
      duration: Math.floor(this.durationMs / 1000),
      size: 0,
      createdAt: new Date().toISOString()
    };

    this.state = RecordingState.IDLE;
    this.countdownValue = 0;
    this.durationMs = 0;
    this.notify();
    return recordingFile;
  }
}

export const recordingService: RecordingService = RecordingService.getInstance();
