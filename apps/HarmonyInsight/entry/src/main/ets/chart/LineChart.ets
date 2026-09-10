import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig, SeriesData } from '../data/ChartDataModel';

/**
 * 折线图
 */
export class LineChart {
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

    // 绘制每条线
    for (let s = 0; s < seriesCount; s++) {
      const series = model.series[s];
      const color = series.color || config.colorScheme[s % config.colorScheme.length];
      const data = series.data;

      // 绘制折线
      if (data.length > 1) {
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.lineWidth = 2.5;
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
      }

      // 数据点
      for (let i = 0; i < data.length; i++) {
        const x = renderer.dataToCanvasX(i, data.length);
        const y = renderer.dataToCanvasY(data[i], min, max);

        if (config.showDataPoints) {
          renderer.drawDataPoint(x, y, color, 5);
        } else {
          renderer.drawCircle(x, y, 4, color, true);
          renderer.drawCircle(x, y, 4, '#FFFFFF', false);
        }

        // 标签
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
}
