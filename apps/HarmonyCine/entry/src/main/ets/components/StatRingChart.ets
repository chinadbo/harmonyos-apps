/**
 * StatRingChart：类型分布环形图（Canvas 自绘）。
 * onReady 后首次绘制；segments 变化时通过 @Watch 重绘。中心显示已看总数。
 */
import { RingSegment } from '../model/Movie';

@Component
export struct StatRingChart {
  @Prop @Watch('requestRedraw') segments: RingSegment[] = [];
  @Prop chartSize: number = 220;
  @Prop centerLabel: string = '看过';
  private renderSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderSettings);

  private totalValue(): number {
    let sum = 0;
    for (const seg of this.segments) {
      sum += seg.value;
    }
    return sum;
  }

  private requestRedraw(): void {
    this.drawChart();
  }

  private drawChart(): void {
    const ctx = this.canvasCtx;
    const size = this.chartSize;
    ctx.clearRect(0, 0, size, size);
    const cx = size / 2;
    const cy = size / 2;
    const radius = size * 0.34;
    const lineWidth = size * 0.12;
    ctx.lineWidth = lineWidth;
    ctx.lineCap = 'butt';

    const total = this.totalValue();
    if (total <= 0) {
      ctx.beginPath();
      ctx.arc(cx, cy, radius, 0, Math.PI * 2);
      ctx.strokeStyle = '#E6E8F0';
      ctx.stroke();
      return;
    }

    let startAngle = -Math.PI / 2;
    const gap = Math.PI / 90;
    for (const seg of this.segments) {
      if (seg.value <= 0) {
        continue;
      }
      const sweep = (seg.value / total) * Math.PI * 2;
      const endAngle = startAngle + Math.max(sweep - gap, 0.02);
      ctx.beginPath();
      ctx.arc(cx, cy, radius, startAngle, endAngle);
      ctx.strokeStyle = seg.color;
      ctx.stroke();
      startAngle += sweep;
    }

    ctx.fillStyle = '#22242E';
    ctx.font = `${Math.round(size * 0.13)}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.fillText(`${total}`, cx, cy + size * 0.03);
    ctx.fillStyle = '#8A8F9E';
    ctx.font = `${Math.round(size * 0.05)}px sans-serif`;
    ctx.fillText(this.centerLabel, cx, cy + size * 0.13);
  }

  build() {
    Column({ space: 14 }) {
      Canvas(this.canvasCtx)
        .width(this.chartSize)
        .height(this.chartSize)
        .onReady(() => {
          this.drawChart();
        })
      if (this.segments.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.segments, (seg: RingSegment) => {
            Row({ space: 8 }) {
              Column()
                .width(10)
                .height(10)
                .borderRadius(5)
                .backgroundColor(seg.color)
              Text(seg.label)
                .fontSize(13)
                .fontColor('#444652')
              Text(`${seg.value} 部`)
                .fontSize(13)
                .fontColor('#8A8F9E')
            }
            .alignItems(VerticalAlign.Center)
          }, (seg: RingSegment) => `${seg.label}_${seg.value}`)
        }
      } else {
        Text('暂无已看完的条目')
          .fontSize(13)
          .fontColor('#8A8F9E')
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}
