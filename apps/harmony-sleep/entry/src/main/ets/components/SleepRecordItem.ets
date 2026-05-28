import { SleepRecord, formatDuration, formatTime, formatDate } from '../model/SleepRecord';

@Component
export struct SleepRecordItem {
  @Prop record: SleepRecord = {
    id: 0, sleepTime: 0, wakeTime: 0, duration: 0, quality: 0, note: '', createdAt: 0
  };

  qualityColor(q: number): string {
    if (q >= 4) return '#4CAF50';
    if (q >= 3) return '#FF9800';
    if (q >= 1) return '#F44336';
    return '#BBBBBB';
  }

  qualityText(q: number): string {
    const stars = ['未评', '差', '一般', '良好', '很好', '极好'];
    return stars[Math.min(q, 5)];
  }

  build() {
    Row() {
      // 日期列
      Column() {
        Text(formatDate(this.record.sleepTime))
          .fontSize(13)
          .fontColor('#888888')
        Text(formatTime(this.record.sleepTime) + ' - ' + formatTime(this.record.wakeTime))
          .fontSize(12)
          .fontColor('#AAAAAA')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('45%')

      // 时长
      Text(formatDuration(this.record.duration))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A2E')
        .width('30%')
        .textAlign(TextAlign.Center)

      // 质量
      Row() {
        Text(this.qualityText(this.record.quality))
          .fontSize(12)
          .fontColor(this.qualityColor(this.record.quality))
          .padding({ horizontal: 8, vertical: 2 })
          .borderRadius(10)
          .backgroundColor(this.qualityColor(this.record.quality) + '20')
      }
      .width('25%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding({ horizontal: 16, vertical: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
