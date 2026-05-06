@Component
export struct WeatherDetailCard {
  @Prop title: string;
  @Prop value: string;
  @Prop suffix: string;

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#B7C9D9')
      Row() {
        Text(this.value)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F7FBFF')
        Text(this.suffix)
          .fontSize(14)
          .fontColor('#B7C9D9')
          .margin({ left: 4, top: 8 })
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .width('48%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#14FFFFFF')
    .borderRadius(22)
    .backdropBlur(24)
  }
}
