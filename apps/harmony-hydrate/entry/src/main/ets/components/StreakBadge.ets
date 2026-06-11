@Component
export struct StreakBadge {
  @Prop streak: number = 0

  build() {
    Row({ space: 8 }) {
      Text('连续达标')
        .fontSize(14)
        .fontColor('#666666')
      Text(`${this.streak} 天`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0A7BFF')
    }
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor('#EEF6FF')
    .borderRadius(20)
  }
}
