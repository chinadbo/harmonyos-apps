import { Theme } from '../utils/Theme';

/**
 * 通用统计图表（Canvas 实现，在 onReady 回调中绘制）：
 * - bar：柱状图（默认）
 * - line：平滑曲线（成长曲线用）
 */
@Component
export struct StatChart {
  @Prop @Watch('onDataChanged') values: number[] = [];
  @Prop @Watch('onDataChanged') labels: string[] = [];
  @Prop @Watch('onDataChanged') mode: string = 'bar';
  @Prop @Watch('onDataChanged') chartColor: string = Theme.PRIMARY;
  @Prop unit: string = '';
  @Prop decimals: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private static readonly PAD_LEFT: number = 38;
  private static readonly PAD_RIGHT: number = 10;
  private static readonly PAD_TOP: number = 22;
  private static readonly PAD_BOTTOM: number = 26;

  onDataChanged(): void {
    this.draw();
  }

  private draw(): void {
    const ctx = this.context;
    const w = ctx.width;
    const h = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = Theme.CARD;
    ctx.fillRect(0, 0, w, h);

    const chartW = w - StatChart.PAD_LEFT - StatChart.PAD_RIGHT;
    const chartH = h - StatChart.PAD_TOP - StatChart.PAD_BOTTOM;

    if (this.values.length === 0) {
      ctx.fillStyle = Theme.TEXT_LIGHT;
      ctx.font = '14px sans-serif';
      ctx.fillText('暂无数据', w / 2 - 28, h / 2);
      return;
    }

    let maxVal = 0;
    for (let i = 0; i < this.values.length; i++) {
      if (this.values[i] > maxVal) {
        maxVal = this.values[i];
      }
    }
    if (maxVal <= 0) {
      maxVal = 1;
    }

    // 横向网格与刻度
    ctx.strokeStyle = Theme.BORDER;
    ctx.lineWidth = 1;
    ctx.font = '10px sans-serif';
    const gridCount = 4;
    for (let g = 0; g <= gridCount; g++) {
      const y = StatChart.PAD_TOP + chartH - chartH * g / gridCount;
      ctx.beginPath();
      ctx.moveTo(StatChart.PAD_LEFT, y);
      ctx.lineTo(w - StatChart.PAD_RIGHT, y);
      ctx.stroke();
      const tickVal = maxVal * g / gridCount;
      ctx.fillStyle = Theme.TEXT_LIGHT;
      ctx.fillText(this.formatTick(tickVal), 4, y + 3);
    }

    const n = this.values.length;
    const stepX = chartW / n;
    const labelSkip = Math.max(1, Math.ceil(n / 7));

    if (this.mode === 'line') {
      this.drawCurve(ctx, maxVal, chartH, stepX, n);
    } else {
      this.drawBars(ctx, maxVal, chartH, stepX, n);
    }

    // x 轴标签
    ctx.font = '10px sans-serif';
    ctx.fillStyle = Theme.TEXT_SUB;
    ctx.textAlign = 'center';
    for (let i = 0; i < n; i += labelSkip) {
      const x = StatChart.PAD_LEFT + stepX * i + stepX / 2;
      if (i < this.labels.length) {
        ctx.fillText(this.labels[i], x, h - 8);
      }
    }
    ctx.textAlign = 'start';
  }

  private drawBars(ctx: CanvasRenderingContext2D, maxVal: number, chartH: number,
                   stepX: number, n: number): void {
    const barW = Math.min(stepX * 0.56, 42);
    for (let i = 0; i < n; i++) {
      const v = this.values[i];
      const barH = chartH * (v / maxVal);
      const x = StatChart.PAD_LEFT + stepX * i + (stepX - barW) / 2;
      const y = StatChart.PAD_TOP + chartH - barH;
      if (barH > 0) {
        const r = Math.min(6, barW / 2, barH);
        ctx.fillStyle = this.chartColor;
        ctx.beginPath();
        ctx.moveTo(x, y + r);
        ctx.lineTo(x, y + barH);
        ctx.lineTo(x + barW, y + barH);
        ctx.lineTo(x + barW, y + r);
        ctx.quadraticCurveTo(x + barW, y, x + barW - r, y);
        ctx.lineTo(x + r, y);
        ctx.quadraticCurveTo(x, y, x, y + r);
        ctx.closePath();
        ctx.fill();
      }
      if (v > 0) {
        ctx.fillStyle = Theme.TEXT_SUB;
        ctx.font = '10px sans-serif';
        ctx.fillText(this.formatTick(v), StatChart.PAD_LEFT + stepX * i + stepX / 2 - 8,
          y - 4);
      }
    }
  }

  private drawCurve(ctx: CanvasRenderingContext2D, maxVal: number, chartH: number,
                    stepX: number, n: number): void {
    if (n < 1) {
      return;
    }
    const pointsX: number[] = [];
    const pointsY: number[] = [];
    for (let i = 0; i < n; i++) {
      pointsX.push(StatChart.PAD_LEFT + stepX * i + stepX / 2);
      pointsY.push(StatChart.PAD_TOP + chartH - chartH * (this.values[i] / maxVal));
    }

    // 曲线下渐变面积
    ctx.globalAlpha = 0.15;
    ctx.fillStyle = this.chartColor;
    ctx.beginPath();
    ctx.moveTo(pointsX[0], pointsY[0]);
    for (let i = 1; i < n; i++) {
      const midX = (pointsX[i - 1] + pointsX[i]) / 2;
      const midY = (pointsY[i - 1] + pointsY[i]) / 2;
      ctx.quadraticCurveTo(pointsX[i - 1], pointsY[i - 1], midX, midY);
    }
    ctx.lineTo(pointsX[n - 1], pointsY[n - 1]);
    ctx.lineTo(pointsX[n - 1], StatChart.PAD_TOP + chartH);
    ctx.lineTo(pointsX[0], StatChart.PAD_TOP + chartH);
    ctx.closePath();
    ctx.fill();
    ctx.globalAlpha = 1;

    // 平滑曲线
    ctx.strokeStyle = this.chartColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(pointsX[0], pointsY[0]);
    for (let i = 1; i < n; i++) {
      const midX = (pointsX[i - 1] + pointsX[i]) / 2;
      const midY = (pointsY[i - 1] + pointsY[i]) / 2;
      ctx.quadraticCurveTo(pointsX[i - 1], pointsY[i - 1], midX, midY);
    }
    ctx.lineTo(pointsX[n - 1], pointsY[n - 1]);
    ctx.stroke();

    // 数据点与数值
    for (let i = 0; i < n; i++) {
      ctx.beginPath();
      ctx.arc(pointsX[i], pointsY[i], 3.2, 0, Math.PI * 2);
      ctx.fillStyle = '#FFFFFF';
      ctx.fill();
      ctx.strokeStyle = this.chartColor;
      ctx.lineWidth = 2;
      ctx.stroke();
      if (this.values[i] > 0) {
        ctx.fillStyle = Theme.TEXT_SUB;
        ctx.font = '10px sans-serif';
        ctx.fillText(this.formatTick(this.values[i]), pointsX[i] - 10, pointsY[i] - 8);
      }
    }
  }

  private formatTick(v: number): string {
    let text = '';
    if (this.decimals <= 0) {
      text = String(Math.round(v));
    } else {
      text = v.toFixed(this.decimals);
    }
    if (this.unit.length > 0) {
      text = text + this.unit;
    }
    return text;
  }

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height(240)
        .onReady(() => {
          this.draw();
        })
    }
    .width('100%')
    .backgroundColor(Theme.CARD)
    .borderRadius(16)
  }
}
