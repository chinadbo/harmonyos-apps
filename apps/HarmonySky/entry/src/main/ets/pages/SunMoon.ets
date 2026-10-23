import { SunTimes, MoonTimes, City, cities } from '../model/models';
import { getSunTimesView, getMoonTimesView, getRiseAzimuth } from '../engine/sunmoon';
import { fmtDate } from '../utils/format';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct SunMoon {
  @StorageProp('cityName') cityName: string = '北京';
  @StorageProp('latitude') latitude: number = 39.9042;
  @StorageProp('longitude') longitude: number = 116.4074;
  @State sun: SunTimes = getSunTimesView(new Date(), 39.9042, 116.4074);
  @State moon: MoonTimes = getMoonTimesView(new Date(), 39.9042, 116.4074);
  @State dateLabel: string = fmtDate(new Date());

  aboutToAppear(): void {
    this.refresh();
  }

  private refresh(): void {
    const now = new Date();
    this.sun = getSunTimesView(now, this.latitude, this.longitude);
    this.moon = getMoonTimesView(now, this.latitude, this.longitude);
    this.dateLabel = fmtDate(now);
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Text('日月升落')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F2F5FF')

            // 城市选择
            SkyCard({
              title: '观测地点',
              subtitle: `${this.cityName} (${this.latitude.toFixed(2)}°, ${this.longitude.toFixed(2)}°)`
            }) {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(cities, (c: City) => {
                  Text(c.name)
                    .fontSize(13)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin(4)
                    .borderRadius(14)
                    .backgroundColor(c.name === this.cityName ? '#5B8DEF' : '#22284E')
                    .fontColor(c.name === this.cityName ? '#FFFFFF' : '#C9D2F2')
                    .onClick(() => {
                      AppStorage.SetOrCreate('cityName', c.name);
                      AppStorage.SetOrCreate('latitude', c.lat);
                      AppStorage.SetOrCreate('longitude', c.lon);
                      this.refresh();
                    })
                }, (c) => c.name)
              }
              .width('100%')
            }

            // 太阳时刻表
            SkyCard({ title: '太阳' }) {
              Column({ space: 8 }) {
                Row({ space: 6 }) {
                  SunKV({ icon: '🌅', k: '日出', v: this.sun.sunrise })
                  SunKV({ icon: '🌇', k: '日落', v: this.sun.sunset })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                Row({ space: 6 }) {
                  SunKV({ icon: '🌄', k: '民用晨光始', v: this.sun.civilDawn })
                  SunKV({ icon: '🌆', k: '民用暮光终', v: this.sun.civilDusk })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                Row({ space: 6 }) {
                  SunKV({ icon: '☀️', k: '正午', v: this.sun.solarNoon })
                  SunKV({ icon: '⏱️', k: '昼长', v: this.sun.dayLength })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                if (this.sun.polarNote !== '') {
                  Text(this.sun.polarNote)
                    .fontSize(12)
                    .fontColor('#F5D76E')
                    .padding(8)
                    .borderRadius(8)
                    .backgroundColor('rgba(245, 215, 110, 0.12)')
                }
              }
              .width('100%')
            }

            // 月亮时刻表
            SkyCard({ title: '月亮' }) {
              Column({ space: 8 }) {
                Row({ space: 6 }) {
                  SunKV({ icon: '🌙', k: '月出', v: this.moon.moonRise })
                  SunKV({ icon: '🌫️', k: '月落', v: this.moon.moonSet })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                Row({ space: 6 }) {
                  SunKV({ icon: '🧭', k: '月出方位', v: `${getRiseAzimuth(new Date(), this.latitude, true).azimuthDeg}°` })
                  SunKV({ icon: '🧭', k: '日出方位', v: `${getRiseAzimuth(new Date(), this.latitude, false).azimuthDeg}°` })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                if (this.moon.polarNote !== '') {
                  Text(this.moon.polarNote)
                    .fontSize(12)
                    .fontColor('#F5D76E')
                    .padding(8)
                    .borderRadius(8)
                    .backgroundColor('rgba(245, 215, 110, 0.12)')
                }
              }
              .width('100%')
            }

            Text(`${this.dateLabel} · 数据由本地算法离线计算，方位角以正北为 0°`)
              .fontSize(11)
              .fontColor('#667099')
              .padding({ bottom: 4 })
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 2 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }
}

@Component
struct SunKV {
  @Prop icon: string = '';
  @Prop k: string = '';
  @Prop v: string = '';

  build() {
    Row({ space: 6 }) {
      Text(this.icon)
        .fontSize(14)
      Column({ space: 2 }) {
        Text(this.k)
          .fontSize(11)
          .fontColor('#9AA3C7')
        Text(this.v)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#F2F5FF')
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}
