@Component
export struct WaterProgressRing {
  @Prop current: number = 0
  @Prop goal: number = 2000
  private contextSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings)

  @Watch('onDataChanged')
  @Prop progressSeed: number = 0

  onDataChanged(): void {
    this.drawRing()
  }

  private drawRing(): void {
    const progress = this.goal > 0 ? Math.min(this.current / this.goal, 1) : 0
    const centerX = 110
    const centerY = 110
    const radius = 82

    this.canvasContext.clearRect(0, 0, 220, 220)
    this.canvasContext.lineWidth = 16
    this.canvasContext.strokeStyle = '#E8EEF7'
    this.canvasContext.beginPath()
    this.canvasContext.arc(centerX, centerY, radius, 0, Math.PI * 2)
    this.canvasContext.stroke()

    this.canvasContext.strokeStyle = '#0A7BFF'
    this.canvasContext.beginPath()
    this.canvasContext.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * progress)
    this.canvasContext.stroke()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.canvasContext)
        .width(220)
        .height(220)
        .onReady(() => {
          this.drawRing()
        })
      Column({ space: 6 }) {
        Text(`${this.current}`)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
        Text(`/ ${this.goal} ml`)
          .fontSize(16)
          .fontColor('#666666')
      }
    }
    .width(220)
    .height(220)
  }
}
