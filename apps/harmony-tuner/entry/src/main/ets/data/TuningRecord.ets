export interface TuningRecord {
  id: number;
  timestamp: number;
  instrument: string;
  targetNote: string;
  detectedFreq: number;
  targetFreq: number;
  deviationCents: number;
  isInTune: boolean;
}
