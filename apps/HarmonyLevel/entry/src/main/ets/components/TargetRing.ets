import { AngleSolver } from '../data/AngleSolver';

const REDRAW_INTERVAL_MS: number = 16;
const LEVEL_TOL: number = 0.5;
const NEAR_TOL: number = 2.0;

// 目标角度环：0/45/90 目标判定可视化，指针指向当前角度，命中目标变绿。
@Component
export struct TargetRing {
  @Prop @Watch('onAngleChanged') angle: number = 0;
  @Prop @Watch('onAngleChanged') target: number = -1;
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
    const r: number = Math.min(w, h) / 2 - 8;
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

    for (let d = 0; d < 360; d += 15) {
      const rad: number = (d - 90) * Math.PI / 180;
      const major: boolean = d % 90 === 0;
      const len: number = major ? 12 : 6;
      ctx.beginPath();
      ctx.moveTo(cx + Math.cos(rad) * (r - 4), cy + Math.sin(rad) * (r - 4));
      ctx.lineTo(cx + Math.cos(rad) * (r - 4 - len), cy + Math.sin(rad) * (r - 4 - len));
      ctx.strokeStyle = major ? '#55636f' : '#333e49';
      ctx.lineWidth = major ? 2 : 1;
      ctx.stroke();
    }

    let needleColor: string = '#37c8f0';
    let diff: number = 0;
    if (this.target >= 0) {
      diff = AngleSolver.normalize180(this.angle - this.target);
      needleColor = Math.abs(diff) <= LEVEL_TOL ? '#35e08a' :
        (Math.abs(diff) <= NEAR_TOL ? '#ffc14d' : '#37c8f0');
      const targetRad: number = (this.target - 90) * Math.PI / 180;
      ctx.strokeStyle = '#35e08a';
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(cx + Math.cos(targetRad) * r * 0.72, cy + Math.sin(targetRad) * r * 0.72);
      ctx.lineTo(cx + Math.cos(targetRad) * (r - 2), cy + Math.sin(targetRad) * (r - 2));
      ctx.stroke();
    }

    const needleRad: number = (this.angle - 90) * Math.PI / 180;
    ctx.strokeStyle = needleColor;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(cx + Math.cos(needleRad) * r * 0.12, cy + Math.sin(needleRad) * r * 0.12);
    ctx.lineTo(cx + Math.cos(needleRad) * r * 0.68, cy + Math.sin(needleRad) * r * 0.68);
    ctx.stroke();

    ctx.fillStyle = needleColor;
    ctx.beginPath();
    ctx.arc(cx, cy, 5, 0, TAU);
    ctx.fill();
  }
}
