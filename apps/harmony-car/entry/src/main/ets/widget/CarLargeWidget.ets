@Entry
@Component
export struct CarLargeWidget {
  @StorageLink('plateNumber') plateNumber: string = '未设置车辆';
  @StorageLink('modelName') modelName: string = '';
  @StorageLink('mileageText') mileageText: string = '0 km';
  @StorageLink('nextReminderText') nextReminderText: string = '暂无提醒';
  @StorageLink('totalCostText') totalCostText: string = '¥0.00';
  @StorageLink('lastRecordText') lastRecordText: string = '暂无记录';
  @StorageLink('reminderCountText') reminderCountText: string = '0 个启用提醒';

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.plateNumber)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(this.modelName)
            .fontSize(14)
            .fontColor('#DDE7FF')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        Text(this.totalCostText)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('当前里程')
            .fontSize(12)
            .fontColor('#DDE7FF')
          Text(this.mileageText)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
        Column({ space: 6 }) {
          Text('启用提醒')
            .fontSize(12)
            .fontColor('#DDE7FF')
          Text(this.reminderCountText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
      }
      .width('100%')
      Divider()
        .strokeWidth(1)
        .color('#6687F7')
      Text(`最近记录：${this.lastRecordText}`)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(`最近提醒：${this.nextReminderText}`)
        .fontSize(13)
        .fontColor('#DDE7FF')
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#4E7BF2')
    .borderRadius(24)
  }
}
