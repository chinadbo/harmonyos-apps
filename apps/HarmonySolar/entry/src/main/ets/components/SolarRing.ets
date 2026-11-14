import { Palette } from '../common/Constants';

@Component
export struct SolarRing {
  @Prop @Watch('redraw') progress: number = 0;
  @Prop @Watch('redraw') ringColor: string = Palette.SUMMER;
  @Prop @Watch('redraw') trackColor: string = '#F0E8DA';
  @Prop @Watch('redraw') ringSize: number = 240;
  @Prop centerTitle: string = '';
  @Prop centerSub: string = '';
  @Prop centerFoot: string = '';
  @Prop centerFootTop: string = '';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasReady: boolean = false;

  private redraw(): void {
    this.draw();
  }

  private seasonColorAt(index: number): string {
    if (index === 0) {
      return Palette.SPRING;
    }
    if (index === 1) {
      return Palette.SUMMER;
    }
    if (index === 2) {
      return Palette.AUTUMN;
    }
    return Palette.WINTER;
  }

  private draw(): void {
    if (!this.canvasReady) {
      return;
    }
    const ctx: CanvasRenderingContext2D = this.context;
    const width: number = this.ringSize;
    const height: number = this.ringSize;
    if (width <= 0 || height <= 0) {
      return;
    }
    const cx: number = width / 2;
    const cy: number = height / 2;
    const radius: number = Math.min(width, height) / 2 - 24;
    ctx.clearRect(0, 0, width, height);

    for (let i: number = 0; i < 24; i++) {
      const angle: number = -Math.PI / 2 + i * Math.PI / 12;
      const major: boolean = i % 6 === 0;
      const inner: number = radius + (major ? 10 : 13);
      const outer: number = radius + (major ? 19 : 16);
      ctx.beginPath();
      ctx.moveTo(cx + Math.cos(angle) * inner, cy + Math.sin(angle) * inner);
      ctx.lineTo(cx + Math.cos(angle) * outer, cy + Math.sin(angle) * outer);
      ctx.lineWidth = major ? 2.5 : 1;
      ctx.strokeStyle = major ? Palette.GOLD : '#D8CDBB';
      ctx.stroke();
    }

    for (let s: number = 0; s < 4; s++) {
      const angle: number = -Math.PI / 2 + s * Math.PI / 2;
      ctx.beginPath();
      ctx.arc(cx + Math.cos(angle) * (radius + 22), cy + Math.sin(angle) * (radius + 22), 3.2, 0, Math.PI * 2);
      ctx.fillStyle = this.seasonColorAt(s);
      ctx.fill();
    }

    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, Math.PI * 2);
    ctx.lineWidth = 12;
    ctx.strokeStyle = this.trackColor;
    ctx.lineCap = 'round';
    ctx.stroke();

    let value: number = this.progress;
    if (value < 0) {
      value = 0;
    }
    if (value > 1) {
      value = 1;
    }
    const startAngle: number = -Math.PI / 2;
    const endAngle: number = startAngle + Math.PI * 2 * value;
    if (value > 0.001) {
      const gradient: CanvasGradient = ctx.createLinearGradient(cx - radius, cy - radius, cx + radius, cy + radius);
      gradient.addColorStop(0, this.ringColor);
      gradient.addColorStop(1, Palette.GOLD);
      ctx.beginPath();
      ctx.arc(cx, cy, radius, startAngle, endAngle, false);
      ctx.lineWidth = 12;
      ctx.strokeStyle = gradient;
      ctx.lineCap = 'round';
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(cx + Math.cos(endAngle) * radius, cy + Math.sin(endAngle) * radius, 5.5, 0, Math.PI * 2);
      ctx.fillStyle = this.ringColor;
      ctx.fill();
    }

    ctx.beginPath();
    ctx.arc(cx, cy, radius - 18, 0, Math.PI * 2);
    ctx.lineWidth = 1;
    ctx.strokeStyle = '#EFE6D5';
    ctx.stroke();
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width(this.ringSize)
        .height(this.ringSize)
        .onReady(() => {
          this.canvasReady = true;
          this.draw();
        })

      Column({ space: 6 }) {
        Text(this.centerSub)
          .fontSize(10)
          .letterSpacing(1.6)
          .fontColor(Palette.INK_FAINT)
          .maxLines(1)
        Text(this.centerTitle)
          .fontSize(36)
          .fontWeight(FontWeight.Medium)
          .fontColor(Palette.INK)
          .letterSpacing(4)
        Row()
          .width(24)
          .height(2)
          .backgroundColor(Palette.GOLD)
          .borderRadius(1)
        Text(this.centerFootTop)
          .fontSize(11)
          .fontColor(Palette.INK_SOFT)
        Text(this.centerFoot)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.ringColor)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width(this.ringSize)
    .height(this.ringSize)
  }
}
