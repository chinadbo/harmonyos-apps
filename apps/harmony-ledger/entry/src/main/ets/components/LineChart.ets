import { DailyTrendPoint } from '../data/DataModels';

@Component
export struct LineChart {
  @Prop points: DailyTrendPoint[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(220)
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
    if (this.points.length === 0) {
      return;
    }

    const paddingLeft: number = 24;
    const paddingTop: number = 18;
    const chartWidth: number = width - 40;
    const chartHeight: number = height - 40;
    const values: number[] = this.points.map((item: DailyTrendPoint) => item.amount);
    const maxValue: number = Math.max(...values, 0);
    const minValue: number = Math.min(...values, 0);
    const range: number = maxValue - minValue === 0 ? 1 : maxValue - minValue;

    this.context.strokeStyle = '#E0E0E0';
    this.context.lineWidth = 1;
    for (let index: number = 0; index < 4; index++) {
      const y: number = paddingTop + (chartHeight / 3) * index;
      this.context.beginPath();
      this.context.moveTo(paddingLeft, y);
      this.context.lineTo(paddingLeft + chartWidth, y);
      this.context.stroke();
    }

    this.context.strokeStyle = '#5C6BC0';
    this.context.lineWidth = 3;
    this.context.beginPath();
    this.points.forEach((item: DailyTrendPoint, index: number) => {
      const x: number = paddingLeft + (chartWidth / Math.max(this.points.length - 1, 1)) * index;
      const normalized: number = (item.amount - minValue) / range;
      const y: number = paddingTop + chartHeight - normalized * chartHeight;
      if (index === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    });
    this.context.stroke();

    this.context.fillStyle = '#5C6BC0';
    this.points.forEach((item: DailyTrendPoint, index: number) => {
      const x: number = paddingLeft + (chartWidth / Math.max(this.points.length - 1, 1)) * index;
      const normalized: number = (item.amount - minValue) / range;
      const y: number = paddingTop + chartHeight - normalized * chartHeight;
      this.context.beginPath();
      this.context.arc(x, y, 3, 0, Math.PI * 2);
      this.context.fill();
    });
  }
}
