import router from '@ohos.router';
import { DailyWeather, WeatherModel } from '../model/WeatherModel';
import { TemperatureChart } from '../components/TemperatureChart';
import WeatherViewModel from '../viewmodel/WeatherViewModel';

@Entry
@Component
struct ForecastPage {
  @State weather: WeatherModel = new WeatherModel();

  aboutToAppear(): void {
    this.weather = WeatherViewModel.weather;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('7-Day Forecast')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
          Button('Back')
            .height(36)
            .backgroundColor('#1E6FFF')
            .onClick(() => router.back())
        }
        .width('100%')

        TemperatureChart({ days: this.weather.daily })

        Column({ space: 12 }) {
          ForEach(this.weather.daily, (item: DailyWeather) => {
            Row() {
              Column({ space: 4 }) {
                Text(item.date)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F7FBFF')
                Text(`UV ${item.uvIndex}`)
                  .fontSize(12)
                  .fontColor('#B7C9D9')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(`${item.mintempC}° / ${item.maxtempC}°`)
                .fontSize(18)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#14FFFFFF')
            .borderRadius(22)
          }, (item: DailyWeather) => item.date)
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#0B132B', 0.0], ['#1C2541', 0.6], ['#3A506B', 1.0]]
    })
  }
}
