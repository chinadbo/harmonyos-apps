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

export class TuningHistory {
  private records: TuningRecord[] = [];
  private maxRecords: number = 100;

  addRecord(record: TuningRecord): void {
    this.records.unshift(record);
    if (this.records.length > this.maxRecords) {
      this.records = this.records.slice(0, this.maxRecords);
    }
  }

  getRecords(): TuningRecord[] {
    return this.records;
  }

  getRecordsByInstrument(instrument: string): TuningRecord[] {
    return this.records.filter(r => r.instrument === instrument);
  }

  clear(): void {
    this.records = [];
  }

  getLastRecord(): TuningRecord | null {
    return this.records.length > 0 ? this.records[0] : null;
  }
}
