import { CharEntry, StrokePoint } from '../model/CharData';
import { AppTheme } from '../common/Theme';

/**
 * 笔顺动画组件：
 * Canvas 逐笔插值演示，支持播放/暂停、单步、重播与速度调节。
 */
@Component
export struct StrokeAnim {
  @Prop @Watch('onEntryChange') entry: CharEntry = { char: '', pinyin: '', grade: 1, strokes: [] };
  @Prop @Watch('onSizeChange') size: number = 280;
  @Prop speedMs: number = 900;
  @Prop brushWidth: number = 8;
  onFinished: () => void = () => {
  };
  @State playing: boolean = false;
  @State strokeIndex: number = 0;
  @State progress: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private timer: number = -1;
  private elapsed: number = 0;
  private ready: boolean = false;

  aboutToDisappear(): void {
    this.stopTimer();
  }

  onEntryChange(): void {
    this.resetState();
    if (this.ready) {
      this.draw();
    }
  }

  onSizeChange(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private resetState(): void {
    this.stopTimer();
    this.playing = false;
    this.strokeIndex = 0;
    this.progress = 0;
    this.elapsed = 0;
  }

  private stopTimer(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  private totalStrokes(): number {
    return this.entry.strokes.length;
  }

  private togglePlay(): void {
    if (this.playing) {
      this.playing = false;
      this.stopTimer();
      return;
    }
    if (this.strokeIndex >= this.totalStrokes()) {
      this.strokeIndex = 0;
      this.progress = 0;
      this.elapsed = 0;
    }
    this.playing = true;
    this.startTimer();
  }

  private startTimer(): void {
    this.stopTimer();
    this.timer = setInterval(() => {
      this.tick();
    }, 33);
  }

  private tick(): void {
    if (!this.playing || this.totalStrokes() === 0) {
      return;
    }
    const duration: number = Math.max(220, this.speedMs);
    this.elapsed += 33;
    this.progress = Math.min(1, this.elapsed / duration);
    if (this.progress >= 1) {
      this.strokeIndex++;
      this.elapsed = 0;
      this.progress = 0;
      if (this.strokeIndex >= this.totalStrokes()) {
        this.strokeIndex = this.totalStrokes();
        this.playing = false;
        this.stopTimer();
        this.draw();
        this.onFinished();
        return;
      }
    }
    this.draw();
  }

  private replay(): void {
    this.resetState();
    this.playing = true;
    this.startTimer();
  }

  private stepOnce(): void {
    this.playing = false;
    this.stopTimer();
    if (this.strokeIndex < this.totalStrokes()) {
      this.strokeIndex++;
      this.progress = 0;
      this.elapsed = 0;
      this.draw();
    }
  }

  private tipPoint(points: StrokePoint[], fraction: number): StrokePoint {
    if (points.length === 0) {
      return { x: 50, y: 50 };
    }
    if (fraction >= 1 || points.length === 1) {
      return points[points.length - 1];
    }
    let total: number = 0;
    for (let i = 0; i < points.length - 1; i++) {
      total += Math.sqrt(
        Math.pow(points[i + 1].x - points[i].x, 2) +
        Math.pow(points[i + 1].y - points[i].y, 2));
    }
    const target: number = total * fraction;
    let walked: number = 0;
    for (let i = 0; i < points.length - 1; i++) {
      const seg: number = Math.sqrt(
        Math.pow(points[i + 1].x - points[i].x, 2) +
        Math.pow(points[i + 1].y - points[i].y, 2));
      if (walked + seg >= target) {
        const t: number = seg < 0.0001 ? 0 : (target - walked) / seg;
        const result: StrokePoint = {
          x: points[i].x + (points[i + 1].x - points[i].x) * t,
          y: points[i].y + (points[i + 1].y - points[i].y) * t
        };
        return result;
      }
      walked += seg;
    }
    return points[points.length - 1];
  }

  private drawStrokePath(points: StrokePoint[], fraction: number, color: string,
    width: number, asLine: boolean): void {
    const s: number = this.size;
    if (points.length < 2) {
      return;
    }
    if (fraction <= 0) {
      return;
    }
    this.ctx.beginPath();
    this.ctx.moveTo(AppTheme.toCanvas(points[0].x, s), AppTheme.toCanvas(points[0].y, s));
    if (fraction >= 1) {
      for (let i = 1; i < points.length; i++) {
        this.ctx.lineTo(AppTheme.toCanvas(points[i].x, s), AppTheme.toCanvas(points[i].y, s));
      }
    } else {
      let total: number = 0;
      for (let i = 0; i < points.length - 1; i++) {
        total += Math.sqrt(
          Math.pow(points[i + 1].x - points[i].x, 2) +
          Math.pow(points[i + 1].y - points[i].y, 2));
      }
      const target: number = total * fraction;
      let walked: number = 0;
      for (let i = 0; i < points.length - 1; i++) {
        const seg: number = Math.sqrt(
          Math.pow(points[i + 1].x - points[i].x, 2) +
          Math.pow(points[i + 1].y - points[i].y, 2));
        if (walked + seg <= target) {
          this.ctx.lineTo(AppTheme.toCanvas(points[i + 1].x, s), AppTheme.toCanvas(points[i + 1].y, s));
          walked += seg;
        } else {
          const t: number = seg < 0.0001 ? 0 : (target - walked) / seg;
          const x: number = points[i].x + (points[i + 1].x - points[i].x) * t;
          const y: number = points[i].y + (points[i + 1].y - points[i].y) * t;
          this.ctx.lineTo(AppTheme.toCanvas(x, s), AppTheme.toCanvas(y, s));
          break;
        }
      }
    }
    this.ctx.strokeStyle = color;
    this.ctx.lineWidth = asLine ? width * 0.35 : width;
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    this.ctx.stroke();
  }

  private draw(): void {
    const s: number = this.size;
    const strokes = this.entry.strokes;
    this.ctx.clearRect(0, 0, s, s);
    AppTheme.drawTianGrid(this.ctx, s, true);

    if (strokes.length === 0) {
      this.ctx.fillStyle = AppTheme.INK_FAINT;
      this.ctx.textAlign = 'center';
      this.ctx.textBaseline = 'middle';
      this.ctx.font = '16px sans-serif';
      this.ctx.fillText('暂无笔画数据', s / 2, s / 2);
      return;
    }

    // 未写笔画：浅色引导
    for (let i = 0; i < strokes.length; i++) {
      if (i > this.strokeIndex || (i === this.strokeIndex && this.strokeIndex >= strokes.length)) {
        this.drawStrokePath(strokes[i].points, 1, AppTheme.GUIDE, 3, true);
      } else if (i === this.strokeIndex) {
        this.drawStrokePath(strokes[i].points, 1, AppTheme.GRID_LINE, 3, true);
      }
    }

    // 已完成笔画
    const doneCount: number = Math.min(this.strokeIndex, strokes.length);
    for (let i = 0; i < doneCount; i++) {
      this.drawStrokePath(strokes[i].points, 1, AppTheme.INK, this.brushWidth, false);
    }

    // 当前笔画（进度插值）
    if (this.strokeIndex < strokes.length) {
      const current = strokes[this.strokeIndex];
      this.drawStrokePath(current.points, Math.max(this.progress, 0.001), AppTheme.ACCENT,
        this.brushWidth, false);

      const start: StrokePoint = current.points[0];
      this.ctx.beginPath();
      this.ctx.arc(AppTheme.toCanvas(start.x, s), AppTheme.toCanvas(start.y, s),
        Math.max(4, this.brushWidth * 0.7), 0, Math.PI * 2);
      this.ctx.fillStyle = AppTheme.GOLD;
      this.ctx.fill();

      if (this.progress > 0 && this.progress < 1) {
        const tip: StrokePoint = this.tipPoint(current.points, this.progress);
        this.ctx.beginPath();
        this.ctx.arc(AppTheme.toCanvas(tip.x, s), AppTheme.toCanvas(tip.y, s),
          Math.max(4, this.brushWidth * 0.75), 0, Math.PI * 2);
        this.ctx.fillStyle = AppTheme.ACCENT;
        this.ctx.fill();
      }
    }
  }

  private statusText(): string {
    const total: number = this.totalStrokes();
    if (total === 0) {
      return '暂无笔画';
    }
    if (this.strokeIndex >= total) {
      return `演示完成 · 共 ${total} 笔`;
    }
    return `第 ${this.strokeIndex + 1} 笔 / 共 ${total} 笔 · ${this.entry.strokes[this.strokeIndex].type}`;
  }

  build() {
    Column({ space: 10 }) {
      Canvas(this.ctx)
        .width(this.size)
        .height(this.size)
        .onReady(() => {
          this.ready = true;
          this.draw();
        })
        .borderRadius(8)

      Text(this.statusText())
        .fontSize(13)
        .fontColor(AppTheme.INK_LIGHT)

      Row({ space: 10 }) {
        Button('重播')
          .type(ButtonType.Capsule)
          .fontSize(13)
          .fontColor(AppTheme.INK_LIGHT)
          .backgroundColor(AppTheme.CARD_ALT)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.replay();
          })
        Button(this.playing ? '暂停' : '播放')
          .type(ButtonType.Capsule)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.INK)
          .height(32)
          .padding({ left: 20, right: 20 })
          .onClick(() => {
            this.togglePlay();
          })
        Button('单步')
          .type(ButtonType.Capsule)
          .fontSize(13)
          .fontColor(AppTheme.ACCENT)
          .backgroundColor(AppTheme.ACCENT_SOFT)
          .height(32)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.stepOnce();
          })
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }
}
