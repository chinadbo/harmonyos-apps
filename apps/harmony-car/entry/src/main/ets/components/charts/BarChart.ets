@Component
export struct BarChart {
  @Prop title: string = '柱状图';
  @Prop labels: string[] = [];
  @Prop values: number[] = [];
  @Prop height: number = 220;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);


  private draw(): void {
    const width: number = 640;
    const height: number = this.height;
    const maxValue: number = Math.max(1, ...this.values);
    const barWidth: number = this.values.length > 0 ? width / (this.values.length * 1.8) : 40;
    this.context2D.clearRect(0, 0, width, height);
    this.context2D.fillStyle = '#FFFFFF';
    this.context2D.fillRect(0, 0, width, height);

    this.context2D.strokeStyle = '#D8E2F0';
    this.context2D.lineWidth = 1;
    this.context2D.beginPath();
    this.context2D.moveTo(36, 12);
    this.context2D.lineTo(36, height - 34);
    this.context2D.lineTo(width - 12, height - 34);
    this.context2D.stroke();

    this.values.forEach((value: number, index: number) => {
      const x: number = 56 + index * (barWidth + 28);
      const barHeight: number = (value / maxValue) * (height - 72);
      const y: number = height - 34 - barHeight;
      this.context2D.fillStyle = '#4E7BF2';
      this.context2D.fillRect(x, y, barWidth, barHeight);
      this.context2D.fillStyle = '#243B53';
      this.context2D.font = '18px sans-serif';
      this.context2D.fillText(this.labels[index] ?? '', x - 4, height - 10);
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
