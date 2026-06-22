import { ChartPoint } from '../model/GoalModel';

@Component
export struct LineChart {
  @Prop points: ChartPoint[] = [];
  @Prop color: string = '#4C7DFF';
  @Prop heightValue: number = 220;
  private chartWidth: number = 320;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.drawChart();
  }

  private drawChart(): void {
    let width: number = this.chartWidth;
    let height: number = this.heightValue;
    let paddingLeft: number = 30;
    let paddingBottom: number = 26;
    let usableWidth: number = width - paddingLeft - 12;
    let usableHeight: number = height - paddingBottom - 12;

    this.context.clearRect(0, 0, width, height);
    this.context.strokeStyle = '#D8E0EB';
    this.context.lineWidth = 1;
    this.context.beginPath();
    this.context.moveTo(paddingLeft, 10);
    this.context.lineTo(paddingLeft, usableHeight);
    this.context.lineTo(width - 8, usableHeight);
    this.context.stroke();

    if (this.points.length === 0) {
      return;
    }

    let stepX: number = this.points.length > 1 ? usableWidth / (this.points.length - 1) : 0;
    let drawPoints: Array<{ x: number, y: number }> = [];
    this.points.forEach((point: ChartPoint, index: number) => {
      let x: number = paddingLeft + stepX * index;
      let y: number = usableHeight - (Math.max(0, Math.min(point.value, 100)) / 100) * (usableHeight - 16);
      drawPoints.push({ x, y });
    });

    this.context.strokeStyle = this.color;
    this.context.lineWidth = 3;
    this.context.beginPath();
    this.context.moveTo(drawPoints[0].x, drawPoints[0].y);
    for (let index = 1; index < drawPoints.length; index++) {
      this.context.lineTo(drawPoints[index].x, drawPoints[index].y);
    }
    this.context.stroke();

    this.context.fillStyle = `${this.color}22`;
    this.context.beginPath();
    this.context.moveTo(drawPoints[0].x, usableHeight);
    drawPoints.forEach((point: { x: number, y: number }) => {
      this.context.lineTo(point.x, point.y);
    });
    this.context.lineTo(drawPoints[drawPoints.length - 1].x, usableHeight);
    this.context.closePath();
    this.context.fill();

    this.context.fillStyle = this.color;
    drawPoints.forEach((point: { x: number, y: number }) => {
      this.context.beginPath();
      this.context.arc(point.x, point.y, 4, 0, Math.PI * 2, false);
      this.context.fill();
    });
  }

  build() {
    Column({ space: 12 }) {
      Canvas(this.context)
        .width(this.chartWidth)
        .height(this.heightValue)
        .onReady(() => {
          this.drawChart();
        })
      if (this.points.length > 0) {
        Row() {
          ForEach(this.points, (item: ChartPoint) => {
            Column({ space: 2 }) {
              Text(item.label)
                .fontSize(10)
                .fontColor('#5E6B7A')
              Text(`${Math.round(item.value)}%`)
                .fontSize(11)
                .fontColor('#18202A')
            }
            .layoutWeight(1)
          }, (item: ChartPoint) => item.date)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
