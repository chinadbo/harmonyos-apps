interface NoiseReferenceItem {
  level: number
  label: string
  color: string
  description: string
}

@Component
export struct ReferenceCard {
  @Prop item: NoiseReferenceItem

  build() {
    Row() {
      Column() {
        Text(`${this.item.level} dB`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(80)
      .height(60)
      .backgroundColor(this.item.color)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.item.label)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 4 })

        Text(this.item.description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }
}

export const noiseReferences: NoiseReferenceItem[] = [
  { level: 30, label: 'Whisper', color: '#4CAF50', description: 'Very quiet, like a library or countryside at night' },
  { level: 40, label: 'Quiet Room', color: '#8BC34A', description: 'Soft ambient noise, comfortable for sleeping' },
  { level: 50, label: 'Office', color: '#CDDC39', description: 'Moderate background noise, typical office environment' },
  { level: 60, label: 'Conversation', color: '#FFC107', description: 'Normal conversation, comfortable for most people' },
  { level: 70, label: 'Traffic', color: '#FF9800', description: 'Busy street traffic, may cause annoyance over time' },
  { level: 80, label: 'Factory', color: '#FF5722', description: 'Loud machinery, hearing protection recommended' },
  { level: 90, label: 'Motorcycle', color: '#F44336', description: 'Very loud, prolonged exposure can damage hearing' },
  { level: 100, label: 'Concert', color: '#D32F2F', description: 'Extremely loud, immediate hearing damage risk' },
  { level: 110, label: 'Jet Engine', color: '#B71C1C', description: 'Painfully loud, permanent hearing damage likely' },
  { level: 120, label: 'Threshold of Pain', color: '#7F0000', description: 'Maximum pain threshold, immediate damage' }
]
