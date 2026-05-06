@Component
export struct WeatherBackground {
  @Prop weatherCode: string;

  private backgroundColors(): Array<string> {
    if (['176', '263', '266', '293', '296', '299', '302', '305', '308', '353', '356', '359'].includes(this.weatherCode)) {
      return ['#2B4162', '#416788', '#7AA6C2'];
    }
    if (['200', '386', '389', '392', '395'].includes(this.weatherCode)) {
      return ['#1B2845', '#274060', '#335C81'];
    }
    if (['113'].includes(this.weatherCode)) {
      return ['#0B1F33', '#19547B', '#FFD166'];
    }
    return ['#172A3A', '#2A4F6E', '#4FB0C6'];
  }

  build() {
    Stack() {
      Column() {
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [[this.backgroundColors()[0], 0.0], [this.backgroundColors()[1], 0.55], [this.backgroundColors()[2], 1.0]]
      })

      Column() {
      }
      .width(320)
      .height(320)
      .borderRadius(160)
      .backgroundColor('#33FFFFFF')
      .blur(80)
      .position({ x: 220, y: -40 })

      Column() {
      }
      .width(260)
      .height(260)
      .borderRadius(130)
      .backgroundColor('#14FFFFFF')
      .position({ x: -40, y: 420 })
    }
    .width('100%')
    .height('100%')
  }
}
