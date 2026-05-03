import { PieChartItem } from '../data/DataModels';

@Component
export struct PieChart {
  @Prop items: PieChartItem[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(240)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .onReady(() => {
        this.drawChart();
      })
  }

  private drawChart(): void {
    const width: number = this.context.width;
    const height: number = this.context.height;
    this.context.clearRect(0, 0, width, height);
    this.context.fillStyle = '#FFFFFF';
    this.context.fillRect(0, 0, width, height);
    if (this.items.length === 0) {
      return;
    }
    const total: number = this.items.reduce((sum: number, item: PieChartItem) => sum + item.amount, 0);
    if (total <= 0) {
      return;
    }
    const centerX: number = width / 2;
    const centerY: number = height / 2;
    const radius: number = Math.min(width, height) * 0.28;
    let startAngle: number = -Math.PI / 2;

    this.items.forEach((item: PieChartItem) => {
      const sweepAngle: number = (item.amount / total) * Math.PI * 2;
      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.fillStyle = item.color;
      this.context.arc(centerX, centerY, radius, startAngle, startAngle + sweepAngle);
      this.context.closePath();
      this.context.fill();
      startAngle += sweepAngle;
    });

    this.context.beginPath();
    this.context.fillStyle = '#FFFFFF';
    this.context.arc(centerX, centerY, radius * 0.55, 0, Math.PI * 2);
    this.context.fill();
  }
}
