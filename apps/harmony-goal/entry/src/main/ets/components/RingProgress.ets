@Component
export struct RingProgress {
  @Prop progress: number = 0;
  @Prop size: number = 88;
  @Prop strokeWidth: number = 10;
  @Prop color: string = '#4C7DFF';
  @Prop backgroundColor: string = '#E6EAF0';
  @Prop label: string = '完成率';
  @State displayProgress: number = 0;
  private timerId: number = -1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.displayProgress = 0;
    this.startAnimation(this.progress);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private startAnimation(target: number): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    let destination: number = Math.max(0, Math.min(100, target));
    let steps: number = 24;
    let delta: number = (destination - this.displayProgress) / steps;
    let count: number = 0;
    this.timerId = setInterval(() => {
      count += 1;
      if (count >= steps) {
        this.displayProgress = destination;
        this.drawRing();
        if (this.timerId !== -1) {
          clearInterval(this.timerId);
          this.timerId = -1;
        }
        return;
      }
      this.displayProgress = Number((this.displayProgress + delta).toFixed(1));
      this.drawRing();
    }, 16) as unknown as number;
  }

  private drawRing(): void {
    let center: number = this.size / 2;
    let radius: number = center - this.strokeWidth;
    this.context.clearRect(0, 0, this.size, this.size);
    this.context.strokeStyle = this.backgroundColor;
    this.context.lineWidth = this.strokeWidth;
    this.context.beginPath();
    this.context.arc(center, center, radius, 0, Math.PI * 2, false);
    this.context.stroke();

    let angle: number = (Math.PI * 2 * this.displayProgress) / 100;
    this.context.strokeStyle = this.color;
    this.context.lineCap = 'round';
    this.context.beginPath();
    this.context.arc(center, center, radius, -Math.PI / 2, -Math.PI / 2 + angle, false);
    this.context.stroke();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width(this.size)
        .height(this.size)
        .onReady(() => {
          this.drawRing();
          this.startAnimation(this.progress);
        })
      Column({ space: 2 }) {
        Text(`${Math.round(this.displayProgress)}%`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18202A')
        Text(this.label)
          .fontSize(10)
          .fontColor('#5E6B7A')
      }
    }
    .width(this.size)
    .height(this.size)
  }
}
