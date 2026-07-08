import { DecibelStats } from '../analysis/DecibelAnalyzer'

@Component
export struct ControlPanel {
  @Prop isCapturing: boolean
  @Prop canSave: boolean
  @Prop thresholdDb: number
  @Prop currentDb: number
  onStart: () => void = () => {}
  onStop: () => void = () => {}
  onReset: () => void = () => {}
  onSave: () => void = () => {}

  build() {
    Column() {
      // Threshold indicator bar
      Row() {
        Stack() {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#E0E0E0')
            .borderRadius(4)

          Row()
            .width(`${Math.min(100, Math.max(0, (this.currentDb - 30) / 90 * 100))}%`)
            .height(8)
            .backgroundColor(this.getBarColor())
            .borderRadius(4)

          Row()
            .width(2)
            .height(14)
            .backgroundColor('#F44336')
            .position({
              x: `${Math.min(100, Math.max(0, (this.thresholdDb - 30) / 90 * 100))}%`,
              y: -3
            })
        }
        .width('100%')
        .height(20)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        Button() {
          Text(this.isCapturing ? $r('app.string.stop') : $r('app.string.start'))
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .width(120)
        .height(48)
        .backgroundColor(this.isCapturing ? $r('app.color.danger') : $r('app.color.primary'))
        .onClick(() => {
          if (this.isCapturing) {
            this.onStop()
          } else {
            this.onStart()
          }
        })

        Button() {
          Text($r('app.string.reset'))
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
        }
        .width(100)
        .height(48)
        .backgroundColor($r('app.color.background'))
        .border({ width: 1, color: $r('app.color.text_secondary') })
        .onClick(() => {
          this.onReset()
        })

        Button() {
          Text($r('app.string.save'))
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .width(100)
        .height(48)
        .backgroundColor(this.canSave ? $r('app.color.accent') : '#BDBDBD')
        .enabled(this.canSave)
        .onClick(() => {
          this.onSave()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  private getBarColor(): ResourceColor {
    if (this.currentDb < 60) {
      return $r('app.color.safe')
    } else if (this.currentDb < 85) {
      return $r('app.color.warning')
    } else {
      return $r('app.color.danger')
    }
  }
}
