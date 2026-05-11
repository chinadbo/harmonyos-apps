import { MoodStat } from '../model/DiaryModel';

@Component
export struct MoodPieChart {
  @Prop stats: MoodStat[] = [];
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  private drawChart(): void {
    const width = 240;
    const height = 240;
    const centerX = 120;
    const centerY = 120;
    const radius = 84;
    let startAngle = -Math.PI / 2;

    this.context.clearRect(0, 0, width, height);
    if (this.stats.length === 0) {
      this.context.fillStyle = '#E2E8F0';
      this.context.beginPath();
      this.context.arc(centerX, centerY, radius, 0, Math.PI * 2);
      this.context.fill();
      this.context.fillStyle = '#64748B';
      this.context.font = '14px sans-serif';
      this.context.fillText('暂无数据', 92, 125);
      return;
    }

    this.stats.forEach((item: MoodStat) => {
      const sweep = item.percentage * Math.PI * 2;
      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.fillStyle = item.color;
      this.context.arc(centerX, centerY, radius, startAngle, startAngle + sweep);
      this.context.closePath();
      this.context.fill();
      startAngle += sweep;
    });

    this.context.beginPath();
    this.context.fillStyle = '#FFFFFF';
    this.context.arc(centerX, centerY, 44, 0, Math.PI * 2);
    this.context.fill();
    this.context.fillStyle = '#0F172A';
    this.context.font = 'bold 18px sans-serif';
    this.context.fillText('心情', 102, 118);
    this.context.font = '12px sans-serif';
    this.context.fillStyle = '#64748B';
    this.context.fillText('分布', 108, 136);
  }

  build() {
    Column({ space: 16 }) {
      Canvas(this.context)
        .width(240)
        .height(240)
        .backgroundColor('#FFFFFF')
        .onReady(() => this.drawChart())

      Column({ space: 10 }) {
        ForEach(this.stats, (item: MoodStat) => {
          Row({ space: 10 }) {
            Blank()
              .width(12)
              .height(12)
              .backgroundColor(item.color)
              .borderRadius(6)
            Text(item.label)
              .fontSize(14)
              .fontColor('#334155')
            Blank()
            Text(`${item.count} 次 · ${Math.round(item.percentage * 100)}%`)
              .fontSize(13)
              .fontColor('#64748B')
          }
          .width('100%')
        })
      }
      .width('100%')
    }
    .width('100%')
    .onAppear(() => this.drawChart())
  }
}
