import { Theme } from '../common/Theme';

/** Canvas 柱状图（近 7 日刷题趋势） */
@Component
export struct BarChart {
  @Prop @Watch('redraw') labels: string[] = [];
  @Prop @Watch('redraw') values: number[] = [];
  @Prop chartHeight: number = 180;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  private drawBar(x: number, y: number, w: number, h: number, r: number): void {
    const rr: number = Math.min(r, w / 2, h);
    this.ctx.beginPath();
    this.ctx.moveTo(x, y + h);
    this.ctx.lineTo(x, y + rr);
    this.ctx.arcTo(x, y, x + rr, y, rr);
    this.ctx.lineTo(x + w - rr, y);
    this.ctx.arcTo(x + w, y, x + w, y + rr, rr);
    this.ctx.lineTo(x + w, y + h);
    this.ctx.closePath();
    this.ctx.fill();
  }

  redraw(): void {
    if (!this.ready) {
      return;
    }
    const w: number = this.ctx.width > 0 ? this.ctx.width : 320;
    const h: number = this.chartHeight;
    this.ctx.clearRect(0, 0, w, h);
    const n: number = this.values.length;
    if (n === 0) {
      return;
    }
    let max: number = 1;
    for (let i = 0; i < n; i++) {
      if (this.values[i] > max) {
        max = this.values[i];
      }
    }

    const leftPad = 8;
    const rightPad = 8;
    const topPad = 18;
    const bottomPad = 26;
    const chartH = h - topPad - bottomPad;
    const gap = 8;
    const barW = (w - leftPad - rightPad - gap * (n - 1)) / n;
    const baseY = h - bottomPad;

    // 横向网格线
    this.ctx.strokeStyle = '#F0F2F7';
    this.ctx.lineWidth = 1;
    for (let g = 0; g <= 3; g++) {
      const gy = topPad + (chartH / 3) * g;
      this.ctx.beginPath();
      this.ctx.moveTo(leftPad, gy);
      this.ctx.lineTo(w - rightPad, gy);
      this.ctx.stroke();
    }

    // 渐变
    const grad = this.ctx.createLinearGradient(0, topPad, 0, baseY);
    grad.addColorStop(0, Theme.primary);
    grad.addColorStop(1, '#9DB6FF');

    for (let i = 0; i < n; i++) {
      const x = leftPad + i * (barW + gap);
      const ratio = this.values[i] / max;
      const bh = chartH * ratio;
      const y = baseY - bh;

      this.ctx.fillStyle = grad;
      if (bh >= 2) {
        this.drawBar(x, y, barW, bh, 6);
      } else {
        // 数值为 0 时画一条浅色基线
        this.ctx.fillStyle = '#E6EAF2';
        this.ctx.fillRect(x, baseY - 2, barW, 2);
      }

      // 顶部数值
      if (this.values[i] > 0) {
        this.ctx.fillStyle = Theme.subText;
        this.ctx.font = '11px sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.fillText(this.values[i].toString(), x + barW / 2, y - 5);
      }

      // 底部日期标签
      this.ctx.fillStyle = '#A6ABB8';
      this.ctx.font = '11px sans-serif';
      this.ctx.textAlign = 'center';
      this.ctx.fillText(this.labels[i], x + barW / 2, h - 9);
    }
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(this.chartHeight)
      .onReady(() => {
        this.ready = true;
        this.redraw();
      })
  }
}
