export class LowPassFilter {
  private alpha: number = 0.15;
  private previousValue: number = 0;
  private isInitialized: boolean = false;

  constructor(alpha: number = 0.15) {
    this.alpha = alpha;
  }

  public filter(value: number): number {
    if (!this.isInitialized) {
      this.previousValue = value;
      this.isInitialized = true;
      return value;
    }

    // Handle 0/360 boundary crossing
    let diff = value - this.previousValue;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    let filtered = this.previousValue + this.alpha * diff;

    // Normalize to 0-360
    if (filtered < 0) {
      filtered += 360;
    } else if (filtered >= 360) {
      filtered -= 360;
    }

    this.previousValue = filtered;
    return filtered;
  }

  public reset(): void {
    this.isInitialized = false;
    this.previousValue = 0;
  }
}