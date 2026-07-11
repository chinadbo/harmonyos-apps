import { AudioCapture } from '../audio/AudioCapture';
import { AudioBuffer } from '../audio/AudioBuffer';
import { PitchDetector } from '../signal/PitchDetector';
import { FrequencyUtils } from '../signal/FrequencyUtils';
import { InstrumentConfig, InstrumentPreset } from './InstrumentConfig';

export interface TunerResult {
  frequency: number;
  note: string;
  octave: number;
  cents: number;
  targetFreq: number;
  isInTune: boolean;
  confidence: number;
}

export class TunerEngine {
  private audioCapture: AudioCapture = new AudioCapture();
  private audioBuffer: AudioBuffer = new AudioBuffer(4096);
  private pitchDetector: PitchDetector = new PitchDetector(44100, 2048);
  private isRunning: boolean = false;
  private currentInstrument: InstrumentPreset = InstrumentConfig.GUITAR_STANDARD;
  private targetNoteIndex: number = 0;
  private onResultCallback: ((result: TunerResult | null) => void) | null = null;
  private onSpectrumCallback: ((data: Float32Array) => void) | null = null;

  async init(): Promise<boolean> {
    return await this.audioCapture.init();
  }

  start(onResult: (result: TunerResult | null) => void, onSpectrum?: (data: Float32Array) => void): void {
    if (this.isRunning) return;
    this.onResultCallback = onResult;
    this.onSpectrumCallback = onSpectrum || null;
    this.isRunning = true;

    this.audioCapture.start((data: ArrayBuffer) => {
      this.audioBuffer.write(data);
      const samples = this.audioBuffer.getSamples(2048);

      const pitchResult = this.pitchDetector.detectPitch(samples);
      if (pitchResult) {
        const noteInfo = FrequencyUtils.frequencyToNote(pitchResult.frequency);
        if (noteInfo) {
          const result: TunerResult = {
            frequency: pitchResult.frequency,
            note: noteInfo.note,
            octave: noteInfo.octave,
            cents: noteInfo.cents,
            targetFreq: noteInfo.targetFreq,
            isInTune: FrequencyUtils.isInTune(noteInfo.cents),
            confidence: pitchResult.confidence
          };
          if (this.onResultCallback) {
            this.onResultCallback(result);
          }
        }
      } else {
        if (this.onResultCallback) {
          this.onResultCallback(null);
        }
      }
    });
  }

  stop(): void {
    this.isRunning = false;
    this.audioCapture.stop();
  }

  release(): void {
    this.isRunning = false;
    this.audioCapture.release();
  }

  setInstrument(preset: InstrumentPreset): void {
    this.currentInstrument = preset;
  }

  setTargetNoteIndex(index: number): void {
    this.targetNoteIndex = index;
  }

  getCurrentInstrument(): InstrumentPreset {
    return this.currentInstrument;
  }
}
