/**
 * StatCharts.ets — 统计图表组合（环形图 + 柱状图 + 图例）
 */
import { CategoryStat, ConditionStat } from '../model/StatsModel';
import { RingChart } from './RingChart';
import { BarChart } from './BarChart';
import { C_CARD, C_TEXT, C_SUB, C_LINE, C_BRAND } from '../common/Constants';

@Component
export struct StatCharts {
  @Prop categories: CategoryStat[] = [];
  @Prop conditions: ConditionStat[] = [];
  @Prop totalValueText: string = '';
  @Prop totalCountText: string = '';

  @Builder
  Legend(categories: CategoryStat[]) {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      ForEach(categories, (c: CategoryStat) => {
        Row() {
          Column()
            .width(9)
            .height(9)
            .borderRadius(5)
            .backgroundColor(c.color)
          Text(c.name)
            .fontSize(11)
            .fontColor(C_SUB)
            .margin({ left: 5 })
          Text(' ' + c.count.toString() + '件')
            .fontSize(10)
            .fontColor(C_TEXT)
        }
        .margin({ right: 12, bottom: 8 })
        .alignItems(VerticalAlign.Center)
      }, (c: CategoryStat) => c.key)
    }
    .width('100%')
    .margin({ top: 6 })
  }

  build() {
    Column({ space: 14 }) {
      Column() {
        Row() {
          Text('品类分布')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_TEXT)
          Blank()
          Text(this.totalCountText + ' 件藏品')
            .fontSize(11)
            .fontColor(C_SUB)
        }
        .width('100%')

        RingChart({
          data: this.categories,
          centerTop: this.totalValueText,
          centerBottom: '总估值'
        })

        this.Legend(this.categories)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(C_CARD)
      .borderRadius(18)
      .border({ width: 1, color: C_LINE })

      Column() {
        Row() {
          Text('成色分布')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_TEXT)
          Blank()
          Text('按件数')
            .fontSize(11)
            .fontColor(C_SUB)
        }
        .width('100%')

        BarChart({ data: this.conditions })

        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.conditions, (c: ConditionStat) => {
            Row() {
              Column()
                .width(9)
                .height(9)
                .borderRadius(2)
                .backgroundColor(c.color)
              Text(this.shortName(c.condition))
                .fontSize(11)
                .fontColor(C_SUB)
                .margin({ left: 5 })
            }
            .margin({ right: 12, bottom: 8 })
            .alignItems(VerticalAlign.Center)
          }, (c: ConditionStat) => c.condition)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(C_CARD)
      .borderRadius(18)
      .border({ width: 1, color: C_LINE })
    }
    .width('100%')
  }

  private shortName(condition: string): string {
    return condition;
  }
}
