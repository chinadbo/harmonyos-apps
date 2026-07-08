interface DecibelStats {
  current: number;
  average: number;
  max: number;
  min: number;
  sampleCount: number;
}

class DecibelAnalyzer {
  private calibrationOffset: number = 0;
  private totalSamples: number = 0;
  private sumDb: number = 0;
  private maxDb: number = -999;
  private minDb: number = 999;
  private history: number[] = [];
  private readonly maxHistorySize: number = 600; // 60 seconds at 10 samples/sec

  setCalibrationOffset(offset: number): void {
    this.calibrationOffset = offset;
  }

  processBuffer(buffer: ArrayBuffer): number {
    const int16Data = new Int16Array(buffer);
    if (int16Data.length === 0) {
      return 0;
    }

    let sum = 0;
    for (let i = 0; i < int16Data.length; i++) {
      sum += int16Data[i] * int16Data[i];
    }
    const rms = Math.sqrt(sum / int16Data.length);

    if (rms === 0) {
      return 0;
    }

    // Convert RMS to dB SPL
    // 32768 is max amplitude for 16-bit signed int
    // 94 dB is the theoretical SPL at full scale for typical microphone calibration
    let db = 20 * Math.log10(rms / 32768) + 94 + this.calibrationOffset;

    // Clamp to realistic range
    db = Math.max(30, Math.min(120, db));

    this.updateStats(db);
    return db;
  }

  private updateStats(db: number): void {
    this.totalSamples++;
    this.sumDb += db;
    this.maxDb = Math.max(this.maxDb, db);
    this.minDb = Math.min(this.minDb, db);

    this.history.push(db);
    if (this.history.length > this.maxHistorySize) {
      this.history.shift();
    }
  }

  getStats(): DecibelStats {
    return {
      current: this.history.length > 0 ? this.history[this.history.length - 1] : 0,
      average: this.totalSamples > 0 ? this.sumDb / this.totalSamples : 0,
      max: this.maxDb === -999 ? 0 : this.maxDb,
      min: this.minDb === 999 ? 0 : this.minDb,
      sampleCount: this.totalSamples
    };
  }

  getHistory(): number[] {
    return [...this.history];
  }

  reset(): void {
    this.totalSamples = 0;
    this.sumDb = 0;
    this.maxDb = -999;
    this.minDb = 999;
    this.history = [];
  }

  getNoiseLevelDescription(db: number): { label: string; color: string } {
    if (db < 40) {
      return { label: 'Very Quiet', color: '#4CAF50' };
    } else if (db < 60) {
      return { label: 'Quiet', color: '#8BC34A' };
    } else if (db < 70) {
      return { label: 'Moderate', color: '#FFC107' };
    } else if (db < 85) {
      return { label: 'Loud', color: '#FF9800' };
    } else if (db < 100) {
      return { label: 'Very Loud', color: '#F44336' };
    } else {
      return { label: 'Dangerous', color: '#D32F2F' };
    }
  }
}

export { DecibelAnalyzer, DecibelStats };
export default new DecibelAnalyzer();
