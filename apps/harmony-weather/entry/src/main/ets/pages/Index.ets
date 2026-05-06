import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/MainPage'
      });
    }, 10);
  }

  build() {
    Column({ space: 16 }) {
      Text('HarmonyWeather')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text('Preparing your forecast...')
        .fontSize(16)
        .fontColor('#D9E8F2')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#0B1F33', 0.0], ['#1B4965', 0.5], ['#62B6CB', 1.0]]
    })
  }
}
