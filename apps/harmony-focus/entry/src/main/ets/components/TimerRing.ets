import { AppDefaults, SessionMode } from '../common/Constants'
import { formatSeconds, getModeColor, toPercent } from '../common/Utils'

@Component
export struct TimerRing {
  @Prop @Watch('onTimerChanged') remainingSeconds: number = 0
  @Prop @Watch('onTimerChanged') totalSeconds: number = 1
  @Prop @Watch('onTimerChanged') mode: SessionMode = SessionMode.FOCUS
  @Prop size: number = 260

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  // @Watch 回调：任何计时相关属性变化时重绘
  onTimerChanged(): void {
    this.drawRing()
  }

  aboutToAppear(): void {
    this.drawRing()
  }

  private drawRing(): void {
    const center: number = this.size / 2
    const radius: number = center - 16
    const progress: number = toPercent(this.remainingSeconds, this.totalSeconds)
    this.context.clearRect(0, 0, this.size, this.size)
    this.context.lineWidth = 14
    this.context.lineCap = 'round'

    // 背景轨道
    this.context.beginPath()
    this.context.strokeStyle = AppDefaults.TRACK_COLOR
    this.context.arc(center, center, radius, 0, Math.PI * 2)
    this.context.stroke()

    // 进度弧（从 12 点位置顺时针）
    this.context.beginPath()
    this.context.strokeStyle = getModeColor(this.mode)
    this.context.arc(center, center, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * progress)
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
      Column({ space: 8 }) {
        Text(formatSeconds(this.remainingSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212529')
        Text(this.mode === SessionMode.FOCUS ? '保持专注' : '放松一下')
          .fontSize(14)
          .fontColor('#868E96')
      }
    }
    .width(this.size)
    .height(this.size)
  }
}
