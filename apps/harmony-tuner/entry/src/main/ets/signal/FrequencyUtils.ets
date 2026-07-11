export class FrequencyUtils {
  private static NOTE_NAMES: string[] = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  private static A4_FREQ: number = 440.0;

  static setReferenceFrequency(freq: number): void {
    FrequencyUtils.A4_FREQ = freq;
  }

  static frequencyToNote(frequency: number): { note: string; octave: number; cents: number; targetFreq: number } | null {
    if (frequency <= 0) return null;

    const semitones = 12 * Math.log2(frequency / FrequencyUtils.A4_FREQ);
    const midiNote = Math.round(69 + semitones);
    const noteIndex = ((midiNote % 12) + 12) % 12;
    const octave = Math.floor((midiNote - 12) / 12);
    const note = FrequencyUtils.NOTE_NAMES[noteIndex];

    const targetFreq = FrequencyUtils.A4_FREQ * Math.pow(2, (midiNote - 69) / 12);
    const cents = 1200 * Math.log2(frequency / targetFreq);

    return { note, octave, cents, targetFreq };
  }

  static noteToFrequency(note: string, octave: number): number {
    const noteIndex = FrequencyUtils.NOTE_NAMES.indexOf(note);
    if (noteIndex < 0) return 0;
    const midiNote = noteIndex + 12 * (octave + 1);
    return FrequencyUtils.A4_FREQ * Math.pow(2, (midiNote - 69) / 12);
  }

  static formatCents(cents: number): string {
    const sign = cents > 0 ? '+' : '';
    return `${sign}${cents.toFixed(1)}`;
  }

  static isInTune(cents: number, tolerance: number = 5.0): boolean {
    return Math.abs(cents) <= tolerance;
  }
}
