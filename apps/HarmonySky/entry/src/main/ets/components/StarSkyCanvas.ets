// 星空背景 Canvas：随机星点 + 定时器闪烁重绘
@Component
export struct StarSkyCanvas {
  private stars: { x: number; y: number; r: number; alpha: number; speed: number }[] = [];
  private timer: number = -1;
  private ready: boolean = false;
  private width: number = 0;
  private height: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height('100%')
      .onAreaChange((_oldArea, newArea) => {
        this.width = newArea.width as number;
        this.height = newArea.height as number;
        this.initStars();
        if (this.ready) {
          this.draw();
        }
      })
      .onReady(() => {
        this.ready = true;
        this.initStars();
        this.draw();
        this.timer = setInterval(() => {
          this.draw();
        }, 2200);
      })
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  private initStars(): void {
    this.stars = [];
    if (this.width <= 0 || this.height <= 0) {
      return;
    }
    const count = Math.floor(this.width * this.height / 4200);
    for (let i = 0; i < count; i++) {
      this.stars.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        r: Math.random() * 1.1 + 0.4,
        alpha: Math.random() * 0.5 + 0.3,
        speed: Math.random() * 0.4 + 0.1
      });
    }
  }

  private draw(): void {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.width, this.height);
    // 深空渐变
    const bg = ctx.createLinearGradient(0, 0, 0, this.height);
    bg.addColorStop(0, '#070B1E');
    bg.addColorStop(0.6, '#0B1026');
    bg.addColorStop(1, '#101A3C');
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, this.width, this.height);

    // 星点（每次 alpha 走向随机目标，模拟闪烁）
    for (let i = 0; i < this.stars.length; i++) {
      const s = this.stars[i];
      const target = Math.random() * 0.7 + 0.3;
      s.alpha += (target - s.alpha) * s.speed * 4;
      ctx.globalAlpha = s.alpha;
      ctx.fillStyle = i % 7 === 0 ? '#BCD4FF' : '#F2F5FF';
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;

    // 银河带（斜向淡淡的星雾）
    ctx.globalAlpha = 0.08;
    ctx.fillStyle = '#9AA3C7';
    for (let i = 0; i < 4; i++) {
      ctx.beginPath();
      ctx.ellipse(this.width * (0.2 + i * 0.18), this.height * 0.5, 60 + i * 18, this.height * 0.34, -0.6, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }
}
