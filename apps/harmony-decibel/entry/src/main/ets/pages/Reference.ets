import { ReferenceCard, noiseReferences } from '../components/ReferenceCard'
import { UIContext } from '@ohos.arkui'

@Entry
@Component
struct Reference {
  build() {
    Column() {
      Row() {
        Button() {
          Text('← Back')
            .fontSize(16)
            .fontColor($r('app.color.primary'))
        }
        .backgroundColor('transparent')
        .onClick(() => {
          const ctx = this.getUIContext() as UIContext
          ctx.getRouter().back()
        })

        Text('Noise Reference')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          Text('Common noise levels and their effects on hearing health')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 16, left: 16, right: 16 })

          ForEach(noiseReferences, (item, index) => {
            ReferenceCard({ item: item })
          })

          Column() {
            Text('Hearing Safety Guidelines')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('• Below 70 dB: Safe for extended exposure')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })

            Text('• 70-85 dB: Safe for up to 8 hours')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })

            Text('• 85-100 dB: Use hearing protection, limit to 2 hours')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })

            Text('• Above 100 dB: Immediate risk of hearing damage')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })

            Text('• Above 120 dB: Pain threshold, permanent damage likely')
              .fontSize(14)
              .fontColor($r('app.color.danger'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ bottom: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}

export default Reference
