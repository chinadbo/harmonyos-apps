@Component
export struct RingProgress {
  @Prop @Watch('onProgressChange') progress: number
  @Prop size: number
  @Prop strokeWidth: number
  @Prop color: string
  @Prop trackColor: string
  @Prop label: string

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  onProgressChange(): void {
    this.drawRing()
  }

  private drawRing(): void {
    const center: number = this.size / 2
    const radius: number = (this.size - this.strokeWidth) / 2
    const safeProgress: number = Math.max(0, Math.min(this.progress, 1))

    this.context.clearRect(0, 0, this.size, this.size)

    this.context.beginPath()
    this.context.strokeStyle = this.trackColor
    this.context.lineWidth = this.strokeWidth
    this.context.lineCap = 'round'
    this.context.arc(center, center, radius, -Math.PI / 2, Math.PI * 1.5, false)
    this.context.stroke()

    this.context.beginPath()
    this.context.strokeStyle = this.color
    this.context.lineWidth = this.strokeWidth
    this.context.lineCap = 'round'
    this.context.arc(center, center, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * safeProgress, false)
    this.context.stroke()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .width(this.size)
        .height(this.size)
        .onReady(() => {
          this.drawRing()
        })

      Column({ space: 4 }) {
        Text(`${Math.round(this.progress * 100)}%`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.color)
        Text(this.label)
          .fontSize(12)
          .fontColor('#666666')
      }
    }
    .width(this.size)
    .height(this.size)
  }
}
