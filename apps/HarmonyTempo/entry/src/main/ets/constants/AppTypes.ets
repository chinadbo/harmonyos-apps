export interface MetronomeSettings {
  bpm: number;
  timeSignature: string;
  soundType: string;
  isDarkMode: boolean;
}

export interface PracticeState {
  durationMinutes: number;
  remainingSeconds: number;
}

export interface BeatState {
  currentBeat: number;
  beatsPerMeasure: number;
  isAccent: boolean;
}
