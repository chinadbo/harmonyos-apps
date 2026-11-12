import { AppTheme } from '../common/Theme';

/** 田字格组件：外框 + 虚线中线 + 可选半透明底字 */
@Component
export struct GridCell {
  @Prop @Watch('onContentChange') character: string = '';
  @Prop @Watch('onContentChange') size: number = 300;
  @Prop @Watch('onContentChange') showDiagonal: boolean = true;
  @Prop @Watch('onContentChange') guideAlpha: number = 0.12;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onContentChange(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private draw(): void {
    const s: number = this.size;
    this.ctx.clearRect(0, 0, s, s);
    AppTheme.drawTianGrid(this.ctx, s, this.showDiagonal);

    if (this.character.length > 0) {
      this.ctx.save();
      this.ctx.globalAlpha = this.guideAlpha;
      this.ctx.fillStyle = AppTheme.INK;
      this.ctx.textAlign = 'center';
      this.ctx.textBaseline = 'middle';
      this.ctx.font = `${Math.round(s * 0.62)}px sans-serif`;
      this.ctx.fillText(this.character, s / 2, s / 2 + s * 0.02);
      this.ctx.restore();
    }
  }

  build() {
    Canvas(this.ctx)
      .width(this.size)
      .height(this.size)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }
}
