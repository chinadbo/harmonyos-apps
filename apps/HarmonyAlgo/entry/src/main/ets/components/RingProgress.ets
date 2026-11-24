import { Theme } from '../common/Theme';

/** Canvas 环形进度图 */
@Component
export struct RingProgress {
  @Prop @Watch('redraw') progress: number = 0;
  @Prop ringSize: number = 150;
  @Prop strokeWidth: number = 14;
  @Prop centerText: string = '';
  @Prop centerSub: string = '';

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  redraw(): void {
    if (!this.ready) {
      return;
    }
    const size: number = this.ringSize;
    const cx: number = size / 2;
    const cy: number = size / 2;
    const r: number = (size - this.strokeWidth) / 2;
    this.ctx.clearRect(0, 0, size, size);

    // 背景圆环
    this.ctx.beginPath();
    this.ctx.arc(cx, cy, r, 0, Math.PI * 2);
    this.ctx.strokeStyle = '#EEF1F7';
    this.ctx.lineWidth = this.strokeWidth;
    this.ctx.stroke();

    // 进度圆环
    let value: number = this.progress;
    if (value < 0) {
      value = 0;
    }
    if (value > 1) {
      value = 1;
    }
    if (value > 0) {
      const start = -Math.PI / 2;
      const end = start + Math.PI * 2 * value;
      const grad = this.ctx.createLinearGradient(0, 0, size, size);
      grad.addColorStop(0, Theme.primary);
      grad.addColorStop(1, Theme.secondary);
      this.ctx.beginPath();
      this.ctx.arc(cx, cy, r, start, end);
      this.ctx.strokeStyle = grad;
      this.ctx.lineWidth = this.strokeWidth;
      this.ctx.lineCap = 'round';
      this.ctx.stroke();
    }
  }

  build() {
    Stack() {
      Canvas(this.ctx)
        .width(this.ringSize)
        .height(this.ringSize)
        .onReady(() => {
          this.ready = true;
          this.redraw();
        })
      Column() {
        Text(this.centerText)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.text)
        Text(this.centerSub)
          .fontSize(11)
          .fontColor(Theme.subText)
          .margin({ top: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width(this.ringSize)
      .height(this.ringSize)
    }
    .width(this.ringSize)
    .height(this.ringSize)
  }
}
