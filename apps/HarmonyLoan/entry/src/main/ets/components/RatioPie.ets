import { LoanCalculator } from '../model/LoanCalculator';

@Component
export default struct RatioPie {
  @Prop @Watch('onDataChanged') principalFen: number = 0;
  @Prop @Watch('onDataChanged') interestFen: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onDataChanged(): void {
    if (this.ready) {
      this.draw();
    }
  }

  build() {
    Column({ space: 6 }) {
      Row() {
        Text('本息构成')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
        Blank()
        Text('总计 ' + LoanCalculator.fenToWan(this.principalFen + this.interestFen) + ' 万')
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .width('100%')

      Canvas(this.canvasCtx)
        .width('100%')
        .height(160)
        .onReady(() => {
          this.ready = true;
          this.draw();
        })

      Row({ space: 6 }) {
        Text('●')
          .fontSize(10)
          .fontColor('#2B6CF6')
        Text('本金')
          .fontSize(11)
          .fontColor('#6B7280')
        Text(LoanCalculator.fenToWan(this.principalFen) + ' 万')
          .fontSize(11)
          .fontColor('#111827')
          .margin({ right: 10 })
        Text('●')
          .fontSize(10)
          .fontColor('#FF8A3D')
        Text('利息')
          .fontSize(11)
          .fontColor('#6B7280')
        Text(LoanCalculator.fenToWan(this.interestFen) + ' 万')
          .fontSize(11)
          .fontColor('#111827')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: '#10000000', offsetX: 0, offsetY: 4 })
  }

  private draw(): void {
    const ctx = this.canvasCtx;
    const width = ctx.width;
    const height = ctx.height;
    if (width <= 0 || height <= 0) {
      return;
    }
    ctx.clearRect(0, 0, width, height);
    const principal = this.principalFen > 0 ? this.principalFen : 0;
    const interest = this.interestFen > 0 ? this.interestFen : 0;
    const total = principal + interest;
    const cx = width / 2;
    const cy = height / 2;
    const radius = Math.min(width, height) / 2 - 10;

    if (total <= 0 || radius <= 0) {
      ctx.fillStyle = '#9CA3AF';
      ctx.font = '12px sans-serif';
      ctx.fillText('暂无数据', cx - 24, cy);
      return;
    }

    const principalAngle = Math.PI * 2 * principal / total;
    const startAngle = -Math.PI / 2;

    ctx.fillStyle = '#2B6CF6';
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.arc(cx, cy, radius, startAngle, startAngle + principalAngle);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = '#FF8A3D';
    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.arc(cx, cy, radius, startAngle + principalAngle, startAngle + Math.PI * 2);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(cx, cy, radius * 0.6, 0, Math.PI * 2);
    ctx.fill();

    const interestPercent = Math.round(interest / total * 100);
    ctx.fillStyle = '#6B7280';
    ctx.font = '11px sans-serif';
    ctx.fillText('利息占比', cx - 24, cy - 6);
    ctx.fillStyle = '#FF8A3D';
    ctx.font = 'bold 18px sans-serif';
    ctx.fillText(interestPercent.toString() + '%', cx - 20, cy + 16);
  }
}
