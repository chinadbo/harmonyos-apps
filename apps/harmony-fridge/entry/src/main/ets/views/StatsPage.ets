import { CategoryStat } from '../model/FoodItem';
import { FoodItemDao } from '../database/FoodItemDao';
import { BarChart } from '../components/BarChart';
import { EmptyView } from '../components/EmptyView';

@Component
export struct StatsPage {
  @State stats: CategoryStat[] = [];
  private foodItemDao: FoodItemDao = new FoodItemDao();

  aboutToAppear(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    this.stats = await this.foodItemDao.getCategoryStats();
  }

  private totalCount(): number {
    return this.stats.reduce((sum: number, item: CategoryStat) => sum + item.count, 0);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('食材统计')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20331E')
          .width('100%')
          .textAlign(TextAlign.Start)
        if (this.totalCount() === 0) {
          EmptyView({ title: '暂无统计数据', message: '添加食材后即可查看各分类数量分布' })
        } else {
          Column({ space: 12 }) {
            Text(`当前共记录 ${this.totalCount()} 项食材`)
              .fontSize(15)
              .fontColor('#4A6247')
              .width('100%')
              .textAlign(TextAlign.Start)
            BarChart({ data: this.stats })
            Column({ space: 8 }) {
              ForEach(this.stats, (item: CategoryStat) => {
                Row() {
                  Text(item.category)
                    .fontSize(14)
                    .fontColor('#294328')
                  Blank()
                  Text(`${item.count} 项`)
                    .fontSize(14)
                    .fontColor('#678064')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
              }, (item: CategoryStat) => item.category)
            }
          }
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8F4')
  }
}
