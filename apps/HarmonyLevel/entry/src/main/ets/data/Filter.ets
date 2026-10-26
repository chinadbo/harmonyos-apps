export class LowPassFilter {
  private alpha: number;
  private value: number;
  private initialized: boolean;

  constructor(alpha: number) {
    this.alpha = alpha;
    this.value = 0;
    this.initialized = false;
  }

  setAlpha(alpha: number): void {
    if (alpha <= 0) {
      this.alpha = 0.01;
    } else if (alpha > 1) {
      this.alpha = 1;
    } else {
      this.alpha = alpha;
    }
  }

  reset(): void {
    this.initialized = false;
    this.value = 0;
  }

  update(input: number): number {
    if (!this.initialized) {
      this.initialized = true;
      this.value = input;
      return input;
    }
    this.value = this.value + this.alpha * (input - this.value);
    return this.value;
  }

  getValue(): number {
    return this.value;
  }
}
