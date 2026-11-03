import { Theme } from '../model/Theme';

@Component
export struct BarChartComponent {
  @Prop @Watch('onDataChange') values: number[] = [];
  @Prop @Watch('onDataChange') rates: number[] = [];
  @Prop labels: string[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2d: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasW: number = 0;
  private canvasH: number = 0;

  onDataChange(): void {
    this.draw();
  }

  build() {
    Canvas(this.context2d)
      .width('100%')
      .height(230)
      .onReady(() => {
        this.canvasW = this.context2d.width;
        this.canvasH = this.context2d.height;
        this.draw();
      })
  }

  private draw(): void {
    const ctx: CanvasRenderingContext2D = this.context2d;
    if (this.canvasW <= 0 || this.canvasH <= 0) {
      return;
    }
    ctx.clearRect(0, 0, this.canvasW, this.canvasH);
    const n: number = this.values.length;
    if (n === 0) {
      return;
    }
    const padL: number = 28;
    const padR: number = 8;
    const padT: number = 14;
    const padB: number = 28;
    const plotW: number = this.canvasW - padL - padR;
    const plotH: number = this.canvasH - padT - padB;
    let maxV: number = 10;
    for (const v of this.values) {
      if (v > maxV) {
        maxV = v;
      }
    }
    const slot: number = plotW / n;
    const barW: number = Math.min(24, slot * 0.5);

    ctx.strokeStyle = Theme.BORDER;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(padL, padT + plotH);
    ctx.lineTo(padL + plotW, padT + plotH);
    ctx.stroke();

    for (let i: number = 0; i < n; i++) {
      const v: number = this.values[i];
      const barH: number = maxV > 0 ? plotH * (v / maxV) : 0;
      const x: number = padL + slot * i + (slot - barW) / 2;
      const y: number = padT + plotH - barH;
      ctx.fillStyle = Theme.PRIMARY;
      if (barH > 1) {
        ctx.fillRect(x, y, barW, barH);
      } else {
        ctx.fillRect(x, padT + plotH - 2, barW, 2);
      }
      ctx.fillStyle = Theme.TEXT_SECONDARY;
      ctx.font = '11px sans-serif';
      ctx.textAlign = 'center';
      const label: string = i < this.labels.length ? this.labels[i] : '';
      ctx.fillText(label, padL + slot * i + slot / 2, padT + plotH + 18);
    }

    if (this.rates.length > 0) {
      ctx.strokeStyle = Theme.WARNING;
      ctx.lineWidth = 2;
      ctx.beginPath();
      let started: boolean = false;
      for (let i: number = 0; i < n && i < this.rates.length; i++) {
        const rate: number = Math.min(100, Math.max(0, this.rates[i]));
        const px: number = padL + slot * i + slot / 2;
        const py: number = padT + plotH * (1 - rate / 100);
        if (!started) {
          ctx.moveTo(px, py);
          started = true;
        } else {
          ctx.lineTo(px, py);
        }
      }
      ctx.stroke();

      ctx.fillStyle = Theme.WARNING;
      for (let i: number = 0; i < n && i < this.rates.length; i++) {
        const rate: number = Math.min(100, Math.max(0, this.rates[i]));
        const px: number = padL + slot * i + slot / 2;
        const py: number = padT + plotH * (1 - rate / 100);
        ctx.beginPath();
        ctx.arc(px, py, 3, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  }
}
