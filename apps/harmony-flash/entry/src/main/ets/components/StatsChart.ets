@Component
export struct StatsChart {
  @Prop dailyData: Array<{ date: string; count: number }> = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.context)
      .width('100%')
      .height(160)
      .onReady(() => {
        this.drawChart();
      })
  }

  private drawChart(): void {
    const ctx = this.context;
    const width = ctx.width;
    const height = ctx.height;
    const padL = 40;
    const padR = 16;
    const padT = 16;
    const padB = 30;
    const chartW = width - padL - padR;
    const chartH = height - padT - padB;

    const maxCount = Math.max(...this.dailyData.map(d => d.count), 5);
    const n = this.dailyData.length;
    if (n === 0) return;

    // 清空
    ctx.clearRect(0, 0, width, height);

    // Y 轴网格线
    ctx.strokeStyle = '#E5E7EB';
    ctx.lineWidth = 1;
    const steps = 4;
    for (let i = 0; i <= steps; i++) {
      const y = padT + chartH * (1 - i / steps);
      ctx.beginPath();
      ctx.moveTo(padL, y);
      ctx.lineTo(padL + chartW, y);
      ctx.stroke();
      // Y 轴标签
      ctx.fillStyle = '#9CA3AF';
      ctx.font = '10px sans-serif';
      ctx.textAlign = 'right';
      ctx.fillText(String(Math.round(maxCount * i / steps)), padL - 4, y + 4);
    }

    // X 轴标签
    ctx.fillStyle = '#9CA3AF';
    ctx.font = '10px sans-serif';
    ctx.textAlign = 'center';
    const step = chartW / (n - 1);
    this.dailyData.forEach((d, i) => {
      const x = padL + i * step;
      ctx.fillText(d.date, x, height - 4);
    });

    // 折线
    const points = this.dailyData.map((d, i) => ({
      x: padL + i * step,
      y: padT + chartH * (1 - d.count / maxCount)
    }));

    // 填充区域
    ctx.beginPath();
    ctx.moveTo(points[0].x, padT + chartH);
    points.forEach(p => ctx.lineTo(p.x, p.y));
    ctx.lineTo(points[points.length - 1].x, padT + chartH);
    ctx.closePath();
    const gradient = ctx.createLinearGradient(0, padT, 0, padT + chartH);
    gradient.addColorStop(0, 'rgba(59,130,246,0.3)');
    gradient.addColorStop(1, 'rgba(59,130,246,0.0)');
    ctx.fillStyle = gradient;
    ctx.fill();

    // 折线本身
    ctx.beginPath();
    ctx.strokeStyle = '#3B82F6';
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    points.forEach((p, i) => {
      if (i === 0) ctx.moveTo(p.x, p.y);
      else ctx.lineTo(p.x, p.y);
    });
    ctx.stroke();

    // 数据点
    points.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, 4, 0, Math.PI * 2);
      ctx.fillStyle = '#3B82F6';
      ctx.fill();
      ctx.strokeStyle = '#fff';
      ctx.lineWidth = 2;
      ctx.stroke();
    });
  }
}
