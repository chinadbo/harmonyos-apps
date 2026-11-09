import common from '@ohos.app.ability.common';
import { GachaRecord, GachaPool, PoolShare, STAR_GOLD } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { goldHistogram, luckIndex, luckLabel, luckDescription, avgGoldPulls, pityConfigOf, EXPECTED_GOLD_PULLS } from '../engine/PityEngine';
import { colorsOf } from '../common/Theme';
import { GoldChart } from '../components/GoldChart';
import { LuckCurve } from '../components/LuckCurve';
import { NavBar } from '../components/NavBar';
import { clampN } from '../common/Format';

@Entry
@Component
struct StatsPage {
  @StorageLink("gachaTheme") themeNum: number = 0;
  @StorageLink("refreshFlag") @Watch('onRefresh') refreshFlag: number = 0;
  @State records: GachaRecord[] = [];
  @State pools: GachaPool[] = [];
  @State bins: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  @State shares: PoolShare[] = [];
  @State luck: number = -1;
  @State avgPulls: number = 0;
  @State goldTotal: number = 0;
  @State curveHard: number = 90;
  @State curveSoft: number = 74;
  @State chartW: number = 340;
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
      const records = await db.getAllRecords();
      const pools = await db.getPools();
      this.records = records;
      this.pools = pools;
      this.bins = goldHistogram(records);
      this.luck = luckIndex(records);
      this.avgPulls = Math.round(avgGoldPulls(records) * 10) / 10;

      let goldTotal = 0;
      for (const r of records) {
        if (r.star === STAR_GOLD) {
          goldTotal++;
        }
      }
      this.goldTotal = goldTotal;

      const shares: PoolShare[] = [];
      for (const p of pools) {
        let goldCount = 0;
        let totalCount = 0;
        for (const r of records) {
          if (r.poolId === p.id) {
            totalCount++;
            if (r.star === STAR_GOLD) {
              goldCount++;
            }
          }
        }
        if (goldCount > 0) {
          const s = new PoolShare();
          s.poolId = p.id;
          s.name = p.name;
          s.goldCount = goldCount;
          s.totalCount = totalCount;
          s.percent = goldTotal > 0 ? goldCount / goldTotal * 100 : 0;
          shares.push(s);
        }
      }
      this.shares = shares;

      let cfgHard = 90;
      let cfgSoft = 74;
      for (const p of pools) {
        if (p.isCurrent) {
          const cfg = pityConfigOf(p.poolType);
          cfgHard = cfg.hardPity;
          cfgSoft = cfg.softStart;
          break;
        }
      }
      this.curveHard = cfgHard;
      this.curveSoft = cfgSoft;
      this.loadError = '';
    } catch (e) {
      this.loadError = '数据加载失败，请重试';
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Text('统计分析')
            .fontSize(20)
            .fontWeight(800)
            .fontColor(colorsOf(this.themeNum).textMain)
            .width('100%')
            .padding({ top: 14, left: 16, right: 16 })

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
              Text('出金抽数分布')
                .fontSize(15)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).textMain)
              Blank()
              Text(`出金 ${this.goldTotal} 次`)
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
            }
            .width('100%')

            GoldChart({
              data: this.bins,
              chartW: this.chartW,
              chartH: 200,
              goldColor: colorsOf(this.themeNum).gold,
              primaryColor: colorsOf(this.themeNum).primary,
              cardColor: colorsOf(this.themeNum).card,
              border: colorsOf(this.themeNum).border,
              textSub: colorsOf(this.themeNum).textSub
            })
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('累计出金概率曲线')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')
            Text('基于概率模型：基础 0.6%，软保底起每抽 +6%，硬保底必出')
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')

            LuckCurve({
              hardPity: this.curveHard,
              softStart: this.curveSoft,
              expected: EXPECTED_GOLD_PULLS,
              primaryColor: colorsOf(this.themeNum).primary,
              goldColor: colorsOf(this.themeNum).gold,
              border: colorsOf(this.themeNum).border,
              textSub: colorsOf(this.themeNum).textSub,
              chartW: this.chartW,
              chartH: 200
            })
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('各池出金占比')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')

            if (this.shares.length === 0) {
              Text('暂无出金记录')
                .fontSize(12)
                .fontColor(colorsOf(this.themeNum).textSub)
                .width('100%')
            } else {
              ForEach(this.shares, (s: PoolShare) => {
                Column({ space: 6 }) {
                  Row() {
                    Text(s.name)
                      .fontSize(12)
                      .fontColor(colorsOf(this.themeNum).textMain)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                    Text(`${s.goldCount} 金 / ${s.percent.toFixed(0)}%`)
                      .fontSize(11)
                      .fontColor(colorsOf(this.themeNum).textSub)
                  }
                  .width('100%')

                  Stack({ alignContent: Alignment.Start }) {
                    Row()
                      .width('100%')
                      .height(8)
                      .borderRadius(4)
                      .backgroundColor(colorsOf(this.themeNum).track)
                    Row()
                      .width(`${clampN(s.percent, 2, 100)}%`)
                      .height(8)
                      .borderRadius(4)
                      .linearGradient({
                        angle: 90,
                        colors: [[colorsOf(this.themeNum).primary, 0], [colorsOf(this.themeNum).gold, 1]]
                      })
                  }
                  .width('100%')
                  .borderRadius(4)
                  .clip(true)
                }
                .width('100%')
              }, (s: PoolShare) => `share-${s.poolId}`)
            }
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Row() {
              Text('欧非指数')
                .fontSize(15)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).textMain)
              Blank()
              Text(this.luck < 0 ? '--' : `${this.luck}`)
                .fontSize(26)
                .fontWeight(800)
                .fontColor(colorsOf(this.themeNum).gold)
            }
            .width('100%')

            Row({ space: 8 }) {
              Text(luckLabel(this.luck))
                .fontSize(12)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(8)
                .backgroundColor(colorsOf(this.themeNum).gold)
              Text(luckDescription(this.luck))
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
                .layoutWeight(1)
            }
            .width('100%')

            Divider().color(colorsOf(this.themeNum).border).opacity(0.5)

            Column({ space: 6 }) {
              Text('指数说明')
                .fontSize(12)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).textMain)
              Text(`欧非指数 = 出金均抽数与期望（${EXPECTED_GOLD_PULLS} 抽）比值的映射，范围 0-100：`)
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
              Text(`· 出金均抽数 = ${this.avgPulls > 0 ? this.avgPulls : '暂无'}，期望为 ${EXPECTED_GOLD_PULLS}`)
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
              Text('· 均抽数低于期望（出得快）→ 指数高于 50，偏欧皇')
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
              Text('· 均抽数高于期望（出得慢）→ 指数低于 50，偏非酋')
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
              Text('· 75+ 欧皇 / 55+ 小欧 / 45-55 平稳 / 25+ 小非 / <25 非酋')
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16, bottom: 20 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')

      NavBar({ active: 3 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }
}
