export interface ChartPoint {
  x: number;
  y: number;
}

const MAX_WEEK: number = 40;
const COLOR_LINE: string = '#EC4899';
const COLOR_BAND: string = 'rgba(236, 72, 153, 0.16)';
const COLOR_GRID: string = '#F4E4EC';
const COLOR_AXIS: string = '#E6C9D8';
const COLOR_LABEL: string = '#A08A97';

// 建议增重下限（kg）：早孕共 +1kg，中晚孕每周 +0.4kg，总量不超过 11.5kg
export function recommendedGainLower(week: number): number {
  const w: number = Math.max(0, Math.min(MAX_WEEK, week));
  if (w <= 13) {
    return w / 13.0;
  }
  return Math.min(11.5, 1.0 + (w - 13) * 0.4);
}

// 建议增重上限（kg）：早孕共 +2kg，中晚孕每周 +0.4kg，总量不超过 16kg
export function recommendedGainUpper(week: number): number {
  const w: number = Math.max(0, Math.min(MAX_WEEK, week));
  if (w <= 13) {
    return 2.0 * w / 13.0;
  }
  return Math.min(16.0, 2.0 + (w - 13) * 0.4);
}

@Component
export struct LineChart {
  @Prop @Watch('onPointsChanged') points: ChartPoint[] = [];
  private ready: boolean = false;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  onPointsChanged(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private draw(): void {
    const ctx: CanvasRenderingContext2D = this.ctx;
    const width: number = ctx.width;
    const height: number = ctx.height;
    ctx.clearRect(0, 0, width, height);
    if (this.points.length === 0) {
      return;
    }

    const padLeft: number = width * 0.1;
    const padRight: number = width * 0.04;
    const padTop: number = height * 0.07;
    const padBottom: number = height * 0.13;
    const plotW: number = width - padLeft - padRight;
    const plotH: number = height - padTop - padBottom;
    if (plotW <= 0 || plotH <= 0) {
      return;
    }
    const hairLine: number = Math.max(1, width * 0.004);
    const lineWidth: number = Math.max(1.5, width * 0.007);
    const dotRadius: number = Math.max(2, width * 0.009);
    const labelSize: number = Math.max(9, width * 0.028);

    const sorted: ChartPoint[] = this.points.slice();
    sorted.sort((a: ChartPoint, b: ChartPoint): number => a.x - b.x);

    // 以首条记录反推孕前体重，使增重区间带与实测体重共用同一纵轴
    const baseline: number = sorted[0].y - recommendedGainLower(sorted[0].x);

    let yMin: number = baseline;
    let yMax: number = baseline + recommendedGainUpper(MAX_WEEK);
    for (let i = 0; i < sorted.length; i++) {
      if (sorted[i].y < yMin) {
        yMin = sorted[i].y;
      }
      if (sorted[i].y > yMax) {
        yMax = sorted[i].y;
      }
    }
    if (yMax - yMin < 1) {
      yMax = yMin + 1;
    }
    const margin: number = (yMax - yMin) * 0.08;
    yMin -= margin;
    yMax += margin;

    const toX: (value: number) => number = (value: number): number => {
      let w: number = value;
      if (w < 0) {
        w = 0;
      }
      if (w > MAX_WEEK) {
        w = MAX_WEEK;
      }
      return padLeft + (w / MAX_WEEK) * plotW;
    };
    const toY: (value: number) => number = (value: number): number => {
      return padTop + (1 - (value - yMin) / (yMax - yMin)) * plotH;
    };

    // 纵向网格
    ctx.strokeStyle = COLOR_GRID;
    ctx.lineWidth = hairLine;
    for (let i = 0; i <= 4; i++) {
      const gy: number = padTop + (plotH / 4) * i;
      ctx.beginPath();
      ctx.moveTo(padLeft, gy);
      ctx.lineTo(padLeft + plotW, gy);
      ctx.stroke();
    }

    // 参考区间带
    ctx.beginPath();
    for (let w = 0; w <= MAX_WEEK; w++) {
      const px: number = toX(w);
      const py: number = toY(baseline + recommendedGainUpper(w));
      if (w === 0) {
        ctx.moveTo(px, py);
      } else {
        ctx.lineTo(px, py);
      }
    }
    for (let w = MAX_WEEK; w >= 0; w--) {
      ctx.lineTo(toX(w), toY(baseline + recommendedGainLower(w)));
    }
    ctx.closePath();
    ctx.fillStyle = COLOR_BAND;
    ctx.fill();

    // 坐标轴
    ctx.strokeStyle = COLOR_AXIS;
    ctx.lineWidth = hairLine;
    ctx.beginPath();
    ctx.moveTo(padLeft, padTop);
    ctx.lineTo(padLeft, padTop + plotH);
    ctx.lineTo(padLeft + plotW, padTop + plotH);
    ctx.stroke();

    // 实测折线
    ctx.beginPath();
    for (let i = 0; i < sorted.length; i++) {
      const px: number = toX(sorted[i].x);
      const py: number = toY(sorted[i].y);
      if (i === 0) {
        ctx.moveTo(px, py);
      } else {
        ctx.lineTo(px, py);
      }
    }
    ctx.strokeStyle = COLOR_LINE;
    ctx.lineWidth = lineWidth;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    // 数据点
    for (let i = 0; i < sorted.length; i++) {
      const px: number = toX(sorted[i].x);
      const py: number = toY(sorted[i].y);
      ctx.beginPath();
      ctx.arc(px, py, dotRadius, 0, Math.PI * 2);
      ctx.fillStyle = '#FFFFFF';
      ctx.fill();
      ctx.strokeStyle = COLOR_LINE;
      ctx.lineWidth = hairLine * 1.6;
      ctx.stroke();
    }

    // 刻度文案
    ctx.font = `${labelSize}px sans-serif`;
    ctx.fillStyle = COLOR_LABEL;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    const labelGap: number = width * 0.015;
    const weekTicks: number[] = [0, 10, 20, 30, 40];
    for (let i = 0; i < weekTicks.length; i++) {
      ctx.fillText(`${weekTicks[i]}`, toX(weekTicks[i]), padTop + plotH + labelGap);
    }

    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    const midValue: number = (yMin + yMax) / 2;
    ctx.fillText(yMax.toFixed(1), padLeft - labelGap, toY(yMax));
    ctx.fillText(midValue.toFixed(1), padLeft - labelGap, toY(midValue));
    ctx.fillText(yMin.toFixed(1), padLeft - labelGap, toY(yMin));
  }

  build() {
    Column() {
      if (this.points.length === 0) {
        Column() {
          Text('暂无体重数据')
            .fontSize(14)
            .fontColor('#B59AA8')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        Canvas(this.ctx)
          .width('100%')
          .height(200)
          .onReady(() => {
            this.ready = true;
            this.draw();
          })
      }
    }
    .width('100%')
  }
}
