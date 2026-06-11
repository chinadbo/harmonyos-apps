import { WaterRecord } from '../model/WaterRecord'

@Component
export struct RecordListItem {
  @Prop record: WaterRecord = new WaterRecord()
  @Prop onEdit: (record: WaterRecord) => void = () => {}
  @Prop onDelete: (record: WaterRecord) => void = () => {}

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const hour = `${date.getHours()}`.padStart(2, '0')
    const minute = `${date.getMinutes()}`.padStart(2, '0')
    return `${hour}:${minute}`
  }

  build() {
    Row() {
      Column() {
        Text(`${this.record.amount} ml`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Text(this.formatTime(this.record.timestamp))
          .fontSize(13)
          .fontColor('#888888')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button('编辑')
        .margin({ right: 8 })
        .onClick(() => this.onEdit(this.record))
      Button('删除')
        .backgroundColor('#F56C6C')
        .onClick(() => this.onDelete(this.record))
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
