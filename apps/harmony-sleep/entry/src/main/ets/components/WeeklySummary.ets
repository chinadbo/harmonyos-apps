import { SleepRecord, formatDuration } from '../model/SleepRecord';

@Component
export struct WeeklySummary {
  @Prop records: SleepRecord[] = [];
  @Prop targetDuration: number = 480;

  avgDuration(): number {
    if (this.records.length === 0) return 0;
    const total = this.records.reduce((sum, r) => sum + r.duration, 0);
    return Math.round(total / this.records.length);
  }

  maxDuration(): number {
    if (this.records.length === 0) return 0;
    return Math.max(...this.records.map(r => r.duration));
  }

  minDuration(): number {
    if (this.records.length === 0) return 0;
    return Math.min(...this.records.map(r => r.duration));
  }

  reachCount(): number {
    return this.records.filter(r => r.duration >= this.targetDuration).length;
  }

  build() {
    Column({ space: 12 }) {
      Text('本周统计')
        .fontSize(14)
        .fontColor('#888888')
        .alignSelf(ItemAlign.Start)
      Row({ space: 8 }) {
        this.StatItem('平均', formatDuration(this.avgDuration()))
        this.StatItem('最长', formatDuration(this.maxDuration()))
        this.StatItem('最短', formatDuration(this.minDuration()))
        this.StatItem('达标', `${this.reachCount()}天`)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  StatItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')
      Text(label)
        .fontSize(12)
        .fontColor('#AAAAAA')
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }
}
