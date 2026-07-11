export interface InstrumentPreset {
  name: string;
  notes: string[];
  frequencies: number[];
}

export class InstrumentConfig {
  static GUITAR_STANDARD: InstrumentPreset = {
    name: 'Guitar Standard',
    notes: ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
    frequencies: [82.41, 110.00, 146.83, 196.00, 246.94, 329.63]
  };

  static UKULELE_STANDARD: InstrumentPreset = {
    name: 'Ukulele Standard',
    notes: ['G4', 'C4', 'E4', 'A4'],
    frequencies: [392.00, 261.63, 329.63, 440.00]
  };

  static VIOLIN_STANDARD: InstrumentPreset = {
    name: 'Violin Standard',
    notes: ['G3', 'D4', 'A4', 'E5'],
    frequencies: [196.00, 293.66, 440.00, 659.25]
  };

  static BASS_STANDARD: InstrumentPreset = {
    name: 'Bass Standard',
    notes: ['E1', 'A1', 'D2', 'G2'],
    frequencies: [41.20, 55.00, 73.42, 98.00]
  };

  static ALL_INSTRUMENTS: InstrumentPreset[] = [
    InstrumentConfig.GUITAR_STANDARD,
    InstrumentConfig.UKULELE_STANDARD,
    InstrumentConfig.VIOLIN_STANDARD,
    InstrumentConfig.BASS_STANDARD
  ];
}
