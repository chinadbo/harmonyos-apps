@Component
export struct WeatherCard {
  @LocalStorageProp('city') city: string = 'Beijing';
  @LocalStorageProp('temperature') temperature: string = '26°';
  @LocalStorageProp('description') description: string = 'Sunny';
  @LocalStorageProp('updatedAt') updatedAt: string = 'Now';

  build() {
    Column({ space: 8 }) {
      Text(this.city)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
      Text(this.temperature)
        .fontSize(42)
        .fontWeight(FontWeight.Light)
        .fontColor('#FFFFFF')
        .width('100%')
      Text(this.description)
        .fontSize(14)
        .fontColor('#D8E8F8')
        .width('100%')
      Blank()
      Text(`Updated ${this.updatedAt}`)
        .fontSize(12)
        .fontColor('#C7DAEB')
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .linearGradient({
      angle: 135,
      colors: [['#17324D', 0.0], ['#235789', 0.55], ['#5BC0EB', 1.0]]
    })
    .borderRadius(24)
  }
}
