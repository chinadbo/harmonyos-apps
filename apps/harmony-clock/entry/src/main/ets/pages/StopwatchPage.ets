import { TimeUtils } from '../utils/TimeUtils'

@Component
export struct StopwatchPage {
  @Prop elapsedMilliseconds: number = 0
  @Prop running: boolean = false
  onStart: () => void = (): void => {}
  onPause: () => void = (): void => {}
  onReset: () => void = (): void => {}

  build() {
    Column({ space: 20 }) {
      Text('Stopwatch')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(TimeUtils.formatDuration(this.elapsedMilliseconds))
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 24, bottom: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

      Row({ space: 12 }) {
        Button(this.running ? 'Pause' : 'Start')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .onClick(() => {
            if (this.running) {
              if (this.onPause) {
                this.onPause()
              }
            } else if (this.onStart) {
              this.onStart()
            }
          })

        Button('Reset')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .onClick(() => {
            if (this.onReset) {
              this.onReset()
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
