@Component
export struct WeekCard {
  @Prop week: number = 0;
  @Prop day: number = 0;
  @Prop stage: string = '孕早期';
  @Prop daysLeft: number = 0;

  private dueLabel(): string {
    if (this.daysLeft > 0) {
      return `距预产期还有 ${this.daysLeft} 天`;
    }
    if (this.daysLeft === 0) {
      return '今天就是预产期';
    }
    return `已超过预产期 ${-this.daysLeft} 天`;
  }

  build() {
    Column() {
      Row() {
        Text('当前孕周')
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.85)')
          .layoutWeight(1)

        Text(this.stage)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D6336C')
          .backgroundColor('rgba(255,255,255,0.9)')
          .borderRadius(12)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Text(`${this.week}`)
          .fontSize(64)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('周')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .margin({ left: 4, bottom: 10 })
        Text(`${this.day}`)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(255,255,255,0.95)')
          .margin({ left: 10, bottom: 8 })
        Text('天')
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.9)')
          .margin({ left: 2, bottom: 10 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: 2 })

      Text(this.dueLabel())
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.92)')
        .margin({ top: 10 })
    }
    .width('100%')
    .padding(20)
    .borderRadius(26)
    .linearGradient({
      angle: 135,
      colors: [['#FFB6D5', 0.0], ['#FF8DBE', 0.55], ['#F26BA8', 1.0]]
    })
    .shadow({ radius: 18, color: 'rgba(242,107,168,0.35)', offsetX: 0, offsetY: 8 })
  }
}
