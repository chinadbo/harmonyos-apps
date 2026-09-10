import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig } from '../data/ChartDataModel';

/**
 * 饼图 / 环形图
 */
export class PieChart {
  static render(ctx: canvas.CanvasRenderingContext2D, width: number, height: number,
    model: ChartDataModel, config: ChartConfig, isDonut: boolean = false,
    highlightIndex: number = -1): void {

    const renderer = new ChartRenderer(ctx, width, height, config);
    renderer.fillBackground();

    if (model.series.length === 0 || model.xAxisLabels.length === 0) return;

    // 合并所有系列数据
    const totalData: { label: string; value: number; color: string }[] = [];
    let allSeriesData: number[] = [];
    let colorIdx = 0;

    for (const series of model.series) {
      allSeriesData = allSeriesData.concat(series.data);
    }

    for (let i = 0; i < model.xAxisLabels.length; i++) {
      const val = allSeriesData[i] ?? 0;
      if (val > 0) {
        totalData.push({
          label: model.xAxisLabels[i],
          value: val,
          color: config.colorScheme[colorIdx % config.colorScheme.length]
        });
        colorIdx++;
      }
    }

    if (totalData.length === 0) return;

    const total = totalData.reduce((sum, d) => sum + d.value, 0);
    const cx = width / 2;
    const cy = height / 2;
    const radius = Math.min(width, height) / 2 - 80;
    const innerRadius = isDonut ? radius * 0.5 : 0;
    const labelRadius = radius + 30;

    // 标题
    renderer.drawTitle(model.title, -30);

    let startAngle = -Math.PI / 2;

    for (let i = 0; i < totalData.length; i++) {
      const item = totalData[i];
      const sliceAngle = (item.value / total) * Math.PI * 2;
      const endAngle = startAngle + sliceAngle;
      const midAngle = startAngle + sliceAngle / 2;

      const isHighlight = highlightIndex === i;
      const r = isHighlight ? radius + 10 : radius;

      // 绘制扇形
      this.drawArcSegment(ctx, cx, cy, r, innerRadius, startAngle, endAngle, item.color);

      // 标签（百分比）
      const percent = (item.value / total * 100).toFixed(1);
      const labelX = cx + Math.cos(midAngle) * labelRadius;
      const labelY = cy + Math.sin(midAngle) * labelRadius;

      renderer.drawText(`${item.label}: ${percent}%`, labelX, labelY, {
        fontSize: 12,
        color: renderer.foregroundColor,
        align: Math.abs(midAngle) < Math.PI / 2 ? 'left' : 'right',
        baseline: 'middle'
      });

      startAngle = endAngle;
    }

    // 环形图中心文字
    if (isDonut) {
      renderer.drawText(total.toFixed(0), cx, cy - 10, {
        fontSize: 20,
        color: config.theme === 'dark' ? '#FFFFFF' : '#1A1A1A',
        align: 'center',
        baseline: 'middle'
      });
      renderer.drawText('Total', cx, cy + 15, {
        fontSize: 12,
        color: renderer.axisColor,
        align: 'center',
        baseline: 'middle'
      });
    }
  }

  private static drawArcSegment(
    ctx: canvas.CanvasRenderingContext2D,
    cx: number, cy: number,
    radius: number, innerRadius: number,
    startAngle: number, endAngle: number,
    color: string
  ): void {
    ctx.beginPath();
    ctx.arc(cx, cy, radius, startAngle, endAngle);
    if (innerRadius > 0) {
      ctx.arc(cx, cy, innerRadius, endAngle, startAngle, true);
    } else {
      ctx.lineTo(cx, cy);
    }
    ctx.closePath();
    ctx.fillStyle = color;
    ctx.fill();

    // 描边
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 2;
    ctx.stroke();
  }
}
