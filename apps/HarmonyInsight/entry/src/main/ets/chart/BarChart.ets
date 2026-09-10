import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig, SeriesData } from '../data/ChartDataModel';

/**
 * 柱状图
 */
export class BarChart {
  static render(ctx: canvas.CanvasRenderingContext2D, width: number, height: number,
    model: ChartDataModel, config: ChartConfig, highlightIndex: number = -1): void {

    const renderer = new ChartRenderer(ctx, width, height, config);
    renderer.fillBackground();

    if (model.series.length === 0 || model.xAxisLabels.length === 0) return;

    const { min, max } = model.getRange();
    const dataMax = model.getMaxSeriesLength();
    const seriesCount = model.series.length;
    const barGroupWidth = renderer.chartAreaRect.w / dataMax * 0.7;
    const barWidth = barGroupWidth / seriesCount * 0.8;
    const barGap = (renderer.chartAreaRect.w - barGroupWidth) / (dataMax + 1);

    // 标题
    renderer.drawTitle(model.title, -30);

    // 网格 + Y轴标签
    renderer.drawGrid(min, max, 5);
    renderer.drawYAxisLabels(min, max, 5);

    // 绘制柱状图
    for (let i = 0; i < dataMax; i++) {
      const groupX = renderer.chartAreaRect.x + i * (renderer.chartAreaRect.w / dataMax);

      for (let s = 0; s < seriesCount; s++) {
        const series = model.series[s];
        const value = series.data[i] ?? 0;
        const color = series.color || config.colorScheme[s % config.colorScheme.length];
        const isHighlight = highlightIndex === i;

        const barX = groupX + s * barWidth + barGap / 2;
        const barY = renderer.dataToCanvasY(value, min, max);
        const barHeight = renderer.chartAreaRect.y + renderer.chartAreaRect.h - barY;

        const alpha = isHighlight ? 1 : 0.85;
        const c = this.hexToRGBA(color, alpha);

        const h = Math.max(barHeight, 2);
        renderer.fillRoundedRect(barX, barY, barWidth - 2, h, 3, c);

        // 数据标签
        if (config.showLabels) {
          renderer.drawText(value.toFixed(1), barX + barWidth / 2, barY - 10, {
            fontSize: 11,
            color: config.theme === 'dark' ? '#AAAAAA' : '#666666',
            align: 'center'
          });
        }
      }

      // X轴标签
      renderer.drawText(model.xAxisLabels[i] || '', groupX + renderer.chartAreaRect.w / dataMax / 2,
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
