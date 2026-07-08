import { DecibelStats } from '../analysis/DecibelAnalyzer'

@Component
export struct DecibelDisplay {
  @Prop stats: DecibelStats
  @Prop noiseLabel: string
  @Prop noiseColor: string

  build() {
    Column() {
      Text($r('app.string.current_db'))
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 8 })

      Text(this.stats.current > 0 ? this.stats.current.toFixed(1) : '--.-')
        .fontSize(72)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.noiseColor)
        .margin({ bottom: 4 })

      Text('dB')
        .fontSize(20)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 16 })

      Text(this.noiseLabel)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.noiseColor)
        .padding({ top: 4, bottom: 4, left: 16, right: 16 })
        .backgroundColor(this.noiseColor + '20')
        .borderRadius(16)

      Row() {
        Column() {
          Text($r('app.string.avg_db'))
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Text(this.stats.average > 0 ? this.stats.average.toFixed(1) : '--')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .layoutWeight(1)

        Column() {
          Text($r('app.string.max_db'))
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Text(this.stats.max > 0 ? this.stats.max.toFixed(1) : '--')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.danger'))
        }
        .layoutWeight(1)

        Column() {
          Text($r('app.string.min_db'))
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Text(this.stats.min > 0 ? this.stats.min.toFixed(1) : '--')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.safe'))
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 24 })
      .padding({ top: 16, bottom: 16 })
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(12)
    }
    .width('100%')
    .padding(16)
  }
}
