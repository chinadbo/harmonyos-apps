@Component
export struct ProgressRing {
  @Prop progress: number = 0; // 0-100
  @Prop size: number = 80;
  @Prop strokeWidth: number = 8;
  @Prop color: string = '#4ECDC4';
  @Prop label: string = '';

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private drawRing(): void {
    const ctx = this.context;
    const center = this.size / 2;
    const radius = center - this.strokeWidth;

    ctx.clearRect(0, 0, this.size, this.size);

    // 背景圆环
    ctx.beginPath();
    ctx.arc(center, center, radius, 0, 2 * Math.PI);
    ctx.strokeStyle = '#F0F0F0';
    ctx.lineWidth = this.strokeWidth;
    ctx.lineCap = 'round';
    ctx.stroke();

    // 进度圆环
    if (this.progress > 0) {
      const startAngle = -Math.PI / 2;
      const endAngle = startAngle + (2 * Math.PI * this.progress / 100);
      ctx.beginPath();
      ctx.arc(center, center, radius, startAngle, endAngle);
      ctx.strokeStyle = this.color;
      ctx.lineWidth = this.strokeWidth;
      ctx.lineCap = 'round';
      ctx.stroke();
    }

    // 中心文字
    ctx.fillStyle = '#333333';
    ctx.font = `bold ${this.size / 5}px`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(`${Math.round(this.progress)}%`, center, center);
  }

  build() {
    Column() {
      Canvas(this.context)
        .width(this.size)
        .height(this.size)
        .onReady(() => {
          this.drawRing();
        })

      if (this.label) {
        Text(this.label)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}
