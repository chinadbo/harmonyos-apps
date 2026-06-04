@Component
export struct SummaryCard {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop subValue: string = '';
  @Prop accentColor: string = '#4E7BF2';

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#5B6B7C')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.value)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2D3D')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.subValue)
        .fontSize(13)
        .fontColor(this.accentColor)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('48%')
  }
}
