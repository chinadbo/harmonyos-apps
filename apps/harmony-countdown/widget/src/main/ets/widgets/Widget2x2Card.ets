let widget2x2Storage = new LocalStorage({
  title: '暂无事件',
  dateText: '去添加第一个纪念日吧',
  countdownText: '开始记录重要日子'
});

@Entry(widget2x2Storage)
@Component
struct Widget2x2Card {
  @LocalStorageProp('title') title: string = '暂无事件';
  @LocalStorageProp('dateText') dateText: string = '去添加第一个纪念日吧';
  @LocalStorageProp('countdownText') countdownText: string = '开始记录重要日子';

  build() {
    Column({ space: 8 }) {
      Text('HarmonyCountdown').fontSize(14).fontColor('#FFFFFF').opacity(0.85);
      Text(this.title).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').maxLines(2);
      Text(this.countdownText).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#FFFFFF');
      Text(this.dateText).fontSize(13).fontColor('#FFF5F5').maxLines(1);
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FF5B4D');
  }
}
