import { PityConfig, cumulativeGoldProb } from '../engine/PityEngine';

@Component
export struct LuckCurve {
  @Prop @Watch('redraw') hardPity: number = 90;
  @Prop @Watch('redraw') softStart: number = 74;
  @Prop @Watch('redraw') expected: number = 62;
  @Prop @Watch('redraw') primaryColor: string = '#E8B542';
  @Prop @Watch('redraw') goldColor: string = '#FFD24A';
  @Prop @Watch('redraw') border: string = '#3A3428';
  @Prop @Watch('redraw') textSub: string = '#A89F8C';
  @Prop chartW: number = 340;
  @Prop chartH: number = 200;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  build() {
    Canvas(this.ctx)
      .width(this.chartW)
      .height(this.chartH)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }

  private redraw(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private draw(): void {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.chartW, this.chartH);
    const padL = 34;
    const padR = 12;
    const padT = 14;
    const padB = 22;
    const plotW = this.chartW - padL - padR;
    const plotH = this.chartH - padT - padB;
    const cfg = new PityConfig(this.hardPity, this.softStart);

    ctx.font = '9px sans-serif';
    ctx.fillStyle = this.textSub;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'right';
    for (let i = 0; i <= 4; i++) {
      const y = padT + plotH - plotH * i / 4;
      ctx.strokeStyle = this.border;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(padL, y);
      ctx.lineTo(padL + plotW, y);
      ctx.stroke();
      ctx.fillText(`${i * 25}%`, padL - 4, y);
    }

    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    const xTicks: number[] = [0, 15, 30, 45, 60, 75, this.hardPity];
    for (const t of xTicks) {
      const x = padL + plotW * t / this.hardPity;
      ctx.strokeStyle = this.border;
      ctx.beginPath();
      ctx.moveTo(x, padT + plotH);
      ctx.lineTo(x, padT + plotH + 3);
      ctx.stroke();
      ctx.fillText(`${t}`, x, padT + plotH + 5);
    }
    ctx.fillText('抽数', padL + plotW / 2, padT + plotH + 12);

    ctx.strokeStyle = this.border;
    ctx.beginPath();
    ctx.moveTo(padL, padT);
    ctx.lineTo(padL, padT + plotH);
    ctx.lineTo(padL + plotW, padT + plotH);
    ctx.stroke();

    ctx.strokeStyle = this.goldColor;
    ctx.setLineDash([4, 3]);
    const softX = padL + plotW * this.softStart / this.hardPity;
    ctx.beginPath();
    ctx.moveTo(softX, padT);
    ctx.lineTo(softX, padT + plotH);
    ctx.stroke();
    ctx.fillStyle = this.goldColor;
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.fillText('软保底', softX + 3, padT + 2);

    const expX = padL + plotW * this.expected / this.hardPity;
    ctx.strokeStyle = this.textSub;
    ctx.beginPath();
    ctx.moveTo(expX, padT);
    ctx.lineTo(expX, padT + plotH);
    ctx.stroke();
    ctx.fillStyle = this.textSub;
    ctx.fillText(`期望${this.expected}`, expX + 3, padT + 14);
    ctx.setLineDash([]);

    ctx.beginPath();
    ctx.moveTo(padL, padT + plotH);
    for (let i = 1; i <= this.hardPity; i++) {
      const p = cumulativeGoldProb(i, cfg);
      const x = padL + plotW * i / this.hardPity;
      const y = padT + plotH - plotH * p;
      ctx.lineTo(x, y);
    }
    ctx.lineTo(padL + plotW, padT + plotH);
    ctx.closePath();
    const grad = ctx.createLinearGradient(0, padT, 0, padT + plotH);
    grad.addColorStop(0, this.primaryColor);
    grad.addColorStop(1, this.primaryColor);
    ctx.globalAlpha = 0.15;
    ctx.fillStyle = grad;
    ctx.fill();
    ctx.globalAlpha = 1;

    ctx.strokeStyle = this.primaryColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(padL, padT + plotH);
    for (let i = 1; i <= this.hardPity; i++) {
      const p = cumulativeGoldProb(i, cfg);
      const x = padL + plotW * i / this.hardPity;
      const y = padT + plotH - plotH * p;
      ctx.lineTo(x, y);
    }
    ctx.stroke();
    ctx.lineWidth = 1;
  }
}
