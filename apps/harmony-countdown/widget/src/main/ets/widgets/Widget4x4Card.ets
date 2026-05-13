let widget4x4Storage = new LocalStorage({
  title: '暂无事件',
  dateText: '去添加第一个纪念日吧',
  countdownText: '开始记录重要日子',
  noteText: 'HarmonyCountdown',
  eventCount: '0'
});

@Entry(widget4x4Storage)
@Component
struct Widget4x4Card {
  @LocalStorageProp('title') title: string = '暂无事件';
  @LocalStorageProp('dateText') dateText: string = '去添加第一个纪念日吧';
  @LocalStorageProp('countdownText') countdownText: string = '开始记录重要日子';
  @LocalStorageProp('noteText') noteText: string = 'HarmonyCountdown';
  @LocalStorageProp('eventCount') eventCount: string = '0';

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('HarmonyCountdown').fontSize(18).fontWeight(FontWeight.Medium).fontColor('#FFFFFF');
        Blank();
        Text(`${this.eventCount} 个事件`).fontSize(14).fontColor('#FFF3F0');
      }
      Text(this.title).fontSize(30).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').maxLines(2);
      Text(this.countdownText).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
      Text(this.dateText).fontSize(16).fontColor('#FFF5F5');
      Blank();
      Text(this.noteText).fontSize(14).fontColor('#FFF3F0').maxLines(2);
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#FF7A66');
  }
}
