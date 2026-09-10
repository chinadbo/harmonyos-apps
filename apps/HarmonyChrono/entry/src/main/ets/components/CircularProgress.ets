import { AppConstants } from '../common/constants'
import { clampProgress } from '../common/utils'

@Component
export struct CircularProgress {
  @Prop @Watch('onProgressChanged') progress: number = 0
  @Prop @Watch('onProgressChanged') color: string = AppConstants.BRAND_COLOR
  @Prop size: number = 240

  @State private animatedProgress: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear(): void {
    this.animatedProgress = clampProgress(this.progress)
    this.drawRing()
  }

  onProgressChanged(): void {
    animateTo({ duration: 120, curve: Curve.EaseInOut }, () => {
      this.animatedProgress = clampProgress(this.progress)
    })
    this.drawRing()
  }

  private drawRing(): void {
    const center = this.size / 2
    const radius = center - 16
    this.context.clearRect(0, 0, this.size, this.size)
    this.context.lineWidth = 12
    this.context.lineCap = 'round'

    this.context.beginPath()
    this.context.strokeStyle = AppConstants.TRACK_COLOR
    this.context.arc(center, center, radius, 0, Math.PI * 2)
    this.context.stroke()

    this.context.beginPath()
    this.context.strokeStyle = this.color
    this.context.arc(center, center, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * this.animatedProgress)
    this.context.stroke()
  }

  build() {
    Canvas(this.context)
      .width(this.size)
      .height(this.size)
      .onReady(() => {
        this.drawRing()
      })
  }
}
