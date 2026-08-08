import { TimeUtils } from '../utils/TimeUtils'

@Component
export struct TimerPage {
  @Prop remainingSeconds: number = 0
  @Prop running: boolean = false
  @Prop presetSeconds: number = 0
  onStart: () => void = (): void => {}
  onPause: () => void = (): void => {}
  onReset: () => void = (): void => {}
  onPresetChange: (seconds: number) => void = (_seconds: number): void => {}

  build() {
    Column({ space: 20 }) {
      Text('Timer')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(TimeUtils.formatTimer(this.remainingSeconds))
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 24, bottom: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

      Row({ space: 8 }) {
        Button('1 min')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.presetSeconds === 60 ? '#317AF7' : '#FFFFFF')
          .fontColor(this.presetSeconds === 60 ? '#FFFFFF' : '#222222')
          .onClick(() => {
            if (this.onPresetChange) {
              this.onPresetChange(60)
            }
          })
        Button('5 min')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.presetSeconds === 300 ? '#317AF7' : '#FFFFFF')
          .fontColor(this.presetSeconds === 300 ? '#FFFFFF' : '#222222')
          .onClick(() => {
            if (this.onPresetChange) {
              this.onPresetChange(300)
            }
          })
        Button('10 min')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .backgroundColor(this.presetSeconds === 600 ? '#317AF7' : '#FFFFFF')
          .fontColor(this.presetSeconds === 600 ? '#FFFFFF' : '#222222')
          .onClick(() => {
            if (this.onPresetChange) {
              this.onPresetChange(600)
            }
          })
      }
      .width('100%')

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
