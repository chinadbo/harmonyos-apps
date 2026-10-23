// 月相 Canvas 绘制组件：phase 0=朔 0.25=上弦 0.5=望 0.75=下弦
@Component
export struct MoonPhaseCanvas {
  @Prop @Watch('onPhaseChange') phase: number = 0;
  @Prop size: number = 200;
  private ready: boolean = false;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.ctx)
      .width(this.size)
      .height(this.size)
      .onReady(() => {
        this.ready = true;
        this.drawMoon();
      })
  }

  private onPhaseChange(): void {
    if (this.ready) {
      this.drawMoon();
    }
  }

  private drawMoon(): void {
    const ctx = this.ctx;
    const w = this.size;
    const h = this.size;
    const cx = w / 2;
    const cy = h / 2;
    const r = Math.min(w, h) / 2 - 6;
    ctx.clearRect(0, 0, w, h);

    // 光晕
    const glow = ctx.createRadialGradient(cx, cy, r * 0.6, cx, cy, r * 1.4);
    glow.addColorStop(0, 'rgba(245, 215, 110, 0.18)');
    glow.addColorStop(1, 'rgba(245, 215, 110, 0)');
    ctx.fillStyle = glow;
    ctx.beginPath();
    ctx.arc(cx, cy, r * 1.4, 0, Math.PI * 2);
    ctx.fill();

    // 暗底月盘
    ctx.fillStyle = '#1A2038';
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.fill();

    // 照亮区域：半圆沿外缘 + 椭圆沿明暗界线
    const p = ((this.phase % 1) + 1) % 1;
    if (p > 0.02 && p < 0.98) {
      if (p <= 0.5) {
        this.drawLitHalf(ctx, cx, cy, r, true, p * 2);
      } else {
        this.drawLitHalf(ctx, cx, cy, r, false, (p - 0.5) * 2);
      }
    }

    // 月海纹理
    ctx.globalAlpha = 0.15;
    ctx.fillStyle = '#8B7D5A';
    ctx.beginPath();
    ctx.arc(cx - r * 0.25, cy - r * 0.2, r * 0.22, 0, Math.PI * 2);
    ctx.arc(cx + r * 0.2, cy - r * 0.25, r * 0.16, 0, Math.PI * 2);
    ctx.arc(cx + r * 0.1, cy + r * 0.3, r * 0.18, 0, Math.PI * 2);
    ctx.arc(cx - r * 0.3, cy + r * 0.25, r * 0.12, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;

    // 边缘
    ctx.strokeStyle = 'rgba(242, 245, 255, 0.25)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, Math.PI * 2);
    ctx.stroke();
  }

  // t: 0=朔(细芽) 0.5=弦(半亮) 1=望(全亮)；waxing 时亮区在右
  private drawLitHalf(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number,
    waxing: boolean, t: number): void {
    const lit = ctx.createRadialGradient(cx + (waxing ? r * 0.3 : -r * 0.3), cy - r * 0.3, r * 0.2,
      cx, cy, r);
    lit.addColorStop(0, '#FFF7DC');
    lit.addColorStop(0.7, '#F5D76E');
    lit.addColorStop(1, '#E3BE62');
    ctx.fillStyle = lit;

    // 明暗界线椭圆半宽：t=0 -> 1（朔芽） 0.5 -> 0（直线） 1 -> 1（凸月）
    // t<0.5 娥眉（界线向亮侧凸），t>0.5 凸月（界线向暗侧凸），anticlockwise 统一按 t 判断
    const k = Math.abs(1 - 2 * t);
    const cw = t > 0.5;
    ctx.beginPath();
    if (waxing) {
      ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI / 2, false);
      ctx.ellipse(cx, cy, k * r, r, 0, Math.PI / 2, -Math.PI / 2, cw);
    } else {
      ctx.arc(cx, cy, r, Math.PI / 2, -Math.PI / 2, false);
      ctx.ellipse(cx, cy, k * r, r, 0, -Math.PI / 2, Math.PI / 2, cw);
    }
    ctx.closePath();
    ctx.fill();
  }
}
