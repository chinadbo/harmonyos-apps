@Component
export struct BarChart {
  @Prop labels: string[] = []
  @Prop values: number[] = []
  @Prop colors: string[] = ['#FF6B6B', '#51CF66', '#74C0FC']

  private getMaxValue(): number {
    const maxValue: number = Math.max(...this.values, 1)
    return maxValue <= 0 ? 1 : maxValue
  }

  private getBarHeight(value: number): number {
    return Math.max(12, Math.floor((value / this.getMaxValue()) * 120))
  }

  build() {
    Column({ space: 12 }) {
      Text('模式统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#212529')
        .width('100%')
        .textAlign(TextAlign.Start)
      Row({ space: 16 }) {
        ForEach(this.labels, (label: string, index: number) => {
          Column({ space: 8 }) {
            Blank()
              .width(48)
              .height(this.getBarHeight(this.values[index] ?? 0))
              .backgroundColor(this.colors[index % this.colors.length])
              .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 4, bottomRight: 4 })
            Text(String(this.values[index] ?? 0))
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#212529')
            Text(label)
              .fontSize(12)
              .fontColor('#868E96')
          }
          .justifyContent(FlexAlign.End)
          .height(180)
          .layoutWeight(1)
        }, (label: string) => label)
      }
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('100%')
  }
}
