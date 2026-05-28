import { SleepRecord, formatDate } from '../model/SleepRecord';

@Component
export struct TrendChart {
  @Prop records: SleepRecord[] = [];
  @Prop targetHours: number = 8;
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  build() {
    Column() {
      Text('睡眠时长趋势')
        .fontSize(14)
        .fontColor('#888888')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })
      Canvas(this.context)
        .width('100%')
        .height(180)
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
    const paddingLeft = 40;
    const paddingRight = 16;
    const paddingTop = 16;
    const paddingBottom = 32;
    const chartWidth = width - paddingLeft - paddingRight;
    const chartHeight = height - paddingTop - paddingBottom;

    ctx.clearRect(0, 0, width, height);

    // 背景网格
    ctx.strokeStyle = '#F0F0F0';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 4; i++) {
      const y = paddingTop + (chartHeight / 4) * i;
      ctx.beginPath();
      ctx.moveTo(paddingLeft, y);
      ctx.lineTo(width - paddingRight, y);
      ctx.stroke();
    }

    // Y 轴标签（0,3,6,9,12 小时）
    ctx.fillStyle = '#AAAAAA';
    ctx.font = '10px sans-serif';
    ctx.textAlign = 'right';
    const maxHours = 12;
    for (let i = 0; i <= 4; i++) {
      const hours = maxHours - (maxHours / 4) * i;
      const y = paddingTop + (chartHeight / 4) * i;
      ctx.fillText(`${hours}h`, paddingLeft - 4, y + 4);
    }

    // 目标线
    const targetY = paddingTop + chartHeight * (1 - this.targetHours / maxHours);
    ctx.strokeStyle = '#5B8DEF';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 4]);
    ctx.beginPath();
    ctx.moveTo(paddingLeft, targetY);
    ctx.lineTo(width - paddingRight, targetY);
    ctx.stroke();
    ctx.setLineDash([]);

    if (this.records.length === 0) return;

    // 数据点
    const sortedRecords = [...this.records].sort((a, b) => a.sleepTime - b.sleepTime);
    const count = sortedRecords.length;
    const step = count > 1 ? chartWidth / (count - 1) : 0;

    // 折线
    ctx.strokeStyle = '#5B8DEF';
    ctx.lineWidth = 2;
    ctx.beginPath();
    sortedRecords.forEach((r, i) => {
      const x = paddingLeft + (count > 1 ? step * i : chartWidth / 2);
      const hours = r.duration / 60;
      const y = paddingTop + chartHeight * (1 - Math.min(hours / maxHours, 1));
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();

    // 数据点圆圈
    sortedRecords.forEach((r, i) => {
      const x = paddingLeft + (count > 1 ? step * i : chartWidth / 2);
      const hours = r.duration / 60;
      const y = paddingTop + chartHeight * (1 - Math.min(hours / maxHours, 1));
      ctx.fillStyle = '#5B8DEF';
      ctx.beginPath();
      ctx.arc(x, y, 4, 0, Math.PI * 2);
      ctx.fill();
    });

    // X 轴日期标签（最多显示 7 个）
    ctx.fillStyle = '#AAAAAA';
    ctx.textAlign = 'center';
    const labelStep = Math.max(1, Math.floor(count / 7));
    sortedRecords.forEach((r, i) => {
      if (i % labelStep === 0 || i === count - 1) {
        const x = paddingLeft + (count > 1 ? step * i : chartWidth / 2);
        ctx.fillText(formatDate(r.sleepTime), x, height - 4);
      }
    });
  }
}
