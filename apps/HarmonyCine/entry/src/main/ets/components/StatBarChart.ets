/**
 * StatBarChart：月度观影柱状图（Canvas 自绘）。
 * 近 N 月每月看完条目数，items 变化时 @Watch 重绘。
 */
import { BarItem } from '../model/Movie';

@Component
export struct StatBarChart {
  @Prop @Watch('requestRedraw') items: BarItem[] = [];
  @Prop chartWidth: number = 320;
  @Prop chartHeight: number = 190;
  private renderSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderSettings);

  private maxValue(): number {
    let max = 0;
    for (const item of this.items) {
      if (item.value > max) {
        max = item.value;
      }
    }
    return max > 0 ? max : 1;
  }

  private requestRedraw(): void {
    this.drawChart();
  }

  private drawChart(): void {
    const ctx = this.canvasCtx;
    const w = this.chartWidth;
    const h = this.chartHeight;
    ctx.clearRect(0, 0, w, h);

    const padLeft = 16;
    const padBottom = 26;
    const padTop = 18;
    const axisY = h - padBottom;

    // 基线
    ctx.beginPath();
    ctx.moveTo(padLeft, axisY);
    ctx.lineTo(w - 4, axisY);
    ctx.strokeStyle = '#E6E8F0';
    ctx.lineWidth = 1;
    ctx.stroke();

    const count = this.items.length;
    if (count === 0) {
      return;
    }
    const max = this.maxValue();
    const usableW = w - padLeft - 8;
    const slot = usableW / count;
    const barW = Math.min(slot * 0.5, 34);

    for (let i = 0; i < count; i++) {
      const item = this.items[i];
      const cx = padLeft + slot * i + slot / 2;
      const plotH = axisY - padTop;
      const barH = item.value > 0 ? Math.max(item.value / max * plotH, 4) : 2;
      const topY = axisY - barH;

      if (item.value > 0) {
        ctx.fillStyle = '#5B7CFA';
      } else {
        ctx.fillStyle = '#E6E8F0';
      }
      ctx.beginPath();
      ctx.rect(cx - barW / 2, topY, barW, barH);
      ctx.fill();

      // 数值标签
      if (item.value > 0) {
        ctx.fillStyle = '#444652';
        ctx.font = '11px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(`${item.value}`, cx, topY - 4);
      }

      // 月份标签
      ctx.fillStyle = '#8A8F9E';
      ctx.font = '11px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(item.label, cx, axisY + 15);
    }
  }

  build() {
    Column() {
      Canvas(this.canvasCtx)
        .width(this.chartWidth)
        .height(this.chartHeight)
        .onReady(() => {
          this.drawChart();
        })
    }
    .alignItems(HorizontalAlign.Center)
  }
}
