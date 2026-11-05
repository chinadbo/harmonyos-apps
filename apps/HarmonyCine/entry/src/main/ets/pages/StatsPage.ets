/**
 * StatsPage：观影统计页。
 * 总数卡片（在看/想看/看过/总数）+ 平均分 + 类型分布环形图（已看完）+ 近 6 月柱状图。
 */
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import {
  TabCounts,
  RingSegment,
  BarItem,
  emptyCounts
} from '../model/Movie';
import { dbReady } from '../data/DbService';
import {
  getCounts,
  getCategorySegments,
  getAverageRating,
  getMonthlyBars
} from '../data/MovieRepository';
import { RatingStars } from '../components/RatingStars';
import { StatRingChart } from '../components/StatRingChart';
import { StatBarChart } from '../components/StatBarChart';

const MONTH_COUNT: number = 6;

@Entry
@Component
struct StatsPage {
  @State counts: TabCounts = emptyCounts();
  @State avgRating: number = 0;
  @State segments: RingSegment[] = [];
  @State bars: BarItem[] = [];
  @State loaded: boolean = false;

  private async load(): Promise<void> {
    try {
      this.counts = await getCounts();
      this.segments = await getCategorySegments();
      this.avgRating = await getAverageRating();
      this.bars = await getMonthlyBars(MONTH_COUNT);
      this.loaded = true;
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] stats load failed, code=${e.code} message=${e.message}`);
    }
  }

  async aboutToAppear(): Promise<void> {
    await dbReady();
    await this.load();
  }

  onPageShow(): void {
    if (this.loaded) {
      this.load();
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#22242E')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('观影统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#22242E')
      }
      .width('100%')
      .padding({ left: 16, top: 14, bottom: 12 })
      .alignItems(VerticalAlign.Center)

      if (!this.loaded) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#8A8F9E')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 总数四宫格
            Row({ space: 10 }) {
              Column({ space: 6 }) {
                Text(`${this.counts.total}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#3D5AFE')
                Text('片单总数')
                  .fontSize(11)
                  .fontColor('#8A8F9E')
              }
              .layoutWeight(1)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
              .borderRadius(14)

              Column({ space: 6 }) {
                Text(`${this.counts.watching}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F39C12')
                Text('在看')
                  .fontSize(11)
                  .fontColor('#8A8F9E')
              }
              .layoutWeight(1)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
            }
            .width('100%')
            .margin({ left: 16, right: 16 })

            Row({ space: 10 }) {
              Column({ space: 6 }) {
                Text(`${this.counts.wish}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#74B9FF')
                Text('想看')
                  .fontSize(11)
                  .fontColor('#8A8F9E')
              }
              .layoutWeight(1)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
              .borderRadius(14)

              Column({ space: 6 }) {
                Text(`${this.counts.watched}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#00B894')
                Text('看过')
                  .fontSize(11)
                  .fontColor('#8A8F9E')
              }
              .layoutWeight(1)
              .padding({ top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
            }
            .width('100%')
            .margin({ left: 16, right: 16, top: 10 })

            // 平均分
            Column({ space: 10 }) {
              Text('已看平均分')
                .fontSize(14)
                .fontColor('#666A78')
                .width('100%')
              Row({ space: 12 }) {
                Text(this.avgRating > 0 ? this.avgRating.toFixed(1) : '—')
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F5A623')
                RatingStars({
                  rating: this.avgRating,
                  starSize: 18,
                  showValue: false
                })
              }
              .alignItems(VerticalAlign.Center)
              Text('看过状态且已评分（rating > 0）的条目参与均分')
                .fontSize(11)
                .fontColor('#A0A5B4')
            }
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ left: 16, right: 16, top: 14 })
            .width('100%')

            // 类型分布环形图
            Column({ space: 14 }) {
              Text('类型分布（已看完）')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#444652')
                .width('100%')
              StatRingChart({
                segments: this.segments,
                chartSize: 200,
                centerLabel: '看过'
              })
            }
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ left: 16, right: 16, top: 14 })
            .width('100%')

            // 近 6 月柱状图
            Column({ space: 8 }) {
              Text(`近 ${MONTH_COUNT} 个月观影`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#444652')
                .width('100%')
              StatBarChart({
                items: this.bars,
                chartWidth: 300,
                chartHeight: 180
              })
            }
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ left: 16, right: 16, top: 14, bottom: 30 })
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F4F8')
  }
}
