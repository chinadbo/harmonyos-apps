import { FFT } from './FFT';

export class PitchDetector {
  private sampleRate: number = 44100;
  private fftSize: number = 2048;

  constructor(sampleRate: number = 44100, fftSize: number = 2048) {
    this.sampleRate = sampleRate;
    this.fftSize = fftSize;
  }

  detectPitch(samples: Float32Array): { frequency: number; confidence: number } | null {
    if (samples.length < this.fftSize) {
      return null;
    }

    // Apply Hanning window
    const windowed = FFT.applyHanningWindow(samples);

    // FFT
    const real = new Float32Array(this.fftSize);
    const imag = new Float32Array(this.fftSize);
    for (let i = 0; i < this.fftSize; i++) {
      real[i] = windowed[i];
      imag[i] = 0;
    }
    FFT.compute(real, imag);
    const magnitudes = FFT.getMagnitudes(real, imag);

    // Find peak in frequency range 50Hz - 500Hz
    const minBin = Math.floor(50 * this.fftSize / this.sampleRate);
    const maxBin = Math.floor(500 * this.fftSize / this.sampleRate);

    let maxMag = 0;
    let peakBin = 0;
    for (let i = minBin; i < maxBin && i < magnitudes.length; i++) {
      if (magnitudes[i] > maxMag) {
        maxMag = magnitudes[i];
        peakBin = i;
      }
    }

    if (maxMag < 1.0) {
      return null;
    }

    // Parabolic interpolation for finer frequency resolution
    const alpha = magnitudes[peakBin - 1] || 0;
    const beta = magnitudes[peakBin];
    const gamma = magnitudes[peakBin + 1] || 0;
    const p = 0.5 * (alpha - gamma) / (alpha - 2 * beta + gamma);
    const refinedBin = peakBin + p;

    const frequency = refinedBin * this.sampleRate / this.fftSize;
    const confidence = maxMag / (this.fftSize / 2);

    // Validate with autocorrelation
    if (this.validateByAutocorrelation(samples, frequency)) {
      return { frequency, confidence };
    }

    return null;
  }

  private validateByAutocorrelation(samples: Float32Array, freq: number): boolean {
    const period = Math.round(this.sampleRate / freq);
    if (period < 1 || period > samples.length / 2) {
      return false;
    }

    let sum = 0;
    let count = 0;
    for (let i = 0; i < samples.length - period; i++) {
      sum += samples[i] * samples[i + period];
      count++;
    }
    const autocorr = count > 0 ? sum / count : 0;
    return autocorr > 0;
  }
}
