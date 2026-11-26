/**
 * RingChart.ets — Canvas 自绘环形图（品类价值 / 数量分布）
 * 使用 CanvasRenderingContext2D，坐标单位 vp。
 */
import { CategoryStat } from '../model/StatsModel';
import { C_TEXT, C_SUB, C_LINE } from '../common/Constants';

@Component
export struct RingChart {
  @Prop @Watch('onDataChange') data: CategoryStat[] = [];
  @Prop @Watch('onDataChange') centerTop: string = '';
  @Prop centerBottom: string = '总估值';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  onDataChange(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private sumValue(): number {
    let total: number = 0;
    for (let i = 0; i < this.data.length; i++) {
      total += this.data[i].value;
    }
    return total;
  }

  private sumCount(): number {
    let total: number = 0;
    for (let i = 0; i < this.data.length; i++) {
      total += this.data[i].count;
    }
    return total;
  }

  private drawCenter(cx: number, cy: number, empty: boolean): void {
    const ctx = this.ctx;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = empty ? '#B7AE9E' : C_TEXT;
    ctx.font = 'bold 20px sans-serif';
    ctx.fillText(this.centerTop.length > 0 ? this.centerTop : '0', cx, cy - 9);
    ctx.fillStyle = C_SUB;
    ctx.font = '12px sans-serif';
    ctx.fillText(this.centerBottom, cx, cy + 15);
  }

  private draw(): void {
    const ctx = this.ctx;
    const w: number = ctx.width;
    const h: number = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);
    const cx: number = w / 2;
    const cy: number = h / 2;
    const radius: number = Math.min(w, h) / 2 - 26;
    const thickness: number = 24;

    const totalValue: number = this.sumValue();
    const totalCount: number = this.sumCount();
    if (totalValue <= 0 && totalCount <= 0) {
      ctx.beginPath();
      ctx.strokeStyle = '#EDE6DA';
      ctx.lineWidth = thickness;
      ctx.arc(cx, cy, radius, 0, Math.PI * 2);
      ctx.stroke();
      this.drawCenter(cx, cy, true);
      return;
    }

    const useValue: boolean = totalValue > 0;
    const total: number = useValue ? totalValue : totalCount;
    let start: number = -Math.PI / 2;
    for (let i = 0; i < this.data.length; i++) {
      const d: CategoryStat = this.data[i];
      const weight: number = useValue ? d.value : d.count;
      if (weight <= 0) {
        continue;
      }
      const sweep: number = (weight / total) * Math.PI * 2;
      const gap: number = sweep > 0.08 ? 0.016 : 0;
      ctx.beginPath();
      ctx.strokeStyle = d.color;
      ctx.lineWidth = thickness;
      ctx.arc(cx, cy, radius, start + gap, start + sweep - gap);
      ctx.stroke();
      start += sweep;
    }
    this.drawCenter(cx, cy, false);
  }

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(220)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }
}
