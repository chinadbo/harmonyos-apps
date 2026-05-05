@Component
export struct StreakBadge {
  @Prop count: number = 0;
  @Prop color: string = '#5B8FF9';

  build() {
    Row({ space: 6 }) {
      Text('连击')
        .fontSize(12)
        .fontColor('#FFFFFFAA')
      Text(`${this.count} 天`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor(this.color)
    .borderRadius(16)
  }
}
