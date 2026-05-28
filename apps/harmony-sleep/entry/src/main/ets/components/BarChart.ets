import { SleepRecord } from '../model/SleepRecord';

@Component
export struct BarChart {
  @Prop records: SleepRecord[] = [];
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  build() {
    Column() {
      Text('入睡时间分布')
        .fontSize(14)
        .fontColor('#888888')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      Canvas(this.context)
        .width('100%')
        .height(140)
        .onReady(() => {
          this.drawChart();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  drawChart(): void {
    const ctx = this.context;
    const width = ctx.width;
    const height = ctx.height;
    const paddingLeft = 30;
    const paddingBottom = 24;
    const paddingTop = 8;
    const paddingRight = 8;
    const chartWidth = width - paddingLeft - paddingRight;
    const chartHeight = height - paddingBottom - paddingTop;

    ctx.clearRect(0, 0, width, height);

    // 时间 bucket: 20,21,22,23,0,1,2,3,4,5,6,7
    const buckets = [20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7];
    const counts: number[] = new Array(12).fill(0);

    this.records.forEach(r => {
      const hour = new Date(r.sleepTime).getHours();
      const idx = buckets.indexOf(hour);
      if (idx !== -1) {
        counts[idx]++;
      }
    });

    const maxCount = Math.max(...counts, 1);
    const barWidth = chartWidth / 12 - 2;

    buckets.forEach((h, i) => {
      const x = paddingLeft + i * (chartWidth / 12) + 1;
      const barH = (counts[i] / maxCount) * chartHeight;
      const y = paddingTop + chartHeight - barH;

      ctx.fillStyle = counts[i] > 0 ? '#5B8DEF' : '#E8E8E8';
      ctx.beginPath();
      ctx.roundRect(x, y, barWidth, barH > 0 ? barH : 2, 3);
      ctx.fill();

      // 标签
      ctx.fillStyle = '#AAAAAA';
      ctx.font = '9px sans-serif';
      ctx.textAlign = 'center';
      if (h % 2 === 0) {
        ctx.fillText(`${h}`, x + barWidth / 2, height - 4);
      }
    });
  }
}
