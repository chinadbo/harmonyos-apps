import router from '@ohos.router';
import { MoonInfo } from '../model/models';
import { computeMoonInfo } from '../engine/astro';
import { getSunTimesView, getMoonTimesView } from '../engine/sunmoon';
import { fmtDate, fmtWeekday, fmtPercent, fmtKm, fmtDays, seasonTip } from '../utils/format';
import { MoonPhaseCanvas } from '../components/MoonPhaseCanvas';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct Index {
  @StorageProp('cityName') cityName: string = '北京';
  @StorageProp('latitude') latitude: number = 39.9042;
  @StorageProp('longitude') longitude: number = 116.4074;
  @State moon: MoonInfo = computeMoonInfo(new Date());
  @State today: string = fmtDate(new Date());
  @State weekday: string = fmtWeekday(new Date());
  private now: Date = new Date();

  aboutToAppear(): void {
    this.refresh();
  }

  private refresh(): void {
    this.now = new Date();
    this.moon = computeMoonInfo(this.now);
    this.today = fmtDate(this.now);
    this.weekday = fmtWeekday(this.now);
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Column() {
                Text('HarmonySky 观星')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F2F5FF')
                Text(`${this.today} ${this.weekday} · ${this.cityName}`)
                  .fontSize(13)
                  .fontColor('#9AA3C7')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Button('刷新')
                .fontSize(13)
                .height(32)
                .backgroundColor('#161B3A')
                .fontColor('#9AA3C7')
                .onClick(() => {
                  this.refresh();
                })
            }
            .width('100%')

            // 今日月相大图
            SkyCard({ title: '今日月相' }) {
              Column({ space: 8 }) {
                MoonPhaseCanvas({ phase: this.moon.phase, size: 210 })
                Text(this.moon.phaseName)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F5D76E')
                Text(`月龄 ${this.moon.ageDays.toFixed(1)} 天 · 照亮 ${fmtPercent(this.moon.illumination)}`)
                  .fontSize(14)
                  .fontColor('#F2F5FF')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }

            // 升落信息
            SkyCard({ title: '日月升落', subtitle: this.cityName }) {
              Column({ space: 8 }) {
                Row() {
                  KV({ k: '日出', v: getSunTimesView(this.now, this.latitude, this.longitude).sunrise })
                  KV({ k: '日落', v: getSunTimesView(this.now, this.latitude, this.longitude).sunset })
                  KV({ k: '月出', v: getMoonTimesView(this.now, this.latitude, this.longitude).moonRise })
                  KV({ k: '月落', v: getMoonTimesView(this.now, this.latitude, this.longitude).moonSet })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
            }

            // 月相档案
            SkyCard({ title: '月球档案' }) {
              Column({ space: 8 }) {
                Row() {
                  KV({ k: '地月距离', v: fmtKm(this.moon.distanceKm) })
                  KV({ k: '视直径', v: `${this.moon.angularDiameterDeg.toFixed(2)}°` })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                Row() {
                  KV({ k: '距下一次朔', v: fmtDays(this.moon.nextNewMoonDays) })
                  KV({ k: '距下一次望', v: fmtDays(this.moon.nextFullMoonDays) })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
            }

            // 观星提示
            SkyCard({ title: '今晚观星指数' }) {
              Column({ space: 6 }) {
                Text(this.skyTip())
                  .fontSize(14)
                  .fontColor('#F2F5FF')
                  .lineHeight(22)
                Text(seasonTip(this.now))
                  .fontSize(13)
                  .fontColor('#9AA3C7')
                  .lineHeight(20)
              }
              .width('100%')
            }

            // 快捷入口
            Row({ space: 10 }) {
              Quick({ icon: '📅', label: '月相日历', url: 'pages/MoonCalendar' })
              Quick({ icon: '🌅', label: '日月升落', url: 'pages/SunMoon' })
              Quick({ icon: '✨', label: '观星清单', url: 'pages/StarList' })
            }
            .width('100%')
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 0 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }

  private skyTip(): string {
    const ill = this.moon.illumination;
    if (ill < 0.15) {
      return '今夜月光几乎为零，是观测深空天体与流星雨的绝佳窗口，别错过银河！';
    }
    if (ill < 0.45) {
      return '月光较弱，双筒观星能看到不少细节，上半夜比后半夜更佳。';
    }
    if (ill < 0.75) {
      return '月光明显，适合观测月球环形山与亮星、双星，深空目标建议月落后进行。';
    }
    return '满月前后月光强烈，深空天体难以观测，但正是欣赏月面细节的好时机。';
  }
}

@Component
struct KV {
  @Prop k: string = '';
  @Prop v: string = '';

  build() {
    Column({ space: 2 }) {
      Text(this.k)
        .fontSize(11)
        .fontColor('#9AA3C7')
      Text(this.v)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F2F5FF')
    }
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
struct Quick {
  @Prop icon: string = '';
  @Prop label: string = '';
  @Prop url: string = '';

  build() {
    Column({ space: 4 }) {
      Text(this.icon)
        .fontSize(26)
      Text(this.label)
        .fontSize(12)
        .fontColor('#F2F5FF')
    }
    .width('32%')
    .padding(12)
    .borderRadius(14)
    .backgroundColor('#161B3A')
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      router.pushUrl({ url: this.url });
    })
  }
}
