import { TunerResult } from '../tuner/TunerEngine';

@Component
export struct NeedleGauge {
  @Prop cents: number = 0;
  @Prop isActive: boolean = false;

  build() {
    Canvas(this.context)
      .width('100%')
      .height(200)
      .onReady(() => {
        this.drawGauge();
      })
  }

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  private drawGauge(): void {
    const ctx = this.context;
    const width = 300;
    const height = 200;
    const centerX = width / 2;
    const centerY = height - 20;
    const radius = 140;

    ctx.clearRect(0, 0, width, height);

    // Draw arc background
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.85, Math.PI * 0.15, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#E0E0E0';
    ctx.stroke();

    // Draw green zone (in tune)
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.95, Math.PI * 1.05, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#4CAF50';
    ctx.stroke();

    // Draw yellow zones
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.85, Math.PI * 0.95, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#FFC107';
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 1.05, Math.PI * 1.15, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#FFC107';
    ctx.stroke();

    // Draw red zones
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 1.15, Math.PI * 1.25, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#F44336';
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 0.85, false);
    ctx.lineWidth = 8;
    ctx.strokeStyle = '#F44336';
    ctx.stroke();

    // Draw needle
    const angle = Math.PI / 2 - (this.cents / 50) * (Math.PI * 0.4);
    const needleLen = radius - 20;
    const needleX = centerX + Math.cos(angle) * needleLen;
    const needleY = centerY - Math.sin(angle) * needleLen;

    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(needleX, needleY);
    ctx.lineWidth = 4;
    ctx.strokeStyle = this.isActive ? '#2196F3' : '#999999';
    ctx.stroke();

    // Center dot
    ctx.beginPath();
    ctx.arc(centerX, centerY, 8, 0, Math.PI * 2);
    ctx.fillStyle = '#333333';
    ctx.fill();

    // Labels
    ctx.font = '12px sans-serif';
    ctx.fillStyle = '#666666';
    ctx.textAlign = 'center';
    ctx.fillText('-50', centerX - radius + 20, centerY - 10);
    ctx.fillText('0', centerX, centerY - radius + 20);
    ctx.fillText('+50', centerX + radius - 20, centerY - 10);
  }
}
