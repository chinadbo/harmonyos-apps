const REDRAW_INTERVAL_MS: number = 16;
const SPAN_DEG: number = 40;

// Canvas 刻度尺：以当前角度为中心的 ±20° 滚动刻度带，中心指针固定。
@Component
export struct AngleRuler {
  @Prop @Watch('onAngleChanged') angle: number = 0;
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private ready: boolean = false;
  private lastDraw: number = 0;
  private pending: boolean = false;

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(64)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }

  private onAngleChanged(): void {
    if (!this.ready) {
      return;
    }
    const now: number = Date.now();
    const elapsed: number = now - this.lastDraw;
    if (elapsed >= REDRAW_INTERVAL_MS) {
      this.lastDraw = now;
      this.draw();
      return;
    }
    if (this.pending) {
      return;
    }
    this.pending = true;
    setTimeout(() => {
      this.pending = false;
      this.lastDraw = Date.now();
      this.draw();
    }, REDRAW_INTERVAL_MS - elapsed);
  }

  private draw(): void {
    if (!this.ready) {
      return;
    }
    const ctx: CanvasRenderingContext2D = this.ctx;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = '#1a222c';
    ctx.fillRect(0, 2, w, h - 4);
    ctx.strokeStyle = '#2c3947';
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 2.5, w - 1, h - 5);

    const pxPerDeg: number = w / SPAN_DEG;
    const center: number = w / 2;
    const baseline: number = h * 0.55;
    const startT: number = Math.floor(this.angle - SPAN_DEG / 2);
    const endT: number = Math.ceil(this.angle + SPAN_DEG / 2);

    ctx.strokeStyle = '#2c3947';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(4, baseline);
    ctx.lineTo(w - 4, baseline);
    ctx.stroke();

    for (let t = startT; t <= endT; t++) {
      const x: number = center + (t - this.angle) * pxPerDeg;
      if (x < -30 || x > w + 30) {
        continue;
      }
      const norm: number = ((t % 360) + 360) % 360;
      const major: boolean = norm % 10 === 0;
      const mid: boolean = norm % 5 === 0;
      const len: number = major ? 16 : (mid ? 10 : 5);
      ctx.beginPath();
      ctx.moveTo(x, baseline);
      ctx.lineTo(x, baseline - len);
      ctx.strokeStyle = major ? '#7a8b99' : (mid ? '#55636f' : '#333e49');
      ctx.lineWidth = major ? 2 : 1;
      ctx.stroke();
      if (major) {
        ctx.fillStyle = '#93a1b0';
        ctx.font = '12px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(norm.toString() + '°', x, baseline + 16);
      }
    }

    ctx.strokeStyle = '#37c8f0';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(center, baseline);
    ctx.lineTo(center, 10);
    ctx.stroke();
    ctx.fillStyle = '#37c8f0';
    ctx.beginPath();
    ctx.moveTo(center - 6, 8);
    ctx.lineTo(center + 6, 8);
    ctx.lineTo(center, 18);
    ctx.closePath();
    ctx.fill();
  }
}
