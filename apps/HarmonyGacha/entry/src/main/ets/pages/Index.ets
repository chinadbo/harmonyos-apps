import common from '@ohos.app.ability.common';
import { GachaRecord, GachaPool, STAR_GOLD, STAR_PURPLE } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { computePity, pityConfigOf, luckIndex, luckLabel, luckDescription, avgGoldPulls } from '../engine/PityEngine';
import { colorsOf } from '../common/Theme';
import { NumberRoll } from '../components/NumberRoll';
import { PityBar } from '../components/PityBar';
import { RecordCard } from '../components/RecordCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct Index {
  @StorageLink("gachaTheme") themeNum: number = 0;
  @StorageLink("refreshFlag") @Watch('onRefresh') refreshFlag: number = 0;
  @State records: GachaRecord[] = [];
  @State pools: GachaPool[] = [];
  @State total: number = 0;
  @State goldCount: number = 0;
  @State purpleCount: number = 0;
  @State luck: number = -1;
  @State avgPulls: number = 0;
  @State loaded: boolean = false;
  @State dbMode: string = '';
  @State loadError: string = '';

  aboutToAppear(): void {
    this.reload();
  }

  onPageShow(): void {
    this.reload();
  }

  private onRefresh(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      this.dbMode = db.isMemoryMode() ? '内存模式（数据库不可用，数据不持久）' : '';
      const records = await db.getAllRecords();
      const pools = await db.getPools();
      this.records = records;
      this.pools = pools;
      this.total = records.length;
      let gold = 0;
      let purple = 0;
      for (const r of records) {
        if (r.star === STAR_GOLD) {
          gold++;
        } else if (r.star === STAR_PURPLE) {
          purple++;
        }
      }
      this.goldCount = gold;
      this.purpleCount = purple;
      this.luck = luckIndex(records);
      this.avgPulls = Math.round(avgGoldPulls(records));
      this.loadError = '';
    } catch (e) {
      this.loadError = '数据加载失败，请重试';
    }
    this.loaded = true;
  }

  private poolNameOf(poolId: number): string {
    for (const p of this.pools) {
      if (p.id === poolId) {
        return p.name;
      }
    }
    return '未知卡池';
  }

  private recentGolds(): GachaRecord[] {
    const golds = this.records.filter((r: GachaRecord) => r.star === STAR_GOLD);
    golds.sort((a: GachaRecord, b: GachaRecord) => b.createdAt - a.createdAt);
    return golds.slice(0, 5);
  }

  private pityOf(pool: GachaPool): number {
    return computePity(this.records, pool.id);
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Row() {
            Column({ space: 2 }) {
              Text('HarmonyGacha')
                .fontSize(22)
                .fontWeight(800)
                .fontColor(colorsOf(this.themeNum).textMain)
              Text('抽卡记录助手')
                .fontSize(12)
                .fontColor(colorsOf(this.themeNum).textSub)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(`${this.luck < 0 ? '--' : this.luck}`)
              .fontSize(18)
              .fontWeight(800)
              .fontColor(colorsOf(this.themeNum).primary)
            Text(luckLabel(this.luck))
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(6)
              .backgroundColor(colorsOf(this.themeNum).cardDeep)
          }
          .width('100%')
          .padding({ top: 14, left: 16, right: 16 })

          Column({ space: 12 }) {
            Row({ space: 16 }) {
              Column({ space: 2 }) {
                NumberRoll({ value: this.total, fontSize: 40, color: colorsOf(this.themeNum).textMain })
                Text('总抽数')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.Start)

              Divider()
                .vertical(true)
                .height(44)
                .color(colorsOf(this.themeNum).border)

              Row({ space: 16 }) {
                Column({ space: 2 }) {
                  NumberRoll({ value: this.goldCount, fontSize: 26, color: colorsOf(this.themeNum).gold })
                  Text('出金')
                    .fontSize(11)
                    .fontColor(colorsOf(this.themeNum).textSub)
                }
                Column({ space: 2 }) {
                  NumberRoll({ value: this.purpleCount, fontSize: 26, color: colorsOf(this.themeNum).purple })
                  Text('紫卡')
                    .fontSize(11)
                    .fontColor(colorsOf(this.themeNum).textSub)
                }
              }
            }
            .width('100%')

            Divider().color(colorsOf(this.themeNum).border).opacity(0.6)

            Row() {
              Column({ space: 2 }) {
                Text(`${this.luck < 0 ? '--' : this.luck}`)
                  .fontSize(30)
                  .fontWeight(800)
                  .fontColor(colorsOf(this.themeNum).gold)
                Text('欧非指数')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text(luckLabel(this.luck))
                  .fontSize(16)
                  .fontWeight(700)
                  .fontColor(colorsOf(this.themeNum).textMain)
                Text(`${this.luck < 0 ? '暂无出金' : `出金均抽数 ${this.avgPulls} / 期望 62`}`)
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            Text(luckDescription(this.luck))
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')
          }
          .padding(16)
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [[colorsOf(this.themeNum).cardDeep, 0], [colorsOf(this.themeNum).card, 1]]
          })
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })

          if (this.dbMode.length > 0) {
            Text(this.dbMode)
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).danger)
              .margin({ left: 16, right: 16 })
          }

          if (this.loadError.length > 0) {
            Row({ space: 10 }) {
              Text(this.loadError)
                .fontSize(12)
                .fontColor(colorsOf(this.themeNum).danger)
                .layoutWeight(1)
              Text('重试')
                .fontSize(12)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .borderRadius(10)
                .backgroundColor(colorsOf(this.themeNum).primary)
                .onClick(() => {
                  this.reload();
                })
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .backgroundColor(colorsOf(this.themeNum).card)
            .border({ width: 1, color: colorsOf(this.themeNum).danger })
            .margin({ left: 16, right: 16 })
          }

          Column({ space: 10 }) {
            Row() {
              Text('当前保底进度')
                .fontSize(15)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).textMain)
              Blank()
              Text('软保底区间已高亮')
                .fontSize(10)
                .fontColor(colorsOf(this.themeNum).textSub)
            }
            .width('100%')

            ForEach(this.pools, (pool: GachaPool) => {
              PityBar({
                poolName: pool.name,
                pity: this.pityOf(pool),
                hardPity: pityConfigOf(pool.poolType).hardPity,
                softStart: pityConfigOf(pool.poolType).softStart,
                isCurrent: pool.isCurrent,
                cardColor: colorsOf(this.themeNum).card,
                border: colorsOf(this.themeNum).border,
                trackColor: colorsOf(this.themeNum).track,
                goldColor: colorsOf(this.themeNum).gold,
                primaryColor: colorsOf(this.themeNum).primary,
                textMain: colorsOf(this.themeNum).textMain,
                textSub: colorsOf(this.themeNum).textSub
              })
            }, (pool: GachaPool) => `pool-${pool.id}`)
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('最近出金')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')

            if (this.recentGolds().length === 0) {
              Text('还没有出金记录')
                .fontSize(12)
                .fontColor(colorsOf(this.themeNum).textSub)
                .width('100%')
            } else {
              ForEach(this.recentGolds(), (rec: GachaRecord) => {
                RecordCard({
                  itemName: rec.itemName,
                  star: rec.star,
                  poolName: this.poolNameOf(rec.poolId),
                  dateStr: rec.recordDate,
                  pullNo: rec.pullNo,
                  goldColor: colorsOf(this.themeNum).gold,
                  purpleColor: colorsOf(this.themeNum).purple,
                  blueColor: colorsOf(this.themeNum).blue,
                  cardColor: colorsOf(this.themeNum).cardDeep,
                  border: colorsOf(this.themeNum).border,
                  textMain: colorsOf(this.themeNum).textMain,
                  textSub: colorsOf(this.themeNum).textSub
                })
              }, (rec: GachaRecord) => `gold-${rec.id}`)
            }
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16, bottom: 20 })
          .alignItems(HorizontalAlign.Start)

          if (!this.loaded) {
            Text('加载中...')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')

      NavBar({ active: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }
}
