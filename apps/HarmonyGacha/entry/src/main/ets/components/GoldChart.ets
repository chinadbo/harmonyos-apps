@Component
export struct GoldChart {
  @Prop @Watch('redraw') data: number[] = [];
  @Prop chartW: number = 340;
  @Prop chartH: number = 200;
  @Prop goldColor: string = '#FFD24A';
  @Prop primaryColor: string = '#E8B542';
  @Prop cardColor: string = '#221E18';
  @Prop border: string = '#3A3428';
  @Prop textSub: string = '#A89F8C';
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private ready: boolean = false;

  private binLabels(): string[] {
    return ['1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90'];
  }

  build() {
    Canvas(this.ctx)
      .width(this.chartW)
      .height(this.chartH)
      .onReady(() => {
        this.ready = true;
        this.draw();
      })
  }

  private redraw(): void {
    if (this.ready) {
      this.draw();
    }
  }

  private draw(): void {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.chartW, this.chartH);
    const padL = 26;
    const padR = 8;
    const padT = 18;
    const padB = 22;
    const plotW = this.chartW - padL - padR;
    const plotH = this.chartH - padT - padB;
    const bins = this.binLabels();
    const n = bins.length;
    const bw = plotW / n;

    let max = 1;
    let total = 0;
    for (const v of this.data) {
      total += v;
      if (v > max) {
        max = v;
      }
    }

    ctx.strokeStyle = this.border;
    ctx.lineWidth = 1;
    ctx.fillStyle = this.textSub;
    ctx.font = '9px sans-serif';
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    for (let i = 0; i <= 4; i++) {
      const y = padT + plotH - plotH * i / 4;
      ctx.beginPath();
      ctx.moveTo(padL, y);
      ctx.lineTo(padL + plotW, y);
      ctx.stroke();
      ctx.fillText(`${Math.round(max * i / 4)}`, padL - 4, y);
    }

    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    for (let i = 0; i < n; i++) {
      const v = i < this.data.length ? this.data[i] : 0;
      const h = v > 0 ? plotH * v / max : 0;
      const x = padL + i * bw + bw * 0.18;
      const w = bw * 0.64;
      if (v > 0) {
        const grad = ctx.createLinearGradient(0, padT + plotH - h, 0, padT + plotH);
        grad.addColorStop(0, this.goldColor);
        grad.addColorStop(1, this.primaryColor);
        ctx.fillStyle = grad;
        ctx.fillRect(x, padT + plotH - h, w, h);
        ctx.fillStyle = this.goldColor;
        ctx.fillText(`${v}`, x + w / 2, padT + plotH - h - 11);
      }
      ctx.fillStyle = this.textSub;
      ctx.font = bw < 30 ? '8px sans-serif' : '9px sans-serif';
      ctx.fillText(bins[i], padL + i * bw + bw / 2, padT + plotH + 5);
      ctx.font = '9px sans-serif';
    }

    ctx.strokeStyle = this.border;
    ctx.beginPath();
    ctx.moveTo(padL, padT + plotH);
    ctx.lineTo(padL + plotW, padT + plotH);
    ctx.stroke();

    if (total === 0) {
      ctx.fillStyle = this.textSub;
      ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('暂无出金数据', padL + plotW / 2, padT + plotH / 2 - 6);
    }
  }
}
