import { COLORS } from '../constants/AppConstants';

@Component
export struct TapTempoButton {
  @State private tapTimes: Array<number> = [];
  @State private lastTempoText: string = 'Tap 4 times';
  onTempoDetected?: (bpm: number) => void;

  private registerTap(): void {
    const now: number = Date.now();
    this.tapTimes = this.tapTimes.filter((item: number) => now - item < 2500);
    this.tapTimes.push(now);
    if (this.tapTimes.length < 4) {
      this.lastTempoText = `Tap ${4 - this.tapTimes.length} more`;
      return;
    }
    let totalInterval: number = 0;
    for (let index: number = 1; index < this.tapTimes.length; index++) {
      totalInterval += this.tapTimes[index] - this.tapTimes[index - 1];
    }
    const averageInterval: number = totalInterval / (this.tapTimes.length - 1);
    const bpm: number = Math.round(60000 / averageInterval);
    this.lastTempoText = `${bpm} BPM detected`;
    if (this.onTempoDetected) {
      this.onTempoDetected(bpm);
    }
  }

  build() {
    Column({ space: 10 }) {
      Button('Tap Tempo')
        .width('100%')
        .height(52)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(COLORS.accent)
        .onClick(() => {
          this.registerTap();
        })
      Text(this.lastTempoText)
        .fontSize(14)
        .fontColor(COLORS.textSecondary)
    }
    .padding(18)
    .backgroundColor(COLORS.surface)
    .borderRadius(24)
    .width('100%')
  }
}
