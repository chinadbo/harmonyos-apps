import router from '@ohos.router';
import { CityModel } from '../model/CityModel';
import { CitySearchItem } from '../components/CitySearchItem';
import WeatherViewModel from '../viewmodel/WeatherViewModel';

@Entry
@Component
struct CityListPage {
  @State keyword: string = '';
  @State version: number = 0;

  private async addCity(): Promise<void> {
    await WeatherViewModel.addCity(this.keyword);
    this.keyword = '';
    this.version++;
  }

  private async selectCity(city: CityModel): Promise<void> {
    await WeatherViewModel.refreshWeather(city.name);
    this.version++;
    router.back();
  }

  private async deleteCity(city: CityModel): Promise<void> {
    await WeatherViewModel.deleteCity(city);
    this.version++;
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        TextInput({ placeholder: 'Search city', text: this.keyword })
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#14FFFFFF')
          .onChange((value: string) => {
            this.keyword = value;
          })
        Button('Add')
          .height(48)
          .backgroundColor('#1E6FFF')
          .onClick(() => this.addCity())
      }
      .width('100%')

      Text('Saved Cities')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')

      List({ space: 12 }) {
        ForEach(WeatherViewModel.cities, (city: CityModel) => {
          ListItem() {
            CitySearchItem({
              city: city,
              onSelect: (selected: CityModel) => this.selectCity(selected),
              onDelete: (selected: CityModel) => this.deleteCity(selected)
            })
          }
        }, (city: CityModel) => `${city.id}`)
      }
      .layoutWeight(1)
      .width('100%')

      Button('Back')
        .width('100%')
        .height(46)
        .backgroundColor('#14FFFFFF')
        .fontColor('#FFFFFF')
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .linearGradient({
      angle: 135,
      colors: [['#0D1B2A', 0.0], ['#1B263B', 0.55], ['#415A77', 1.0]]
    })
  }
}
