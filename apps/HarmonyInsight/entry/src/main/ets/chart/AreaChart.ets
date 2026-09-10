import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig } from '../data/ChartDataModel';

/**
 * 面积图
 */
export class AreaChart {
  static render(ctx: canvas.CanvasRenderingContext2D, width: number, height: number,
    model: ChartDataModel, config: ChartConfig): void {

    const renderer = new ChartRenderer(ctx, width, height, config);
    renderer.fillBackground();

    if (model.series.length === 0 || model.xAxisLabels.length === 0) return;

    const { min, max } = model.getRange();
    const dataMax = model.getMaxSeriesLength();
    const seriesCount = model.series.length;

    // 标题
    renderer.drawTitle(model.title, -30);

    // 网格 + 轴标签
    renderer.drawGrid(min, max, 5);
    renderer.drawYAxisLabels(min, max, 5);

    // 绘制面积图（从后往前，避免遮挡）
    for (let s = seriesCount - 1; s >= 0; s--) {
      const series = model.series[s];
      const color = series.color || config.colorScheme[s % config.colorScheme.length];
      const data = series.data;

      // 渐变填充
      const gradient = renderer.createLinearGradient(
        0, renderer.chartAreaRect.y,
        0, renderer.chartAreaRect.y + renderer.chartAreaRect.h,
        ['#FFFFFF00', this.hexToRGBA(color, 0.3), this.hexToRGBA(color, 0.1)]
      );

      // 绘制闭合路径（底部为基准线）
      ctx.beginPath();
      const baseY = renderer.dataToCanvasY(min, min, max);

      for (let i = 0; i < data.length; i++) {
        const x = renderer.dataToCanvasX(i, data.length);
        const y = renderer.dataToCanvasY(data[i], min, max);
        if (i === 0) {
          ctx.moveTo(x, baseY);
          ctx.lineTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }

      // 回到底部
      const lastX = renderer.dataToCanvasX(data.length - 1, data.length);
      ctx.lineTo(lastX, baseY);
      ctx.closePath();

      ctx.fillStyle = gradient;
      ctx.fill();

      // 描边
      ctx.beginPath();
      ctx.strokeStyle = color;
      ctx.lineWidth = 2;
      ctx.setLineDash([]);
      for (let i = 0; i < data.length; i++) {
        const x = renderer.dataToCanvasX(i, data.length);
        const y = renderer.dataToCanvasY(data[i], min, max);
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.stroke();

      // 数据点
      for (let i = 0; i < data.length; i++) {
        const x = renderer.dataToCanvasX(i, data.length);
        const y = renderer.dataToCanvasY(data[i], min, max);
        renderer.drawCircle(x, y, 3, color, true);

        if (config.showLabels) {
          renderer.drawText(data[i].toFixed(1), x, y - 12, {
            fontSize: 11,
            color: color,
            align: 'center'
          });
        }
      }
    }

    // X轴标签
    const step = Math.max(1, Math.floor(dataMax / 6));
    for (let i = 0; i < dataMax; i += step) {
      const x = renderer.dataToCanvasX(i, dataMax);
      renderer.drawText(model.xAxisLabels[i] || '', x,
        renderer.chartAreaRect.y + renderer.chartAreaRect.h + 10, {
          fontSize: 12,
          color: renderer.axisColor,
          align: 'center'
        });
    }

    // 图例
    renderer.drawLegend(
      model.series.map((s, idx) => ({
        name: s.name,
        color: s.color || config.colorScheme[idx % config.colorScheme.length]
      })),
      renderer.chartAreaRect.x,
      -10
    );
  }

  private static hexToRGBA(hex: string, alpha: number): string {
    const clean = hex.replace('#', '');
    const r = parseInt(clean.slice(0, 2), 16);
    const g = parseInt(clean.slice(2, 4), 16);
    const b = parseInt(clean.slice(4, 6), 16);
    return `rgba(${r},${g},${b},${alpha})`;
  }
}
