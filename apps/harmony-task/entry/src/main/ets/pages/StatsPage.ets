import router from '@ohos.router';
import { StatsService, StatsData, CategoryStat, DailyCount } from '../services/StatsService';
import { ProgressRing } from '../components/ProgressRing';

@Entry
@Component
struct StatsPage {
  @State stats: StatsData = {
    todayCompleted: 0,
    todayTotal: 0,
    weekCompleted: 0,
    weekTotal: 0,
    monthCompleted: 0,
    monthTotal: 0,
    categoryDistribution: [],
    weeklyTrend: []
  };
  private statsService: StatsService = new StatsService();
  private pieSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private pieContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.pieSettings);
  private lineSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private lineContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.lineSettings);

  async aboutToAppear(): Promise<void> {
    this.stats = await this.statsService.getStatsData();
  }

  private getRate(completed: number, total: number): number {
    if (total === 0) return 0;
    return Math.round(completed * 100 / total);
  }

  private drawPieChart(): void {
    const ctx = this.pieContext;
    const size = 160;
    const center = size / 2;
    const radius = 60;

    ctx.clearRect(0, 0, size, size);

    const data = this.stats.categoryDistribution;
    if (data.length === 0) {
      ctx.fillStyle = '#F0F0F0';
      ctx.beginPath();
      ctx.arc(center, center, radius, 0, 2 * Math.PI);
      ctx.fill();
      ctx.fillStyle = '#999999';
      ctx.font = '14px';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText('暂无数据', center, center);
      return;
    }

    const total = data.reduce((sum, item) => sum + item.count, 0);
    let startAngle = -Math.PI / 2;

    for (const item of data) {
      const sliceAngle = (item.count / total) * 2 * Math.PI;
      ctx.beginPath();
      ctx.moveTo(center, center);
      ctx.arc(center, center, radius, startAngle, startAngle + sliceAngle);
      ctx.closePath();
      ctx.fillStyle = item.color;
      ctx.fill();
      startAngle += sliceAngle;
    }

    // 中心白色圆（空心效果）
    ctx.beginPath();
    ctx.arc(center, center, radius * 0.5, 0, 2 * Math.PI);
    ctx.fillStyle = Color.White.toString();
    ctx.fill();
  }

  private drawLineChart(): void {
    const ctx = this.lineContext;
    const width = 300;
    const height = 150;
    const padding = 30;

    ctx.clearRect(0, 0, width, height);

    const data = this.stats.weeklyTrend;
    if (data.length === 0) return;

    const maxVal = Math.max(...data.map(d => d.completed), 1);
    const chartWidth = width - padding * 2;
    const chartHeight = height - padding * 2;
    const stepX = chartWidth / (data.length - 1 || 1);

    // 网格线
    ctx.strokeStyle = '#F0F0F0';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 4; i++) {
      const y = padding + (chartHeight / 4) * i;
      ctx.beginPath();
      ctx.moveTo(padding, y);
      ctx.lineTo(width - padding, y);
      ctx.stroke();
    }

    // 折线
    ctx.beginPath();
    ctx.strokeStyle = '#4ECDC4';
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';

    for (let i = 0; i < data.length; i++) {
      const x = padding + stepX * i;
      const y = padding + chartHeight - (data[i].completed / maxVal) * chartHeight;
      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.stroke();

    // 数据点
    for (let i = 0; i < data.length; i++) {
      const x = padding + stepX * i;
      const y = padding + chartHeight - (data[i].completed / maxVal) * chartHeight;
      ctx.beginPath();
      ctx.arc(x, y, 4, 0, 2 * Math.PI);
      ctx.fillStyle = '#4ECDC4';
      ctx.fill();

      // X轴标签
      ctx.fillStyle = '#999999';
      ctx.font = '10px';
      ctx.textAlign = 'center';
      ctx.fillText(data[i].date, x, height - 8);
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // 完成率环形图
          Text('完成率')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)

          Row() {
            ProgressRing({
              progress: this.getRate(this.stats.todayCompleted, this.stats.todayTotal),
              size: 80,
              color: '#4ECDC4',
              label: '今日'
            })

            ProgressRing({
              progress: this.getRate(this.stats.weekCompleted, this.stats.weekTotal),
              size: 80,
              color: '#45B7D1',
              label: '本周'
            })
              .margin({ left: 24 })

            ProgressRing({
              progress: this.getRate(this.stats.monthCompleted, this.stats.monthTotal),
              size: 80,
              color: '#FF6B6B',
              label: '本月'
            })
              .margin({ left: 24 })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          // 分类分布
          Text('分类占比')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 24, bottom: 16 })
            .alignSelf(ItemAlign.Start)

          Column() {
            Canvas(this.pieContext)
              .width(160)
              .height(160)
              .onReady(() => {
                this.drawPieChart();
              })

            // 图例
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(this.stats.categoryDistribution, (item: CategoryStat) => {
                Row() {
                  Circle().width(10).height(10).fill(item.color)
                  Text(`${item.categoryName} (${item.count})`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ left: 4 })
                }
                .margin({ right: 12, top: 8 })
              }, (item: CategoryStat) => item.categoryId.toString())
            }
            .margin({ top: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .alignItems(HorizontalAlign.Center)

          // 近7天趋势
          Text('近7天完成趋势')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 24, bottom: 16 })
            .alignSelf(ItemAlign.Start)

          Column() {
            Canvas(this.lineContext)
              .width(300)
              .height(150)
              .onReady(() => {
                this.drawLineChart();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .alignItems(HorizontalAlign.Center)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
