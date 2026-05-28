let storage = new LocalStorage();

@Entry(storage)
@Component
struct SleepWidgetCard {
  @LocalStorageProp('lastDuration') lastDuration: number = 0;
  @LocalStorageProp('lastQuality') lastQuality: number = 0;
  @LocalStorageProp('weeklyAvg') weeklyAvg: number = 0;

  formatH(minutes: number): string {
    const h = Math.floor(minutes / 60);
    const m = minutes % 60;
    if (h === 0) return `${m}m`;
    if (m === 0) return `${h}h`;
    return `${h}h${m}m`;
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Text('😴')
          .fontSize(16)
        Text(' HarmonySleep')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A2E')
      }
      .alignSelf(ItemAlign.Start)

      Blank()

      Text(this.lastDuration > 0 ? this.formatH(this.lastDuration) : '--')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')

      Text('昨晚睡眠')
        .fontSize(11)
        .fontColor('#888888')

      Blank()

      Row() {
        Text(`本周均：${this.weeklyAvg > 0 ? this.formatH(this.weeklyAvg) : '--'}`)
          .fontSize(11)
          .fontColor('#5B8DEF')
        Blank()
        Text(this.lastQuality > 0 ? '★'.repeat(this.lastQuality) + '☆'.repeat(5 - this.lastQuality) : '未评')
          .fontSize(11)
          .fontColor('#FFD700')
      }
      .width('100%')
    }
    .padding(12)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
