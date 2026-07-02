import { RenderingContextSettings, CanvasRenderingContext2D } from '@ohos.arkui';

@Component
export struct CompassFace {
  @Watch('onHeadingChanged')
  @Prop heading: number = 0;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasSize: number = 320;

  onHeadingChanged() {
    this.drawCompass();
  }

  build() {
    Canvas(this.context)
      .width(this.canvasSize)
      .height(this.canvasSize)
      .backgroundColor('#16213e')
      .borderRadius(this.canvasSize / 2)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.5)', offsetX: 0, offsetY: 4 })
      .onReady(() => {
        this.drawCompass();
      })
  }

  private drawCompass(): void {
    let ctx = this.context;
    let size = this.canvasSize;
    let center = size / 2;
    let radius = size / 2 - 24;
    let needleLength = radius - 50;

    // Clear canvas
    ctx.clearRect(0, 0, size, size);

    // Outer glow ring
    ctx.beginPath();
    ctx.arc(center, center, radius + 8, 0, 2 * Math.PI);
    ctx.strokeStyle = 'rgba(233, 69, 96, 0.15)';
    ctx.lineWidth = 2;
    ctx.stroke();

    // Main compass circle
    ctx.beginPath();
    ctx.arc(center, center, radius, 0, 2 * Math.PI);
    ctx.fillStyle = '#16213e';
    ctx.fill();
    ctx.strokeStyle = '#0f3460';
    ctx.lineWidth = 2;
    ctx.stroke();

    // Inner decorative circle
    ctx.beginPath();
    ctx.arc(center, center, radius - 18, 0, 2 * Math.PI);
    ctx.strokeStyle = 'rgba(15, 52, 96, 0.5)';
    ctx.lineWidth = 1;
    ctx.stroke();

    // Save context and rotate for compass face
    ctx.save();
    ctx.translate(center, center);
    ctx.rotate(-this.heading * Math.PI / 180);

    // Draw degree tick marks
    for (let i = 0; i < 360; i += 10) {
      let angle = (i - 90) * Math.PI / 180;
      let isCardinal = i % 90 === 0;
      let isIntercardinal = i % 45 === 0 && !isCardinal;
      let tickInner = radius - (isCardinal ? 22 : isIntercardinal ? 16 : 10);

      ctx.beginPath();
      ctx.moveTo(Math.cos(angle) * tickInner, Math.sin(angle) * tickInner);
      ctx.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
      ctx.strokeStyle = isCardinal ? '#FFFFFF' : isIntercardinal ? '#8892b0' : 'rgba(136, 146, 176, 0.5)';
      ctx.lineWidth = isCardinal ? 2.5 : isIntercardinal ? 1.5 : 1;
      ctx.stroke();
    }

    // Draw degree numbers (every 30 degrees)
    ctx.font = '11px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    for (let i = 0; i < 360; i += 30) {
      if (i % 90 === 0) continue; // Skip cardinal positions (will draw letters there)
      let angle = (i - 90) * Math.PI / 180;
      let textR = radius - 34;
      ctx.fillStyle = '#8892b0';
      ctx.fillText(i.toString(), Math.cos(angle) * textR, Math.sin(angle) * textR);
    }

    // Draw direction letters
    interface DirectionInfo {
      name: string;
      angle: number;
      color: string;
      fontSize: number;
    }

    let directions: DirectionInfo[] = [
      { name: 'N', angle: 0, color: '#e94560', fontSize: 28 },
      { name: 'NE', angle: 45, color: '#8892b0', fontSize: 14 },
      { name: 'E', angle: 90, color: '#FFFFFF', fontSize: 24 },
      { name: 'SE', angle: 135, color: '#8892b0', fontSize: 14 },
      { name: 'S', angle: 180, color: '#FFFFFF', fontSize: 24 },
      { name: 'SW', angle: 225, color: '#8892b0', fontSize: 14 },
      { name: 'W', angle: 270, color: '#FFFFFF', fontSize: 24 },
      { name: 'NW', angle: 315, color: '#8892b0', fontSize: 14 }
    ];

    for (let dir of directions) {
      let angle = (dir.angle - 90) * Math.PI / 180;
      let textR = radius - 56;
      ctx.font = `bold ${dir.fontSize}px sans-serif`;
      ctx.fillStyle = dir.color;
      ctx.fillText(dir.name, Math.cos(angle) * textR, Math.sin(angle) * textR);
    }

    // Restore context (face rotation undone)
    ctx.restore();

    // Draw static needle (always points up / North)
    this.drawNeedle(ctx, center, center, needleLength);

    // Draw center pivot
    ctx.beginPath();
    ctx.arc(center, center, 12, 0, 2 * Math.PI);
    ctx.fillStyle = '#1a1a2e';
    ctx.fill();
    ctx.strokeStyle = '#0f3460';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(center, center, 6, 0, 2 * Math.PI);
    ctx.fillStyle = '#e94560';
    ctx.fill();
  }

  private drawNeedle(ctx: CanvasRenderingContext2D, cx: number, cy: number, length: number): void {
    let width = 10;
    let baseOffset = 6;

    // North half (red, pointing up)
    ctx.beginPath();
    ctx.moveTo(cx, cy - baseOffset);
    ctx.lineTo(cx - width, cy + baseOffset);
    ctx.lineTo(cx, cy - length);
    ctx.lineTo(cx + width, cy + baseOffset);
    ctx.closePath();
    ctx.fillStyle = '#e94560';
    ctx.fill();

    // Add highlight to North half
    ctx.beginPath();
    ctx.moveTo(cx, cy - baseOffset);
    ctx.lineTo(cx - width * 0.5, cy);
    ctx.lineTo(cx, cy - length + 10);
    ctx.lineTo(cx, cy - baseOffset);
    ctx.closePath();
    ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
    ctx.fill();

    // South half (blue, pointing down)
    ctx.beginPath();
    ctx.moveTo(cx, cy + baseOffset);
    ctx.lineTo(cx - width, cy - baseOffset);
    ctx.lineTo(cx, cy + length);
    ctx.lineTo(cx + width, cy - baseOffset);
    ctx.closePath();
    ctx.fillStyle = '#0f3460';
    ctx.fill();

    // Needle outline
    ctx.beginPath();
    ctx.moveTo(cx, cy - length);
    ctx.lineTo(cx - width, cy + baseOffset);
    ctx.lineTo(cx, cy + length);
    ctx.lineTo(cx + width, cy + baseOffset);
    ctx.closePath();
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.3)';
    ctx.lineWidth = 1;
    ctx.stroke();
  }
}