import common from '@ohos.app.ability.common';
import { CategoryStat, Database, LearnStats, TrendData } from '../model/Database';
import { CATEGORIES } from '../data/problemset';
import { RingProgress } from '../components/RingProgress';
import { BarChart } from '../components/BarChart';
import { Theme } from '../common/Theme';

/** 学习统计页（作为首页 Tab 内容） */
@Component
export struct StatsView {
  @Prop @Watch('onTick') refreshTick: number = 0;
  @State stats: LearnStats = new LearnStats();
  @State categories: CategoryStat[] = [];
  @State trend: TrendData = new TrendData([], []);
  @State loaded: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  onTick(): void {
    this.load();
  }

  async load(): Promise<void> {
    const db = Database.getInstance();
    await db.init(getContext(this) as common.UIAbilityContext);
    this.stats = await db.getStats();
    this.categories = await db.getCategoryProgress(CATEGORIES);
    this.trend = await db.getLast7DayTrend();
    this.loaded = true;
  }

  ratio(): number {
    if (this.stats.total <= 0) {
      return 0;
    }
    return this.stats.done / this.stats.total;
  }

  percentText(): string {
    return Math.round(this.ratio() * 100).toString() + '%';
  }

  @Builder
  StatTile(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor(Theme.subText)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Theme.card)
    .borderRadius(14)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Scroll() {
      Column() {
        Text('学习统计')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.text)
          .width('100%')
          .padding({ left: 4, top: 4, bottom: 14 })

        // 总进度环形图
        Column() {
          Row() {
            RingProgress({
              progress: this.ratio(),
              ringSize: 132,
              strokeWidth: 13,
              centerText: this.percentText(),
              centerSub: '已完成 ' + this.stats.done + '/' + this.stats.total
            })
            Column() {
              Text('总体完成度')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.text)
              Text('坚持刷题，稳步提升')
                .fontSize(12)
                .fontColor(Theme.subText)
                .margin({ top: 6 })
              Text('已掌握 ' + this.stats.mastered + ' 道')
                .fontSize(12)
                .fontColor(Theme.success)
                .margin({ top: 14 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 16 })
          }
          .width('100%')
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(16)

        // 四项统计
        Row({ space: 12 }) {
          this.StatTile(this.stats.done.toString(), '已做题目', Theme.primary)
          this.StatTile(this.stats.mastered.toString(), '已掌握', Theme.success)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          this.StatTile(this.stats.favorites.toString(), '收藏题目', Theme.star)
          this.StatTile(this.stats.wrong.toString(), '待巩固', Theme.danger)
        }
        .width('100%')
        .margin({ top: 12 })

        // 近 7 日趋势
        Column() {
          Text('近 7 日刷题趋势')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.text)
            .width('100%')
            .margin({ bottom: 10 })
          BarChart({ labels: this.trend.labels, values: this.trend.values, chartHeight: 180 })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(16)
        .margin({ top: 12 })

        // 分类进度
        Column() {
          Text('分类进度')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.text)
            .width('100%')
            .margin({ bottom: 14 })
          ForEach(this.categories, (cat: CategoryStat) => {
            Column() {
              Row() {
                Text(cat.category)
                  .fontSize(13)
                  .fontColor(Theme.text)
                Blank()
                Text(cat.done + '/' + cat.total)
                  .fontSize(12)
                  .fontColor(Theme.subText)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Progress({
                value: cat.done,
                total: cat.total > 0 ? cat.total : 1,
                type: ProgressType.Linear
              })
                .color(Theme.primary)
                .backgroundColor('#EEF1F7')
                .width('100%')
                .height(6)
            }
            .width('100%')
            .margin({ bottom: 16 })
          }, (cat: CategoryStat) => cat.category)
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.card)
        .borderRadius(16)
        .margin({ top: 12, bottom: 20 })

        // 隐私政策入口
        Text($r('app.string.privacy_agreement'))
          .fontSize(13)
          .fontColor(Theme.subText)
          .width('100%')
          .textAlign(TextAlign.Center)
          .decoration({ type: TextDecorationType.Underline, color: Theme.subText })
          .padding({ top: 4, bottom: 16 })
          .onClick(() => {
            AlertDialog.show({
              title: $r('app.string.privacy_statement_title'),
              message: $r('app.string.privacy_statement_content'),
              confirm: {
                value: $r('app.string.protocol_and_privacy'),
                action: () => {
                }
              }
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(Theme.bg)
  }
}
