export class AudioBuffer {
  private buffer: Float32Array;
  private writeIndex: number = 0;
  private size: number;

  constructor(size: number) {
    this.size = size;
    this.buffer = new Float32Array(size);
  }

  write(data: ArrayBuffer): void {
    const int16Data = new Int16Array(data);
    const floatData = new Float32Array(int16Data.length);
    for (let i = 0; i < int16Data.length; i++) {
      floatData[i] = int16Data[i] / 32768.0;
    }

    for (let i = 0; i < floatData.length; i++) {
      this.buffer[this.writeIndex] = floatData[i];
      this.writeIndex = (this.writeIndex + 1) % this.size;
    }
  }

  getSamples(count: number): Float32Array {
    const result = new Float32Array(count);
    for (let i = 0; i < count; i++) {
      const idx = (this.writeIndex - count + i + this.size) % this.size;
      result[i] = this.buffer[idx];
    }
    return result;
  }

  isFull(): boolean {
    return true;
  }
}
