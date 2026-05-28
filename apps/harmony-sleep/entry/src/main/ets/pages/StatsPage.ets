import DatabaseService from '../service/DatabaseService';
import { SleepRecord, formatDuration } from '../model/SleepRecord';
import { TrendChart } from '../components/TrendChart';
import { BarChart } from '../components/BarChart';

@Component
export default struct StatsPage {
  @State mode: 'week' | 'month' = 'week';
  @State records: SleepRecord[] = [];
  @State avgDuration: number = 0;
  @State avgQuality: number = 0;
  @State reachCount: number = 0;
  private targetDuration: number = 480;

  async aboutToAppear(): Promise<void> {
    await this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      if (this.mode === 'week') {
        this.records = await DatabaseService.instance().getWeeklyStats();
      } else {
        this.records = await DatabaseService.instance().getMonthlyStats();
      }
      this.calcStats();
    } catch (err) {
      console.error('[StatsPage] loadData error:', JSON.stringify(err));
    }
  }

  calcStats(): void {
    if (this.records.length === 0) {
      this.avgDuration = 0;
      this.avgQuality = 0;
      this.reachCount = 0;
      return;
    }
    const totalDuration = this.records.reduce((s, r) => s + r.duration, 0);
    this.avgDuration = Math.round(totalDuration / this.records.length);
    const rated = this.records.filter(r => r.quality > 0);
    this.avgQuality = rated.length > 0
      ? Math.round(rated.reduce((s, r) => s + r.quality, 0) / rated.length * 10) / 10
      : 0;
    this.reachCount = this.records.filter(r => r.duration >= this.targetDuration).length;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('睡眠统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })

        // 周/月切换
        Row() {
          Button('本周')
            .backgroundColor(this.mode === 'week' ? '#5B8DEF' : '#F0F0F0')
            .fontColor(this.mode === 'week' ? Color.White : '#888888')
            .layoutWeight(1)
            .height(36)
            .borderRadius(18)
            .onClick(() => {
              if (this.mode !== 'week') {
                this.mode = 'week';
                this.loadData();
              }
            })
          Button('本月')
            .backgroundColor(this.mode === 'month' ? '#5B8DEF' : '#F0F0F0')
            .fontColor(this.mode === 'month' ? Color.White : '#888888')
            .layoutWeight(1)
            .height(36)
            .borderRadius(18)
            .onClick(() => {
              if (this.mode !== 'month') {
                this.mode = 'month';
                this.loadData();
              }
            })
        }
        .width('100%')
        .padding({ horizontal: 4 })
        .backgroundColor(Color.White)
        .borderRadius(20)
        .padding(4)

        // 汇总
        Row({ space: 8 }) {
          this.SummaryCard('平均时长', formatDuration(this.avgDuration))
          this.SummaryCard('平均质量', this.avgQuality > 0 ? `${this.avgQuality}★` : '-')
          this.SummaryCard('达标天数', `${this.reachCount}天`)
        }
        .width('100%')

        // 折线图
        TrendChart({
          records: this.records,
          targetHours: this.targetDuration / 60
        })

        // 柱状图
        BarChart({ records: this.records })
      }
      .padding({ horizontal: 16, bottom: 24, top: 12 })
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F8F9FA')
    .width('100%')
    .height('100%')
  }

  @Builder
  SummaryCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')
      Text(label)
        .fontSize(12)
        .fontColor('#AAAAAA')
    }
    .layoutWeight(1)
    .padding({ vertical: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }
}
