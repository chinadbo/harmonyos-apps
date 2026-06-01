@Component
export struct ProgressRing {
  @Prop progress: number = 0
  @Prop title: string = '打包完成率'

  private ringContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  private drawRing(): void {
    const normalized = Math.max(0, Math.min(100, this.progress))
    const centerX = 90
    const centerY = 90
    const radius = 58
    const startAngle = -Math.PI / 2
    const endAngle = startAngle + Math.PI * 2 * (normalized / 100)

    this.ringContext.clearRect(0, 0, 180, 180)
    this.ringContext.lineWidth = 14
    this.ringContext.strokeStyle = '#E5E7EB'
    this.ringContext.beginPath()
    this.ringContext.arc(centerX, centerY, radius, 0, Math.PI * 2)
    this.ringContext.stroke()

    this.ringContext.strokeStyle = '#3B82F6'
    this.ringContext.lineCap = 'round'
    this.ringContext.beginPath()
    this.ringContext.arc(centerX, centerY, radius, startAngle, endAngle)
    this.ringContext.stroke()
  }

  build() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Canvas(this.ringContext)
          .width(180)
          .height(180)
          .onReady(() => {
            this.drawRing()
          })

        Column({ space: 6 }) {
          Text(`${Math.max(0, Math.min(100, this.progress))}%`)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text(this.title)
            .fontSize(13)
            .fontColor('#64748B')
        }
      }
    }
    .padding(12)
  }
}
