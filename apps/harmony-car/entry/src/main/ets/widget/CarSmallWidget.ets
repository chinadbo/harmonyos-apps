@Entry
@Component
export struct CarSmallWidget {
  @StorageLink('plateNumber') plateNumber: string = '未设置车辆';
  @StorageLink('modelName') modelName: string = '';
  @StorageLink('mileageText') mileageText: string = '0 km';
  @StorageLink('nextReminderText') nextReminderText: string = '暂无提醒';

  build() {
    Column({ space: 8 }) {
      Text(this.plateNumber)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.modelName)
        .fontSize(13)
        .fontColor('#DDE7FF')
        .width('100%')
        .textAlign(TextAlign.Start)
      Divider()
        .strokeWidth(1)
        .color('#6687F7')
      Text(this.mileageText)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Text(this.nextReminderText)
        .fontSize(12)
        .fontColor('#DDE7FF')
        .maxLines(2)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#4E7BF2')
    .borderRadius(24)
  }
}
