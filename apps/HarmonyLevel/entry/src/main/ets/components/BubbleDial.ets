const LEVEL_TOL: number = 1.0;
const REDRAW_INTERVAL_MS: number = 16;

// Canvas 气泡表盘：上下文仅在 onReady 后有效，绘制前统一判空；
// 角度更新经 @Watch 进入，内部做 16ms 节流重绘。
@Component
export struct BubbleDial {
  @Prop @Watch('onAngleChanged') pitch: number = 0;
  @Prop @Watch('onAngleChanged') roll: number = 0;
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private ready: boolean = false;
  private lastDraw: number = 0;
  private pending: boolean = false;

  build() {
    Canvas(this.ctx)
      .width('100%')
      .aspectRatio(1)
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
    const cx: number = w / 2;
    const cy: number = h / 2;
    const r: number = Math.min(w, h) / 2 - 6;
    const TAU: number = Math.PI * 2;

    ctx.clearRect(0, 0, w, h);

    const bg = ctx.createRadialGradient(cx, cy, r * 0.1, cx, cy, r);
    bg.addColorStop(0, '#1d2733');
    bg.addColorStop(1, '#0d1218');
    ctx.fillStyle = bg;
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, TAU);
    ctx.fill();
    ctx.strokeStyle = '#3a4654';
    ctx.lineWidth = 2;
    ctx.stroke();

    for (let d = 0; d < 360; d += 10) {
      const major: boolean = d % 30 === 0;
      const rad: number = (d - 90) * Math.PI / 180;
      const len: number = major ? 12 : 6;
      ctx.beginPath();
      ctx.moveTo(cx + Math.cos(rad) * (r - 4), cy + Math.sin(rad) * (r - 4));
      ctx.lineTo(cx + Math.cos(rad) * (r - 4 - len), cy + Math.sin(rad) * (r - 4 - len));
      ctx.strokeStyle = major ? '#55636f' : '#333e49';
      ctx.lineWidth = major ? 2 : 1;
      ctx.stroke();
    }

    ctx.setLineDash([4, 4]);
    ctx.strokeStyle = '#26313c';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(cx - r * 0.8, cy);
    ctx.lineTo(cx + r * 0.8, cy);
    ctx.moveTo(cx, cy - r * 0.8);
    ctx.lineTo(cx, cy + r * 0.8);
    ctx.stroke();
    ctx.setLineDash([]);

    const pxPerDeg: number = (r * 0.7) / 30;
    ctx.strokeStyle = '#2a3540';
    ctx.lineWidth = 1;
    for (let i = 0; i < 2; i++) {
      const ringR: number = (i === 0 ? 10 : 20) * pxPerDeg;
      ctx.beginPath();
      ctx.arc(cx, cy, ringR, 0, TAU);
      ctx.stroke();
    }

    const level: boolean = Math.abs(this.pitch) <= LEVEL_TOL && Math.abs(this.roll) <= LEVEL_TOL;
    const targetR: number = r * 0.18;
    if (level) {
      ctx.fillStyle = 'rgba(53, 224, 138, 0.15)';
      ctx.beginPath();
      ctx.arc(cx, cy, targetR, 0, TAU);
      ctx.fill();
    }
    ctx.strokeStyle = level ? '#35e08a' : '#3a4654';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(cx, cy, targetR, 0, TAU);
    ctx.stroke();

    const rb: number = r * 0.15;
    let dx: number = -this.roll * pxPerDeg;
    let dy: number = -this.pitch * pxPerDeg;
    const maxOff: number = r - rb - 6;
    const mag: number = Math.sqrt(dx * dx + dy * dy);
    if (mag > maxOff && mag > 0) {
      dx = dx / mag * maxOff;
      dy = dy / mag * maxOff;
    }
    const bx: number = cx + dx;
    const by: number = cy + dy;

    const bubble = ctx.createRadialGradient(bx - rb * 0.3, by - rb * 0.3, rb * 0.1, bx, by, rb);
    bubble.addColorStop(0, '#8df2c8');
    bubble.addColorStop(0.5, '#35e08a');
    bubble.addColorStop(1, '#1d9e63');
    ctx.fillStyle = bubble;
    ctx.beginPath();
    ctx.arc(bx, by, rb, 0, TAU);
    ctx.fill();
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.25)';
    ctx.lineWidth = 1;
    ctx.stroke();
    ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.beginPath();
    ctx.arc(bx - rb * 0.35, by - rb * 0.35, rb * 0.22, 0, TAU);
    ctx.fill();
  }
}
