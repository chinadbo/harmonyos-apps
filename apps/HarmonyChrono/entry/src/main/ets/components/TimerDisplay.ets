import { AppConstants } from '../common/constants'
import { formatStopwatchTime } from '../common/utils'

@Component
export struct TimerDisplay {
  @Prop elapsedMilliseconds: number = 0
  @Prop running: boolean = false

  build() {
    Text(formatStopwatchTime(this.elapsedMilliseconds))
      .fontSize(42)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.running ? AppConstants.RUNNING_COLOR : AppConstants.PAUSED_COLOR)
      .fontFamily('monospace')
      .textAlign(TextAlign.Center)
      .width('100%')
  }
}
