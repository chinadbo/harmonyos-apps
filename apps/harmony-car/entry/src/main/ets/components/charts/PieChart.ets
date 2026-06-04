import { CHART_COLORS } from '../../utils/Constants';

@Component
export struct PieChart {
  @Prop title: string = '饼图';
  @Prop labels: string[] = [];
  @Prop values: number[] = [];
  @Prop height: number = 260;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);


  private draw(): void {
    const width: number = 640;
    const height: number = this.height;
    const centerX: number = 180;
    const centerY: number = height / 2;
    const radius: number = 90;
    const total: number = this.values.reduce((sum: number, current: number) => sum + current, 0) || 1;
    let startAngle: number = -Math.PI / 2;

    this.context2D.clearRect(0, 0, width, height);
    this.context2D.fillStyle = '#FFFFFF';
    this.context2D.fillRect(0, 0, width, height);

    this.values.forEach((value: number, index: number) => {
      const angle: number = (value / total) * Math.PI * 2;
      this.context2D.beginPath();
      this.context2D.moveTo(centerX, centerY);
      this.context2D.arc(centerX, centerY, radius, startAngle, startAngle + angle);
      this.context2D.closePath();
      this.context2D.fillStyle = CHART_COLORS[index % CHART_COLORS.length];
      this.context2D.fill();
      startAngle += angle;
    });

    this.context2D.fillStyle = '#243B53';
    this.context2D.font = '20px sans-serif';
    this.labels.forEach((label: string, index: number) => {
      const y: number = 48 + index * 28;
      this.context2D.fillStyle = CHART_COLORS[index % CHART_COLORS.length];
      this.context2D.fillRect(350, y - 14, 18, 18);
      this.context2D.fillStyle = '#243B53';
      this.context2D.fillText(`${label} ${this.values[index] ?? 0}`, 380, y);
    });
  }

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
      Canvas(this.context2D)
        .width('100%')
        .height(this.height)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onReady(() => {
          this.draw();
        })
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
