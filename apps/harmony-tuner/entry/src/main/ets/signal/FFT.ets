export class FFT {
  private static reverseBits(index: number, numBits: number): number {
    let reversed = 0;
    for (let i = 0; i < numBits; i++) {
      reversed = (reversed << 1) | (index & 1);
      index >>= 1;
    }
    return reversed;
  }

  static compute(real: Float32Array, imag: Float32Array): void {
    const n = real.length;
    if (n !== imag.length || (n & (n - 1)) !== 0) {
      throw new Error('FFT length must be power of 2');
    }

    const numBits = Math.log2(n);

    // Bit reversal permutation
    for (let i = 0; i < n; i++) {
      const j = this.reverseBits(i, numBits);
      if (j > i) {
        let temp = real[i];
        real[i] = real[j];
        real[j] = temp;
        temp = imag[i];
        imag[i] = imag[j];
        imag[j] = temp;
      }
    }

    // Cooley-Tukey FFT
    for (let len = 2; len <= n; len <<= 1) {
      const halfLen = len >> 1;
      for (let i = 0; i < n; i += len) {
        for (let j = 0; j < halfLen; j++) {
          const angle = -2 * Math.PI * j / len;
          const cos = Math.cos(angle);
          const sin = Math.sin(angle);
          const evenReal = real[i + j];
          const evenImag = imag[i + j];
          const oddReal = real[i + j + halfLen];
          const oddImag = imag[i + j + halfLen];
          real[i + j] = evenReal + cos * oddReal - sin * oddImag;
          imag[i + j] = evenImag + cos * oddImag + sin * oddReal;
          real[i + j + halfLen] = evenReal - cos * oddReal + sin * oddImag;
          imag[i + j + halfLen] = evenImag - cos * oddImag - sin * oddReal;
        }
      }
    }
  }

  static getMagnitudes(real: Float32Array, imag: Float32Array): Float32Array {
    const result = new Float32Array(real.length / 2);
    for (let i = 0; i < result.length; i++) {
      result[i] = Math.sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }
    return result;
  }

  static applyHanningWindow(samples: Float32Array): Float32Array {
    const n = samples.length;
    const result = new Float32Array(n);
    for (let i = 0; i < n; i++) {
      result[i] = samples[i] * 0.5 * (1 - Math.cos(2 * Math.PI * i / (n - 1)));
    }
    return result;
  }
}
