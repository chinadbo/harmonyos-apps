/**
 * StatsView.ets — 统计 Tab（概览卡片 + Canvas 图表 + 高价值藏品）
 */
import { StatsService } from '../service/StatsService';
import { StatsResult, CategoryStat, ConditionStat } from '../model/StatsModel';
import { SummaryCard } from '../components/SummaryCard';
import { StatCharts } from '../components/StatCharts';
import { EmptyView } from '../components/EmptyView';
import { Db } from '../model/Db';
import { Format } from '../common/Format';
import {
  C_TEXT, C_SUB, C_BG, C_BRAND, C_CARD, C_LINE, C_SUCCESS, C_DANGER
} from '../common/Constants';

@Component
export struct StatsView {
  @StorageProp('refreshTick') @Watch('onRefresh') refreshTick: number = 0;
  @Prop showTopBar: boolean = true;

  @State stats: StatsResult = new StatsResult();
  @State loading: boolean = true;
  @State loaded: boolean = false;
  @State reqSeq: number = 0;

  aboutToAppear(): void {
    this.reload();
  }

  onRefresh(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    this.reqSeq++;
    const seq: number = this.reqSeq;
    this.loading = this.stats.summary.count === 0;
    try {
      if (!Db.isReady()) {
        await Db.waitReady(4000);
      }
      const result: StatsResult = await StatsService.build();
      if (seq === this.reqSeq) {
        this.stats = result;
        this.loading = false;
        this.loaded = true;
      }
    } catch (err) {
      if (seq === this.reqSeq) {
        this.loading = false;
        this.loaded = true;
      }
    }
  }

  private gainColor(): string {
    if (this.stats.summary.gain > 0) {
      return C_SUCCESS;
    }
    if (this.stats.summary.gain < 0) {
      return C_DANGER;
    }
    return C_SUB;
  }

  private gainHint(): string {
    const rate: number = this.stats.summary.gainRate();
    const sign: string = rate > 0 ? '+' : '';
    return sign + (rate * 100).toFixed(1) + '%';
  }

  @Builder
  TopBar() {
    Row() {
      Column() {
        Text('统计')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(C_TEXT)
        Text('收藏资产一览')
          .fontSize(12)
          .fontColor(C_SUB)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('↻')
        .fontSize(20)
        .fontColor(C_TEXT)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .backgroundColor(C_CARD)
        .border({ width: 1, color: C_LINE })
        .onClick(() => { this.reload(); })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 8 })
  }

  @Builder
  SummaryBlock() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        SummaryCard({
          label: '藏品数量',
          value: this.stats.summary.count.toString() + ' 件',
          hint: '含图片 ' + this.stats.summary.imageCount.toString() + ' 件',
          accent: C_BRAND
        })
        SummaryCard({
          label: '总投入',
          value: Format.money(this.stats.summary.totalCost),
          hint: '入手价合计',
          accent: '#4F6D7A'
        })
      }
      .width('100%')

      Row({ space: 12 }) {
        SummaryCard({
          label: '总估值',
          value: Format.money(this.stats.summary.totalValue),
          hint: '当前市场估价',
          accent: '#C9A227'
        })
        SummaryCard({
          label: '浮动盈亏',
          value: Format.money(this.stats.summary.gain),
          hint: this.gainHint(),
          accent: this.gainColor()
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  TopItemsCard() {
    Column() {
      Text('高价值藏品')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(C_TEXT)
        .width('100%')

      ForEach(this.stats.topItems, (name: string, index: number) => {
        Row() {
          Text((index + 1).toString())
            .fontSize(12)
            .fontColor(0xFFFFFF)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .borderRadius(10)
            .backgroundColor(index === 0 ? C_BRAND : C_SUB)
          Text(name)
            .fontSize(14)
            .fontColor(C_TEXT)
            .margin({ left: 10 })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .margin({ top: 10 })
        .alignItems(VerticalAlign.Center)
      }, (name: string, index: number) => name + index.toString())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(C_CARD)
    .borderRadius(18)
    .border({ width: 1, color: C_LINE })
  }

  build() {
    Column() {
      if (this.showTopBar) {
        this.TopBar()
      }

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(C_BRAND)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.loaded && this.stats.summary.count === 0) {
        EmptyView({
          icon: '▤',
          title: '还没有统计数据',
          subtitle: '添加藏品后即可查看品类分布与成色构成'
        })
      } else {
        Scroll() {
          Column({ space: 14 }) {
            this.SummaryBlock()
            StatCharts({
              categories: this.stats.categories,
              conditions: this.stats.conditions,
              totalValueText: '¥' + Format.moneyShort(this.stats.summary.totalValue),
              totalCountText: this.stats.summary.count.toString()
            })
            if (this.stats.topItems.length > 0) {
              this.TopItemsCard()
            }
            Column().height(20)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
