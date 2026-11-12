import { AppTheme } from '../common/Theme';

/** 掌握度进度环（Canvas 绘制，中心文字默认显示百分比） */
@Component
export struct ProgressRing {
  @Prop @Watch('onValueChange') percent: number = 0;
  @Prop size: number = 76;
  @Prop ringWidth: number = 8;
  @Prop label: string = '';
  @Prop showValue: boolean = true;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onValueChange(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private ringColor(): string {
    return AppTheme.masteryColor(this.percent);
  }

  private draw(): void {
    const s: number = this.size;
    const center: number = s / 2;
    const radius: number = s / 2 - this.ringWidth / 2 - 1;
    const value: number = Math.max(0, Math.min(100, this.percent));

    this.ctx.clearRect(0, 0, s, s);
    this.ctx.lineCap = 'round';

    this.ctx.beginPath();
    this.ctx.arc(center, center, radius, 0, Math.PI * 2);
    this.ctx.strokeStyle = AppTheme.CARD_ALT;
    this.ctx.lineWidth = this.ringWidth;
    this.ctx.stroke();

    if (value > 0) {
      const start: number = -Math.PI / 2;
      const end: number = start + Math.PI * 2 * value / 100;
      this.ctx.beginPath();
      this.ctx.arc(center, center, radius, start, end);
      this.ctx.strokeStyle = this.ringColor();
      this.ctx.lineWidth = this.ringWidth;
      this.ctx.stroke();
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.ctx)
        .width(this.size)
        .height(this.size)
        .onReady(() => {
          this.ready = true;
          this.draw();
        })
      Column({ space: 1 }) {
        if (this.showValue) {
          Text(`${Math.round(this.percent)}`)
            .fontSize(this.size * 0.27)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.ringColor())
        }
        if (this.label.length > 0) {
          Text(this.label)
            .fontSize(Math.max(9, this.size * 0.12))
            .fontColor(AppTheme.INK_FAINT)
        }
      }
    }
    .width(this.size)
    .height(this.size)
  }
}
