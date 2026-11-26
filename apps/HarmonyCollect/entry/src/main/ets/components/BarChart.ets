/**
 * BarChart.ets — Canvas 自绘柱状图（成色分布）
 */
import { ConditionStat } from '../model/StatsModel';
import { C_TEXT, C_SUB, C_LINE } from '../common/Constants';

@Component
export struct BarChart {
  @Prop @Watch('onDataChange') data: ConditionStat[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onDataChange(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private shortLabel(condition: string): string {
    if (condition === '有使用痕迹') {
      return '痕迹';
    }
    if (condition === '仅配件') {
      return '配件';
    }
    if (condition.length > 4) {
      return condition.substring(0, 3);
    }
    return condition;
  }

  private draw(): void {
    const ctx = this.ctx;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);

    const left: number = 12;
    const right: number = 12;
    const top: number = 24;
    const bottom: number = 30;
    const chartW: number = w - left - right;
    const chartH: number = h - top - bottom;

    const n: number = this.data.length;
    if (n === 0) {
      ctx.fillStyle = C_SUB;
      ctx.font = '13px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('暂无数据', w / 2, h / 2);
      return;
    }

    let maxCount: number = 1;
    for (let i = 0; i < n; i++) {
      if (this.data[i].count > maxCount) {
        maxCount = this.data[i].count;
      }
    }

    const slot: number = chartW / n;
    const barW: number = Math.min(26, slot * 0.5);

    ctx.beginPath();
    ctx.strokeStyle = C_LINE;
    ctx.lineWidth = 1;
    ctx.moveTo(left, h - bottom);
    ctx.lineTo(w - right, h - bottom);
    ctx.stroke();

    for (let i = 0; i < n; i++) {
      const d: ConditionStat = this.data[i];
      const barH: number = maxCount <= 0 ? 0 : (d.count / maxCount) * chartH;
      const x: number = left + slot * i + (slot - barW) / 2;
      const y: number = h - bottom - barH;

      if (barH > 0) {
        ctx.fillStyle = d.color;
        ctx.fillRect(x, y, barW, barH);
      }

      ctx.fillStyle = C_TEXT;
      ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      ctx.fillText(d.count.toString(), x + barW / 2, y - 4);

      ctx.fillStyle = C_SUB;
      ctx.font = '10px sans-serif';
      ctx.textBaseline = 'top';
      ctx.fillText(this.shortLabel(d.condition), x + barW / 2, h - bottom + 6);
    }
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(200)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }
}
