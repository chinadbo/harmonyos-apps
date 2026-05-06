import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { HourlyWeather } from '../model/WeatherModel';
import WeatherViewModel from '../viewmodel/WeatherViewModel';
import { HourlyItem } from '../components/HourlyItem';
import { WeatherBackground } from '../components/WeatherBackground';
import { WeatherDetailCard } from '../components/WeatherDetailCard';

@Entry
@Component
struct MainPage {
  @State weatherVersion: number = 0;
  @State initialized: boolean = false;

  async aboutToAppear() {
    if (this.initialized) {
      return;
    }
    this.initialized = true;
    const context = getContext(this) as common.UIAbilityContext;
    await WeatherViewModel.init(context);
    this.weatherVersion++;
  }

  private refresh(): void {
    WeatherViewModel.refreshWeather(WeatherViewModel.selectedCity).then(() => {
      this.weatherVersion++;
    });
  }

  private openCities(): void {
    router.pushUrl({
      url: 'pages/CityListPage'
    });
  }

  private openForecast(): void {
    WeatherViewModel.openForecast();
  }

  build() {
    Stack() {
      WeatherBackground({ weatherCode: WeatherViewModel.weather.current.weatherCode })
      Scroll() {
        Column({ space: 20 }) {
          Row() {
            Column({ space: 4 }) {
              Text(WeatherViewModel.weather.city)
                .fontSize(34)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${WeatherViewModel.weather.region} ${WeatherViewModel.weather.country}`)
                .fontSize(15)
                .fontColor('#D6EAF8')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Button('Cities')
              .height(38)
              .backgroundColor('#1E6FFF')
              .onClick(() => this.openCities())
          }
          .width('100%')

          Column({ space: 6 }) {
            Text(`${WeatherViewModel.weather.current.tempC}°`)
              .fontSize(88)
              .fontWeight(FontWeight.Light)
              .fontColor('#FFFFFF')
            Text(WeatherViewModel.weather.current.description)
              .fontSize(22)
              .fontColor('#EAF6FF')
            Text(`Feels like ${WeatherViewModel.weather.current.feelsLikeC}° · Updated ${WeatherViewModel.weather.updatedAt}`)
              .fontSize(14)
              .fontColor('#C0D8E8')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 24, bottom: 12 })

          Scroll({ scrollDirection: Axis.Horizontal }) {
            Row({ space: 12 }) {
              ForEach(WeatherViewModel.currentHourly(), (item: HourlyWeather) => {
                HourlyItem({ item: item })
              }, (item: HourlyWeather) => `${item.time}-${item.tempC}`)
            }
          }
          .scrollBar(BarState.Off)
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            WeatherDetailCard({ title: 'Humidity', value: WeatherViewModel.weather.current.humidity, suffix: '%' })
            WeatherDetailCard({ title: 'Wind', value: WeatherViewModel.weather.current.windspeedKmph, suffix: 'km/h' })
            WeatherDetailCard({ title: 'Visibility', value: WeatherViewModel.weather.current.visibility, suffix: 'km' })
            WeatherDetailCard({ title: 'UV Index', value: WeatherViewModel.weather.current.uvIndex, suffix: '' })
          }
          .width('100%')

          Row({ space: 12 }) {
            Button('Refresh')
              .layoutWeight(1)
              .height(46)
              .backgroundColor('#1E6FFF')
              .onClick(() => this.refresh())
            Button('7-Day Forecast')
              .layoutWeight(1)
              .height(46)
              .backgroundColor('#14FFFFFF')
              .fontColor('#FFFFFF')
              .onClick(() => this.openForecast())
          }
          .width('100%')

          if (WeatherViewModel.errorMessage.length > 0) {
            Text(WeatherViewModel.errorMessage)
              .fontSize(14)
              .fontColor('#FFD7D7')
              .width('100%')
          }
        }
        .width('100%')
        .padding(24)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
