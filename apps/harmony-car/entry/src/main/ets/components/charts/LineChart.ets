@Component
export struct LineChart {
  @Prop title: string = '折线图';
  @Prop labels: string[] = [];
  @Prop values: number[] = [];
  @Prop height: number = 220;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);


  private draw(): void {
    const width: number = 640;
    const height: number = this.height;
    const maxValue: number = Math.max(1, ...this.values);
    const stepX: number = this.values.length > 1 ? (width - 90) / (this.values.length - 1) : 60;
    this.context2D.clearRect(0, 0, width, height);
    this.context2D.fillStyle = '#FFFFFF';
    this.context2D.fillRect(0, 0, width, height);

    this.context2D.strokeStyle = '#D8E2F0';
    this.context2D.lineWidth = 1;
    this.context2D.beginPath();
    this.context2D.moveTo(36, 16);
    this.context2D.lineTo(36, height - 34);
    this.context2D.lineTo(width - 20, height - 34);
    this.context2D.stroke();

    this.context2D.strokeStyle = '#5CC8B2';
    this.context2D.lineWidth = 4;
    this.context2D.beginPath();
    this.values.forEach((value: number, index: number) => {
      const x: number = 48 + index * stepX;
      const y: number = height - 34 - (value / maxValue) * (height - 70);
      if (index === 0) {
        this.context2D.moveTo(x, y);
      } else {
        this.context2D.lineTo(x, y);
      }
    });
    this.context2D.stroke();

    this.values.forEach((value: number, index: number) => {
      const x: number = 48 + index * stepX;
      const y: number = height - 34 - (value / maxValue) * (height - 70);
      this.context2D.beginPath();
      this.context2D.fillStyle = '#5CC8B2';
      this.context2D.arc(x, y, 6, 0, Math.PI * 2);
      this.context2D.fill();
      this.context2D.fillStyle = '#243B53';
      this.context2D.font = '16px sans-serif';
      this.context2D.fillText(this.labels[index] ?? '', x - 16, height - 8);
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
