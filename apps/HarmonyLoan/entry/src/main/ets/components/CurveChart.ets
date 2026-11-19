import { PaymentRow } from '../model/LoanTypes';
import { LoanCalculator, YearPoint } from '../model/LoanCalculator';

@Component
export default struct CurveChart {
  @Prop @Watch('onRowsChanged') rows: PaymentRow[] = [];
  @Prop title: string = '逐年还款曲线';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onRowsChanged(): void {
    if (this.ready) {
      this.draw();
    }
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
        Blank()
        Row({ space: 4 }) {
          Text('●')
            .fontSize(10)
            .fontColor('#2B6CF6')
          Text('本金')
            .fontSize(11)
            .fontColor('#6B7280')
          Text('●')
            .fontSize(10)
            .fontColor('#FF8A3D')
            .margin({ left: 6 })
          Text('利息')
            .fontSize(11)
            .fontColor('#6B7280')
        }
      }
      .width('100%')

      Canvas(this.canvasCtx)
        .width('100%')
        .height(180)
        .backgroundColor('#FAFBFF')
        .borderRadius(10)
        .onReady(() => {
          this.ready = true;
          this.draw();
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#10000000', offsetX: 0, offsetY: 4 })
  }

  private xPos(index: number, count: number, left: number, plotW: number): number {
    if (count <= 1) {
      return left + plotW / 2;
    }
    return left + plotW * index / (count - 1);
  }

  private drawSeries(points: YearPoint[], color: string, usePrincipal: boolean,
    left: number, top: number, plotW: number, plotH: number, maxValue: number): void {
    const ctx = this.canvasCtx;
    ctx.strokeStyle = color;
    ctx.lineWidth = 2;
    ctx.beginPath();
    for (let i = 0; i < points.length; i++) {
      const value = usePrincipal ? points[i].principalFen : points[i].interestFen;
      const x = this.xPos(i, points.length, left, plotW);
      const y = top + plotH - plotH * value / maxValue;
      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.stroke();

    ctx.fillStyle = color;
    for (let i = 0; i < points.length; i++) {
      const value = usePrincipal ? points[i].principalFen : points[i].interestFen;
      const x = this.xPos(i, points.length, left, plotW);
      const y = top + plotH - plotH * value / maxValue;
      ctx.beginPath();
      ctx.arc(x, y, 2.4, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  private draw(): void {
    const ctx = this.canvasCtx;
    const width = ctx.width;
    const height = ctx.height;
    if (width <= 0 || height <= 0) {
      return;
    }
    ctx.clearRect(0, 0, width, height);
    const points = LoanCalculator.yearly(this.rows);
    const left = 38;
    const right = 12;
    const top = 14;
    const bottom = 22;
    const plotW = width - left - right;
    const plotH = height - top - bottom;

    if (points.length === 0) {
      ctx.fillStyle = '#9CA3AF';
      ctx.font = '12px sans-serif';
      ctx.fillText('暂无数据', left, height / 2);
      return;
    }

    let maxValue = 0;
    for (let i = 0; i < points.length; i++) {
      if (points[i].principalFen > maxValue) {
        maxValue = points[i].principalFen;
      }
      if (points[i].interestFen > maxValue) {
        maxValue = points[i].interestFen;
      }
    }
    if (maxValue <= 0) {
      maxValue = 1;
    }

    ctx.strokeStyle = '#E8ECF5';
    ctx.lineWidth = 1;
    ctx.font = '9px sans-serif';
    for (let g = 0; g <= 4; g++) {
      const y = top + plotH - plotH * g / 4;
      ctx.beginPath();
      ctx.moveTo(left, y);
      ctx.lineTo(left + plotW, y);
      ctx.stroke();
      ctx.fillStyle = '#9CA3AF';
      ctx.fillText(LoanCalculator.fenToWan(maxValue * g / 4), 2, y + 3);
    }

    ctx.fillStyle = '#9CA3AF';
    ctx.font = '9px sans-serif';
    for (let i = 0; i < points.length; i++) {
      const show = i === 0 || i === points.length - 1 || (points.length > 2 && i === Math.floor(points.length / 2));
      if (show) {
        const x = this.xPos(i, points.length, left, plotW);
        ctx.fillText(points[i].year + '年', x - 10, height - 6);
      }
    }

    this.drawSeries(points, '#2B6CF6', true, left, top, plotW, plotH, maxValue);
    this.drawSeries(points, '#FF8A3D', false, left, top, plotW, plotH, maxValue);

    ctx.fillStyle = '#9CA3AF';
    ctx.font = '9px sans-serif';
    ctx.fillText('单位: 万元', left + 2, top + 8);
  }
}
