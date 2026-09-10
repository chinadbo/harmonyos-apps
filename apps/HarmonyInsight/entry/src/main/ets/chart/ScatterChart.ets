import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig } from '../data/ChartDataModel';

/**
 * 散点图
 */
export class ScatterChart {
  static render(ctx: canvas.CanvasRenderingContext2D, width: number, height: number,
    model: ChartDataModel, config: ChartConfig): void {

    const renderer = new ChartRenderer(ctx, width, height, config);
    renderer.fillBackground();

    if (model.series.length === 0 || model.xAxisLabels.length === 0) return;

    const { min, max } = model.getRange();
    const dataMax = model.getMaxSeriesLength();

    // 标题
    renderer.drawTitle(model.title, -30);

    // 网格 + 轴标签
    renderer.drawGrid(min, max, 5);
    renderer.drawYAxisLabels(min, max, 5);

    // 绘制散点
    for (let s = 0; s < model.series.length; s++) {
      const series = model.series[s];
      const color = series.color || config.colorScheme[s % config.colorScheme.length];
      const data = series.data;

      for (let i = 0; i < data.length; i++) {
        const x = renderer.dataToCanvasX(i, dataMax);
        const y = renderer.dataToCanvasY(data[i], min, max);

        // 绘制散点（空心圆）
        renderer.drawCircle(x, y, 6, color, false);
        renderer.drawCircle(x, y, 3, color, true);

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
