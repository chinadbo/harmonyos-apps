import { MAX_BPM, MAX_TIMER_MINUTES, MIN_BPM } from '../constants/AppConstants';
import type { BeatState } from '../constants/AppTypes';

export class MetronomeService {
  private static instance: MetronomeService = new MetronomeService();
  private intervalId: number = -1;
  private secondTimerId: number = -1;
  private bpm: number = 100;
  private timeSignature: string = '4/4';
  private currentBeat: number = 0;
  private remainingSeconds: number = 300;
  private durationMinutes: number = 5;
  private onBeat?: (state: BeatState) => void;
  private onTimer?: (remainingSeconds: number) => void;
  private onStop?: () => void;
  private playSound?: (isAccent: boolean) => void;

  private constructor() {
  }

  static getInstance(): MetronomeService {
    return MetronomeService.instance;
  }

  configure(options: {
    bpm: number;
    timeSignature: string;
    durationMinutes: number;
    onBeat?: (state: BeatState) => void;
    onTimer?: (remainingSeconds: number) => void;
    onStop?: () => void;
    playSound?: (isAccent: boolean) => void;
  }): void {
    this.bpm = Math.min(MAX_BPM, Math.max(MIN_BPM, options.bpm));
    this.timeSignature = options.timeSignature;
    this.durationMinutes = Math.min(MAX_TIMER_MINUTES, Math.max(1, options.durationMinutes));
    this.onBeat = options.onBeat;
    this.onTimer = options.onTimer;
    this.onStop = options.onStop;
    this.playSound = options.playSound;
    if (!this.isRunning()) {
      this.remainingSeconds = this.durationMinutes * 60;
    }
  }

  updateBpm(bpm: number): void {
    this.bpm = Math.min(MAX_BPM, Math.max(MIN_BPM, bpm));
    if (this.isRunning()) {
      this.restartBeatLoop();
    }
  }

  updateTimeSignature(timeSignature: string): void {
    this.timeSignature = timeSignature;
    this.currentBeat = 0;
    if (this.isRunning()) {
      this.restartBeatLoop();
    }
  }

  updateDurationMinutes(minutes: number): void {
    this.durationMinutes = Math.min(MAX_TIMER_MINUTES, Math.max(1, minutes));
    if (!this.isRunning()) {
      this.remainingSeconds = this.durationMinutes * 60;
      if (this.onTimer) {
        this.onTimer(this.remainingSeconds);
      }
    }
  }

  getRemainingSeconds(): number {
    return this.remainingSeconds;
  }

  getDurationMinutes(): number {
    return this.durationMinutes;
  }

  isRunning(): boolean {
    return this.intervalId !== -1;
  }

  start(): void {
    if (this.isRunning()) {
      return;
    }
    this.currentBeat = 0;
    this.remainingSeconds = this.durationMinutes * 60;
    this.startBeatLoop();
    this.startSecondLoop();
  }

  stop(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
    if (this.secondTimerId !== -1) {
      clearInterval(this.secondTimerId);
      this.secondTimerId = -1;
    }
    this.currentBeat = 0;
    this.remainingSeconds = this.durationMinutes * 60;
    if (this.onTimer) {
      this.onTimer(this.remainingSeconds);
    }
    if (this.onStop) {
      this.onStop();
    }
  }

  toggle(): void {
    if (this.isRunning()) {
      this.stop();
      return;
    }
    this.start();
  }

  release(): void {
    this.stop();
    this.onBeat = undefined;
    this.onTimer = undefined;
    this.onStop = undefined;
    this.playSound = undefined;
  }

  private beatsPerMeasure(): number {
    const value: string = this.timeSignature.split('/')[0];
    return Number(value) || 4;
  }

  private emitBeat(): void {
    const beatsPerMeasure: number = this.beatsPerMeasure();
    const beatIndex: number = this.currentBeat % beatsPerMeasure;
    const isAccent: boolean = beatIndex === 0;
    if (this.playSound) {
      this.playSound(isAccent);
    }
    if (this.onBeat) {
      this.onBeat({
        currentBeat: beatIndex + 1,
        beatsPerMeasure,
        isAccent
      });
    }
    this.currentBeat = (beatIndex + 1) % beatsPerMeasure;
  }

  private startBeatLoop(): void {
    const intervalMs: number = Math.round(60000 / this.bpm);
    this.emitBeat();
    this.intervalId = setInterval(() => {
      this.emitBeat();
    }, intervalMs) as unknown as number;
  }

  private restartBeatLoop(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
    this.startBeatLoop();
  }

  private startSecondLoop(): void {
    this.secondTimerId = setInterval(() => {
      this.remainingSeconds -= 1;
      if (this.onTimer) {
        this.onTimer(this.remainingSeconds);
      }
      if (this.remainingSeconds <= 0) {
        this.stop();
      }
    }, 1000) as unknown as number;
  }
}

export const metronomeService: MetronomeService = MetronomeService.getInstance();
