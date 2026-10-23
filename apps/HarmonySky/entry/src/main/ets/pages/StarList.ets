import router from '@ohos.router';
import { StarTarget } from '../model/models';
import { starTargets } from '../engine/stardata';
import { getString, putBoolean, getBoolean } from '../utils/prefs';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct StarList {
  @State doneIds: Set<string> = new Set();
  @State filterSeason: string = '全部';
  @State filterDifficulty: number = 0;
  @State targets: StarTarget[] = starTargets;
  private seasons: string[] = ['全部', '春季', '夏季', '秋季', '冬季', '全年'];

  aboutToAppear(): void {
    this.doneIds = new Set();
    for (let i = 0; i < this.targets.length; i++) {
      const id = this.targets[i].id;
      if (getBoolean(`star_done_${id}`, false)) {
        this.doneIds.add(id);
      }
    }
  }

  private isMatched(t: StarTarget): boolean {
    const seasonOk = this.filterSeason === '全部' || t.bestSeason.indexOf(this.filterSeason) >= 0;
    const diffOk = this.filterDifficulty === 0 || t.difficulty === this.filterDifficulty;
    return seasonOk && diffOk;
  }

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Text('观星清单')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F2F5FF')

            Row() {
              Text(`已打卡 ${this.doneIds.size} / ${this.targets.length}`)
                .fontSize(14)
                .fontColor('#F5D76E')
                .layoutWeight(1)
            }
            .width('100%')

            // 进度条
            Progress({ value: this.doneIds.size, total: this.targets.length, type: ProgressType.Linear })
              .width('100%')
              .color('#F5D76E')
              .backgroundColor('#22284E')

            // 筛选
            SkyCard({ title: '筛选' }) {
              Column({ space: 8 }) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.seasons, (s: string) => {
                    Text(s)
                      .fontSize(12)
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .margin(3)
                      .borderRadius(12)
                      .backgroundColor(this.filterSeason === s ? '#5B8DEF' : '#22284E')
                      .fontColor(this.filterSeason === s ? '#FFFFFF' : '#C9D2F2')
                      .onClick(() => {
                        this.filterSeason = s;
                      })
                  }, (s: string) => s)
                }
                .width('100%')

                Row({ space: 8 }) {
                  ForEach([0, 1, 2, 3], (d: number) => {
                    Text(d === 0 ? '全部难度' : '难度'.concat('★'.repeat(d)))
                      .fontSize(12)
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .borderRadius(12)
                      .backgroundColor(this.filterDifficulty === d ? '#5B8DEF' : '#22284E')
                      .fontColor(this.filterDifficulty === d ? '#FFFFFF' : '#C9D2F2')
                      .onClick(() => {
                        this.filterDifficulty = d;
                      })
                  }, (d: number) => d.toString())
                }
                .width('100%')
              }
              .width('100%')
            }

            // 目标列表
            ForEach(this.targets, (t: StarTarget) => {
              if (this.isMatched(t)) {
                SkyCard() {
                  Row({ space: 10 }) {
                    Text(this.doneIds.has(t.id) ? '✅' : (t.difficulty === 1 ? '⭐' : (t.difficulty === 2 ? '🌟' : '💫')))
                      .fontSize(22)
                    Column({ space: 3 }) {
                      Row({ space: 6 }) {
                        Text(t.name)
                          .fontSize(15)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#F2F5FF')
                        Text(`${t.mag === 0 ? '流星雨' : `星等 ${t.mag.toFixed(1)}`}`)
                          .fontSize(11)
                          .fontColor('#9AA3C7')
                      }
                      Text(`${t.constellation} · 最佳季节：${t.bestSeason} · 难度${'★'.repeat(t.difficulty)}`)
                        .fontSize(12)
                        .fontColor('#9AA3C7')
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Button(this.doneIds.has(t.id) ? '已打卡' : '详情')
                      .fontSize(12)
                      .height(30)
                      .backgroundColor(this.doneIds.has(t.id) ? '#22284E' : '#5B8DEF')
                      .fontColor(this.doneIds.has(t.id) ? '#9AA3C7' : '#FFFFFF')
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/StarDetail',
                          params: { id: t.id }
                        });
                      })
                  }
                  .width('100%')
                }
              }
            }, (t: StarTarget) => `${t.id}_${this.doneIds.has(t.id)}_${this.filterSeason}_${this.filterDifficulty}`)
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 3 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }
}
