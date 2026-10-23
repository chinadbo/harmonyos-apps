import { City, cities, settingsPrefKeys } from '../model/models';
import { getString, putString, putNumber, putBoolean, getBoolean } from '../utils/prefs';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct Settings {
  @StorageLink('cityName') cityName: string = '北京';
  @StorageLink('latitude') latitude: number = 39.9042;
  @StorageLink('longitude') longitude: number = 116.4074;
  @StorageLink('themeDark') themeDark: boolean = true;
  @State customLat: string = '';
  @State customLon: string = '';
  @State version: string = '1.0.0';

  aboutToAppear(): void {
    this.cityName = getString(settingsPrefKeys.city, '北京');
    this.themeDark = getBoolean(settingsPrefKeys.themeDark, true);
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Text('设置')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F2F5FF')

            // 城市选择
            SkyCard({ title: '预设城市' }) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(cities, (c: City) => {
                  Text(c.name)
                    .fontSize(13)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin(4)
                    .borderRadius(14)
                    .backgroundColor(c.name === this.cityName ? '#5B8DEF' : '#22284E')
                    .fontColor(c.name === this.cityName ? '#FFFFFF' : '#C9D2F2')
                    .onClick(() => {
                      this.cityName = c.name;
                      this.latitude = c.lat;
                      this.longitude = c.lon;
                      putString(settingsPrefKeys.city, c.name);
                      putNumber(settingsPrefKeys.lat, c.lat);
                      putNumber(settingsPrefKeys.lon, c.lon);
                    })
                }, (c: City) => c.name)
              }
              .width('100%')
            }

            // 自定义坐标
            SkyCard({ title: '自定义坐标', subtitle: '支持任意观测地，如郊野光污染更少的暗夜地点' }) {
              Column({ space: 10 }) {
                Row({ space: 10 }) {
                  TextInput({ placeholder: `纬度 (当前 ${this.latitude.toFixed(2)})`, text: this.customLat })
                    .type(InputType.Number)
                    .fontSize(13)
                    .height(40)
                    .backgroundColor('#22284E')
                    .fontColor('#F2F5FF')
                    .layoutWeight(1)
                    .onChange((v: string) => {
                      this.customLat = v;
                    })
                  TextInput({ placeholder: `经度 (当前 ${this.longitude.toFixed(2)})`, text: this.customLon })
                    .type(InputType.Number)
                    .fontSize(13)
                    .height(40)
                    .backgroundColor('#22284E')
                    .fontColor('#F2F5FF')
                    .layoutWeight(1)
                    .onChange((v: string) => {
                      this.customLon = v;
                    })
                }
                .width('100%')

                Button('应用自定义坐标')
                  .fontSize(13)
                  .height(38)
                  .width('100%')
                  .backgroundColor('#5B8DEF')
                  .fontColor('#FFFFFF')
                  .onClick(() => {
                    const lat = parseFloat(this.customLat);
                    const lon = parseFloat(this.customLon);
                    if (Number.isNaN(lat) || Number.isNaN(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                      this.getUIContext().getPromptAction().showToast({ message: '坐标无效：纬度 -90~90，经度 -180~180' });
                      return;
                    }
                    this.latitude = lat;
                    this.longitude = lon;
                    this.cityName = '自定义坐标';
                    putNumber(settingsPrefKeys.lat, lat);
                    putNumber(settingsPrefKeys.lon, lon);
                    putString(settingsPrefKeys.city, '自定义坐标');
                    this.getUIContext().getPromptAction().showToast({ message: '已应用自定义坐标' });
                  })
              }
              .width('100%')
            }

            // 主题
            SkyCard({ title: '主题' }) {
              Row() {
                Column({ space: 2 }) {
                  Text('深空暗色主题')
                    .fontSize(14)
                    .fontColor('#F2F5FF')
                  Text('关掉后使用更亮的观星护眼配色（仍为深色基调）')
                    .fontSize(11)
                    .fontColor('#9AA3C7')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Toggle({ type: ToggleType.Switch, isOn: this.themeDark })
                  .onChange((on: boolean) => {
                    this.themeDark = on;
                    putBoolean(settingsPrefKeys.themeDark, on);
                  })
              }
              .width('100%')
            }

            // 关于
            SkyCard({ title: '关于' }) {
              Column({ space: 6 }) {
                Text('HarmonySky 观星 v' + this.version)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F2F5FF')
                Text('纯离线天文算法应用：月相、日月升落均由本地计算，不联网、不申请任何权限、不收集任何数据。')
                  .fontSize(12)
                  .fontColor('#9AA3C7')
                  .lineHeight(20)
                Text('月相数据误差约 ±1 分钟，升落时刻误差约 ±2 分钟，仅供观星参考。')
                  .fontSize(12)
                  .fontColor('#9AA3C7')
                  .lineHeight(20)
              }
              .width('100%')
            }
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 5 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }
}
