import { StatisticsViewModel } from '../viewmodel/StatisticsViewModel';
import { DailyTrendPoint, PieChartItem } from '../data/DataModels';
import { LineChart } from '../components/LineChart';
import { PieChart } from '../components/PieChart';
import { FormatUtils } from '../utils/FormatUtils';

@Entry
@Component
struct Statistics {
  private viewModel: StatisticsViewModel = new StatisticsViewModel();
  @State trendPoints: DailyTrendPoint[] = [];
  @State pieItems: PieChartItem[] = [];
  @State currency: string = '¥';

  async aboutToAppear(): Promise<void> {
    await this.viewModel.load();
    this.trendPoints = this.viewModel.trendPoints;
    this.pieItems = this.viewModel.pieItems;
    this.currency = this.viewModel.currency;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('统计分析')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 12 }) {
          Text('近 30 天收支趋势')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          LineChart({ points: this.trendPoints })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)

        Column({ space: 12 }) {
          Text('本月分类支出占比')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
          PieChart({ items: this.pieItems })
          ForEach(this.pieItems, (item: PieChartItem) => {
            Row() {
              Row() {
                Row()
                  .width(12)
                  .height(12)
                  .backgroundColor(item.color)
                  .borderRadius(6)
                Text(item.label)
                  .fontSize(14)
                  .margin({ left: 8 })
              }
              .layoutWeight(1)
              Text(FormatUtils.formatAmount(item.amount, this.currency))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
            }
            .padding({ top: 6, bottom: 6 })
          }, (item: PieChartItem) => `${item.categoryId}`)
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(24)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F6F7FB')
  }
}
