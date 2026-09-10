import canvas from '@ohos.graphics.canvas';
import { ChartRenderer } from './ChartRenderer';
import { ChartDataModel, ChartConfig } from '../data/ChartDataModel';

/**
 * 雷达图
 */
export class RadarChart {
  static render(ctx: canvas.CanvasRenderingContext2D, width: number, height: number,
    model: ChartDataModel, config: ChartConfig): void {

    const renderer = new ChartRenderer(ctx, width, height, config);
    renderer.fillBackground();

    if (model.series.length === 0 || model.xAxisLabels.length === 0) return;

    const { min, max } = model.getRange();
    const cx = width / 2;
    const cy = height / 2;
    const radius = Math.min(width, height) / 2 - 80;
    const axisCount = model.xAxisLabels.length;

    // 标题
    renderer.drawTitle(model.title, -30);

    // 绘制网格（同心多边形）
    const gridLevels = 5;
    for (let level = 1; level <= gridLevels; level++) {
      const r = (radius / gridLevels) * level;
      ctx.beginPath();
      for (let i = 0; i < axisCount; i++) {
        const angle = (i / axisCount) * Math.PI * 2 - Math.PI / 2;
        const x = cx + Math.cos(angle) * r;
        const y = cy + Math.sin(angle) * r;
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.closePath();
      ctx.strokeStyle = renderer.gridColor;
      ctx.lineWidth = 1;
      ctx.setLineDash([3, 3]);
      ctx.stroke();
    }

    // 绘制轴线
    for (let i = 0; i < axisCount; i++) {
      const angle = (i / axisCount) * Math.PI * 2 - Math.PI / 2;
      const x = cx + Math.cos(angle) * radius;
      const y = cy + Math.sin(angle) * radius;
      renderer.drawLine(cx, cy, x, y, { color: renderer.axisColor, width: 1 });

      // 轴标签
      const labelX = cx + Math.cos(angle) * (radius + 20);
      const labelY = cy + Math.sin(angle) * (radius + 20);
      renderer.drawText(model.xAxisLabels[i] || '', labelX, labelY, {
        fontSize: 12,
        color: renderer.foregroundColor,
        align: 'center',
        baseline: 'middle'
      });
    }

    // 绘制数据多边形
    for (let s = 0; s < model.series.length; s++) {
      const series = model.series[s];
      const color = series.color || config.colorScheme[s % config.colorScheme.length];
      const data = series.data;

      // 填充区域
      ctx.beginPath();
      for (let i = 0; i < axisCount; i++) {
        const angle = (i / axisCount) * Math.PI * 2 - Math.PI / 2;
        const val = data[i] ?? 0;
        const ratio = max > min ? (val - min) / (max - min) : 0;
        const r = ratio * radius;
        const x = cx + Math.cos(angle) * r;
        const y = cy + Math.sin(angle) * r;
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.closePath();

      // 半透明填充
      const fillColor = this.hexToRGBA(color, 0.2);
      ctx.fillStyle = fillColor;
      ctx.fill();

      // 描边
      ctx.strokeStyle = color;
      ctx.lineWidth = 2;
      ctx.setLineDash([]);
      ctx.stroke();

      // 数据点
      for (let i = 0; i < axisCount; i++) {
        const angle = (i / axisCount) * Math.PI * 2 - Math.PI / 2;
        const val = data[i] ?? 0;
        const ratio = max > min ? (val - min) / (max - min) : 0;
        const r = ratio * radius;
        const x = cx + Math.cos(angle) * r;
        const y = cy + Math.sin(angle) * r;

        renderer.drawCircle(x, y, 5, color, true);
        renderer.drawCircle(x, y, 5, '#FFFFFF', false);

        if (config.showLabels && config.showDataPoints) {
          const labelX = cx + Math.cos(angle) * (r + 15);
          const labelY = cy + Math.sin(angle) * (r + 15);
          renderer.drawText(val.toFixed(1), labelX, labelY, {
            fontSize: 10,
            color: color,
            align: 'center',
            baseline: 'middle'
          });
        }
      }
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
