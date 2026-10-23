import router from '@ohos.router';
import { StarTarget } from '../model/models';
import { starTargets } from '../engine/stardata';
import { computeMoonInfo } from '../engine/astro';
import { getBoolean, putBoolean } from '../utils/prefs';
import { fmtAngle } from '../utils/format';
import { MoonPhaseCanvas } from '../components/MoonPhaseCanvas';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';

interface DetailParams {
  id: string;
}

@Entry
@Component
struct StarDetail {
  @State target: StarTarget = starTargets[0];
  @State done: boolean = false;
  @State moonPhase: number = 0;
  private prefKey: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as DetailParams;
    const id = params !== undefined && params.id !== undefined ? params.id : 'sirius';
    for (let i = 0; i < starTargets.length; i++) {
      if (starTargets[i].id === id) {
        this.target = starTargets[i];
        break;
      }
    }
    this.prefKey = `star_done_${this.target.id}`;
    this.done = getBoolean(this.prefKey, false);
    this.moonPhase = computeMoonInfo(new Date()).phase;
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Button('◀ 返回')
                .fontSize(13)
                .height(32)
                .backgroundColor('#161B3A')
                .fontColor('#F2F5FF')
                .onClick(() => {
                  router.back();
                })
            }
            .width('100%')

            SkyCard() {
              Column({ space: 8 }) {
                Text(this.target.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F5D76E')
                Text(`${this.target.constellation} · 最佳季节：${this.target.bestSeason}`)
                  .fontSize(13)
                  .fontColor('#9AA3C7')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }

            // 观测档案
            SkyCard({ title: '观测档案' }) {
              Column({ space: 8 }) {
                Row({ space: 6 }) {
                  Info({ k: '视星等', v: this.target.mag === 0 ? '—（流星雨）' : this.target.mag.toFixed(2) })
                  Info({ k: '难度', v: '★'.repeat(this.target.difficulty) })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                Row({ space: 6 }) {
                  Info({ k: '赤经', v: fmtAngle(this.target.ra, true) })
                  Info({ k: '赤纬', v: fmtAngle(this.target.dec, false) })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
            }

            // 知识与建议
            SkyCard({ title: '观测建议' }) {
              Text(this.target.desc)
                .fontSize(14)
                .fontColor('#F2F5FF')
                .lineHeight(24)
                .width('100%')
            }

            // 今晚是否适合
            SkyCard({ title: '今晚窗口' }) {
              Row({ space: 14 }) {
                MoonPhaseCanvas({ phase: this.moonPhase, size: 72 })
                Column({ space: 4 }) {
                  Text(this.observeTip())
                    .fontSize(13)
                    .fontColor('#F2F5FF')
                    .lineHeight(20)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
            }

            // 打卡
            Button(this.done ? '✅ 已打卡' : '打卡：我观测到了！')
              .width('90%')
              .height(46)
              .fontSize(16)
              .backgroundColor(this.done ? '#22284E' : '#5B8DEF')
              .fontColor(this.done ? '#9AA3C7' : '#FFFFFF')
              .onClick(() => {
                this.done = !this.done;
                putBoolean(this.prefKey, this.done);
              })
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }

  private observeTip(): string {
    const ill = (1 - Math.cos(2 * Math.PI * this.moonPhase)) / 2;
    const deep = this.target.id.indexOf('m') === 0 || this.target.id === 'doublecluster';
    if (deep) {
      return ill < 0.3 ? '今晚月光干扰小，深空目标观测条件良好。' : '今晚月光较强，深空目标观测效果一般，建议月光弱时再来。';
    }
    return ill < 0.5 ? '今晚月光较弱，适合观测。' : '今晚月光较强，亮星/双星不受影响，尽情观测。';
  }
}

@Component
struct Info {
  @Prop k: string = '';
  @Prop v: string = '';

  build() {
    Column({ space: 2 }) {
      Text(this.k)
        .fontSize(11)
        .fontColor('#9AA3C7')
      Text(this.v)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F2F5FF')
    }
    .alignItems(HorizontalAlign.Center)
  }
}
