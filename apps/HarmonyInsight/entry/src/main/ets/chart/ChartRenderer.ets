import canvas from '@ohos.graphics.canvas';
import { ChartConfig } from '../data/ChartDataModel';

/**
 * Canvas 基础绘制上下文封装
 * 提供通用绘图方法：坐标转换、文本、线条、矩形、圆、扇形等
 */
export class ChartRenderer {
  private ctx: canvas.CanvasRenderingContext2D;
  private width: number;
  private height: number;
  private config: ChartConfig;

  // 边距
  private readonly PADDING = { top: 50, right: 50, bottom: 50, left: 60 };
  // 绘图区域
  private chartArea: { x: number, y: number, w: number, h: number };

  constructor(ctx: canvas.CanvasRenderingContext2D, width: number, height: number, config: ChartConfig) {
    this.ctx = ctx;
    this.width = width;
    this.height = height;
    this.config = config;

    this.chartArea = {
      x: this.PADDING.left,
      y: this.PADDING.top,
      w: width - this.PADDING.left - this.PADDING.right,
      h: height - this.PADDING.top - this.PADDING.bottom
    };
  }

  // ── 颜色 ──
  get foregroundColor(): string {
    return this.config.theme === 'dark' ? '#FFFFFF' : '#1A1A1A';
  }

  get backgroundColor(): string {
    return this.config.theme === 'dark' ? '#1A1A1A' : '#FFFFFF';
  }

  get gridColor(): string {
    return this.config.theme === 'dark' ? '#333333' : '#E8E8E8';
  }

  get axisColor(): string {
    return this.config.theme === 'dark' ? '#666666' : '#999999';
  }

  // ── 文本绘制 ──
  drawText(
    text: string,
    x: number,
    y: number,
    options: {
      fontSize?: number;
      color?: string;
      align?: 'left' | 'center' | 'right';
      baseline?: 'top' | 'middle' | 'bottom';
      maxWidth?: number;
    } = {}
  ): void {
    const fontSize = options.fontSize ?? 14;
    const color = options.color ?? this.foregroundColor;
    const align = options.align ?? 'left';
    const baseline = options.baseline ?? 'top';

    this.ctx.font = `${fontSize}px sans-serif`;
    this.ctx.fillStyle = color;
    this.ctx.textAlign = align;
    this.ctx.textBaseline = baseline;

    if (options.maxWidth && this.ctx.measureText(text).width > options.maxWidth) {
      let displayText = text;
      while (this.ctx.measureText(displayText + '...').width > options.maxWidth && displayText.length > 1) {
        displayText = displayText.slice(0, -1);
      }
      this.ctx.fillText(displayText + '...', x, y);
    } else {
      this.ctx.fillText(text, x, y);
    }
  }

  // ── 线条绘制 ──
  drawLine(x1: number, y1: number, x2: number, y2: number, options: {
    color?: string;
    width?: number;
    dash?: number[];
  } = {}): void {
    const color = options.color ?? this.axisColor;
    const width = options.width ?? 1;

    this.ctx.strokeStyle = color;
    this.ctx.lineWidth = width;
    this.ctx.beginPath();
    this.ctx.moveTo(x1, y1);
    this.ctx.lineTo(x2, y2);

    if (options.dash) {
      this.ctx.setLineDash(options.dash);
    } else {
      this.ctx.setLineDash([]);
    }

    this.ctx.stroke();
  }

  // ── 矩形填充 ──
  fillRect(x: number, y: number, w: number, h: number, color: string): void {
    this.ctx.fillStyle = color;
    this.ctx.fillRect(x, y, w, h);
  }

  // ── 圆角矩形 ──
  fillRoundedRect(x: number, y: number, w: number, h: number, radius: number, color: string): void {
    this.ctx.fillStyle = color;
    this.ctx.beginPath();
    this.ctx.moveTo(x + radius, y);
    this.ctx.lineTo(x + w - radius, y);
    this.ctx.arcTo(x + w, y, x + w, y + h, radius);
    this.ctx.lineTo(x + w, y + h - radius);
    this.ctx.arcTo(x + w, y + h, x + w - radius, y + h, radius);
    this.ctx.lineTo(x + radius, y + h);
    this.ctx.arcTo(x, y + h, x, y + h - radius, radius);
    this.ctx.lineTo(x, y + radius);
    this.ctx.arcTo(x, y, x + radius, y, radius);
    this.ctx.closePath();
    this.ctx.fill();
  }

  // ── 圆形/点 ──
  drawCircle(cx: number, cy: number, radius: number, color: string, fill: boolean = true): void {
    this.ctx.beginPath();
    this.ctx.arc(cx, cy, radius, 0, Math.PI * 2);
    if (fill) {
      this.ctx.fillStyle = color;
      this.ctx.fill();
    } else {
      this.ctx.strokeStyle = color;
      this.ctx.lineWidth = 2;
      this.ctx.stroke();
    }
  }

  // ── 扇形 ──
  drawSector(cx: number, cy: number, radius: number, startAngle: number, endAngle: number, color: string): void {
    this.ctx.beginPath();
    this.ctx.moveTo(cx, cy);
    this.ctx.arc(cx, cy, radius, startAngle, endAngle);
    this.ctx.closePath();
    this.ctx.fillStyle = color;
    this.ctx.fill();
  }

  // ── 背景填充 ──
  fillBackground(): void {
    this.fillRect(0, 0, this.width, this.height, this.backgroundColor);
  }

  // ── 坐标轴标签 ──
  drawXAxisLabels(labels: string[], count: number): void {
    if (labels.length === 0) return;

    const step = this.chartArea.w / Math.max(labels.length - 1, 1);
    const y = this.chartArea.y + this.chartArea.h + 10;

    for (let i = 0; i < labels.length; i++) {
      const x = this.chartArea.x + i * step;
      this.drawText(labels[i], x, y, {
        fontSize: 12,
        color: this.axisColor,
        align: 'center'
      });
    }
  }

  drawYAxisLabels(min: number, max: number, steps: number = 5): void {
    const step = (max - min) / steps;
    const labelStep = this.chartArea.h / steps;

    for (let i = 0; i <= steps; i++) {
      const val = min + step * i;
      const y = this.chartArea.y + this.chartArea.h - labelStep * i;
      const x = this.chartArea.x - 8;

      this.drawText(val.toFixed(1), x, y, {
        fontSize: 12,
        color: this.axisColor,
        align: 'right',
        baseline: 'middle'
      });
    }
  }

  // ── 网格线 ──
  drawGrid(min: number, max: number, steps: number = 5): void {
    if (!this.config.showGrid) return;

    const step = (max - min) / steps;
    const labelStep = this.chartArea.h / steps;

    for (let i = 0; i <= steps; i++) {
      const y = this.chartArea.y + this.chartArea.h - labelStep * i;
      this.drawLine(
        this.chartArea.x,
        y,
        this.chartArea.x + this.chartArea.w,
        y,
        { color: this.gridColor, dash: [3, 3] }
      );
    }
  }

  // ── 标题 ──
  drawTitle(title: string, yOffset: number = -30): void {
    this.drawText(title, this.width / 2, this.chartArea.y + yOffset, {
      fontSize: 18,
      color: this.foregroundColor,
      align: 'center'
    });
  }

  // ── 图例 ──
  drawLegend(series: { name: string; color: string }[], x: number, y: number): void {
    if (!this.config.showLegend || series.length === 0) return;

    const itemWidth = 100;
    const itemHeight = 24;
    const colorBoxSize = 12;
    const gap = 8;

    let row = 0;
    let col = 0;
    const maxCols = Math.floor((this.width - this.PADDING.left - this.PADDING.right) / itemWidth);

    for (const s of series) {
      const itemX = x + col * itemWidth;
      const itemY = y + row * itemHeight;

      this.fillRect(itemX, itemY + 6, colorBoxSize, colorBoxSize, s.color);
      this.drawText(s.name, itemX + colorBoxSize + gap, itemY + 8, {
        fontSize: 12,
        color: this.foregroundColor
      });

      col++;
      if (col >= maxCols) {
        col = 0;
        row++;
      }
    }
  }

  // ── 数据点标记 ──
  drawDataPoint(cx: number, cy: number, color: string, size: number = 4): void {
    this.drawCircle(cx, cy, size, color, true);
    this.drawCircle(cx, cy, size + 1, color, false);
  }

  // ── 渐变填充 ──
  createLinearGradient(x0: number, y0: number, x1: number, y1: number, colors: string[]): canvas.CanvasGradient {
    const gradient = this.ctx.createLinearGradient(x0, y0, x1, y1);
    const step = 1 / (colors.length - 1);
    for (let i = 0; i < colors.length; i++) {
      gradient.addColorStop(i * step, colors[i]);
    }
    return gradient;
  }

  // ── 获取绘图区域 ──
  get chartAreaRect(): { x: number, y: number, w: number, h: number } {
    return { ...this.chartArea };
  }

  // ── 坐标转换 ──
  dataToCanvasX(index: number, total: number): number {
    if (total <= 1) return this.chartArea.x + this.chartArea.w / 2;
    return this.chartArea.x + (index / (total - 1)) * this.chartArea.w;
  }

  dataToCanvasY(value: number, min: number, max: number): number {
    if (max === min) return this.chartArea.y + this.chartArea.h / 2;
    const ratio = (value - min) / (max - min);
    return this.chartArea.y + this.chartArea.h - ratio * this.chartArea.h;
  }
}
