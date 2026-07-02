@Component
export struct DegreeDisplay {
  @Prop heading: number = 0;

  build() {
    Column() {
      Text(`${Math.round(this.heading)}°`)
        .fontSize(72)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}