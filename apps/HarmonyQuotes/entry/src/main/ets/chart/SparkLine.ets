/**
 * 迷你走势线：自选卡片右侧的分时缩略图
 */

@Component
export struct SparkLine {
  @Prop data: number[] = []
  @Prop lineColor: string = '#E5393D'
  @Prop lineHeight: number = 36
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  build() {
    Canvas(this.ctx)
      .width('100%')
      .height(this.lineHeight)
      .onReady(() => {
        this.draw()
      })
      .onAreaChange(() => {
        this.draw()
      })
  }

  private draw(): void {
    const ctx = this.ctx
    const w: number = ctx.width
    const h: number = ctx.height
    if (w <= 0 || h <= 0) {
      return
    }
    ctx.clearRect(0, 0, w, h)
    if (this.data.length < 2) {
      return
    }
    let min: number = this.data[0]
    let max: number = this.data[0]
    for (const v of this.data) {
      if (v < min) {
        min = v
      }
      if (v > max) {
        max = v
      }
    }
    if (max - min < 1e-6) {
      max = min + 1e-6
    }
    const pad: number = 3
    const stepX: number = (w - pad * 2) / (this.data.length - 1)
    ctx.strokeStyle = this.lineColor
    ctx.lineWidth = 1.5
    ctx.beginPath()
    for (let i = 0; i < this.data.length; i++) {
      const x: number = pad + i * stepX
      const y: number = pad + (1 - (this.data[i] - min) / (max - min)) * (h - pad * 2)
      if (i === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    }
    ctx.stroke()
  }
}
