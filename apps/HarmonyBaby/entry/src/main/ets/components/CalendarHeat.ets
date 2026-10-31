import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';

/**
 * 月历热力图（Canvas 实现，onReady 中绘制）：
 * - 每天一个圆形格子，颜色深浅代表当天记录条数
 * - 点击某个日期回调 onSelectDay
 */
@Component
export struct CalendarHeat {
  @Prop @Watch('onDataChange') year: number = 2026;
  @Prop @Watch('onDataChange') month: number = 0;
  @Prop @Watch('onDataChange') heatData: number[] = [];
  @Prop @Watch('onDataChange') selectedDay: number = 0;
  onSelectDay: (day: number) => void = (day: number) => {
  };

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // 绘制时缓存的布局参数，供点击命中检测复用
  private gridTop: number = 30;
  private cellW: number = 0;
  private cellH: number = 0;
  private firstWeekday: number = 0;
  private daysCount: number = 30;

  private static readonly WEEK_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];

  onDataChange(): void {
    this.draw();
  }

  private draw(): void {
    const ctx = this.context;
    const w = ctx.width;
    const h = ctx.height;
    if (w <= 0 || h <= 0) {
      return;
    }
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = Theme.CARD;
    ctx.fillRect(0, 0, w, h);

    this.daysCount = TimeUtils.daysInMonth(this.year, this.month);
    this.firstWeekday = TimeUtils.firstWeekday(this.year, this.month);
    const rows = Math.ceil((this.firstWeekday + this.daysCount) / 7);
    this.cellW = w / 7;
    this.gridTop = 26;
    const gridBottomPad = 6;
    this.cellH = (h - this.gridTop - gridBottomPad) / rows;

    // 周标题
    ctx.font = '12px sans-serif';
    ctx.fillStyle = Theme.TEXT_LIGHT;
    ctx.textAlign = 'center';
    for (let i = 0; i < 7; i++) {
      ctx.fillText(CalendarHeat.WEEK_LABELS[i], this.cellW * i + this.cellW / 2, 17);
    }

    // 计算热力最大值
    let maxHeat = 0;
    for (let i = 0; i < this.heatData.length; i++) {
      if (this.heatData[i] > maxHeat) {
        maxHeat = this.heatData[i];
      }
    }
    if (maxHeat <= 0) {
      maxHeat = 1;
    }

    const radius = Math.min(this.cellW, this.cellH) * 0.4;
    const todayStart = TimeUtils.todayStart();
    ctx.textAlign = 'center';
    for (let d = 1; d <= this.daysCount; d++) {
      const col = (this.firstWeekday + d - 1) % 7;
      const row = Math.floor((this.firstWeekday + d - 1) / 7);
      const cx = this.cellW * col + this.cellW / 2;
      const cy = this.gridTop + this.cellH * row + this.cellH / 2;
      const dayStartMs = new Date(this.year, this.month, d).getTime();
      const heat = d <= this.heatData.length ? this.heatData[d - 1] : 0;

      // 选中日：外圈描边
      if (d === this.selectedDay) {
        ctx.beginPath();
        ctx.arc(cx, cy, radius + 4, 0, Math.PI * 2);
        ctx.strokeStyle = Theme.PRIMARY;
        ctx.lineWidth = 2;
        ctx.stroke();
      }

      if (heat > 0) {
        const alpha = 0.2 + 0.75 * (heat / maxHeat);
        ctx.beginPath();
        ctx.arc(cx, cy, radius, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(249,115,22,' + alpha.toFixed(2) + ')';
        ctx.fill();
        ctx.fillStyle = '#FFFFFF';
      } else {
        ctx.beginPath();
        ctx.arc(cx, cy, radius, 0, Math.PI * 2);
        ctx.fillStyle = Theme.GRAY_BG;
        ctx.fill();
        if (dayStartMs === todayStart) {
          ctx.fillStyle = Theme.PRIMARY;
        } else {
          ctx.fillStyle = Theme.TEXT_SUB;
        }
      }
      ctx.font = (d === this.selectedDay ? 'bold ' : '') + Math.floor(radius) + 'px sans-serif';
      ctx.fillText(String(d), cx, cy + radius * 0.35);
    }
    ctx.textAlign = 'start';
  }

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height(330)
        .onReady(() => {
          this.draw();
        })
        .onClick((event: ClickEvent) => {
          const x = event.x;
          const y = event.y;
          if (x < 0 || y < 0 || this.cellW <= 0 || this.cellH <= 0) {
            return;
          }
          if (y < this.gridTop) {
            return;
          }
          const col = Math.floor(x / this.cellW);
          const row = Math.floor((y - this.gridTop) / this.cellH);
          if (col < 0 || col > 6 || row < 0) {
            return;
          }
          const day = row * 7 + col - this.firstWeekday + 1;
          if (day >= 1 && day <= this.daysCount) {
            this.onSelectDay(day);
          }
        })
    }
    .width('100%')
    .backgroundColor(Theme.CARD)
    .borderRadius(16)
  }
}
