import { COLORS } from '../constants/AppConstants';

@Component
export struct BeatIndicator {
  @Prop currentBeat: number;
  @Prop beatsPerMeasure: number;
  @Prop isAccent: boolean;
  @Prop isDarkMode: boolean = true;

  private onDraw(context: CanvasRenderingContext2D): void {
    const width: number = 320;
    const height: number = 240;
    const centerX: number = width / 2;
    const centerY: number = height / 2;
    const baseRadius: number = Math.min(width, height) * 0.24;
    const pulseRadius: number = baseRadius + (this.isAccent ? 26 : 16);
    context.clearRect(0, 0, width, height);

    context.fillStyle = this.isDarkMode ? COLORS.surface : '#F5F7FB';
    context.beginPath();
    context.roundRect(0, 0, width, height, 28);
    context.fill();

    context.fillStyle = this.isAccent ? 'rgba(168,108,255,0.22)' : 'rgba(91,167,255,0.16)';
    context.beginPath();
    context.arc(centerX, centerY, pulseRadius, 0, Math.PI * 2);
    context.fill();

    context.fillStyle = this.isAccent ? COLORS.accent : COLORS.primary;
    context.beginPath();
    context.arc(centerX, centerY, baseRadius, 0, Math.PI * 2);
    context.fill();

    context.fillStyle = COLORS.textPrimary;
    context.font = 'bold 28px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillText(`${this.currentBeat}`, centerX, centerY - 10);

    context.fillStyle = COLORS.textSecondary;
    context.font = '16px sans-serif';
    context.fillText(`Beat ${this.currentBeat} / ${this.beatsPerMeasure}`, centerX, centerY + 28);
  }

  build() {
    Canvas(this.onDraw.bind(this))
      .width('100%')
      .height(240)
      .backgroundColor(this.isDarkMode ? COLORS.surface : '#F5F7FB')
      .borderRadius(28)
  }
}
