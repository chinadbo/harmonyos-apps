import { SpeedRecord } from '../model/SpeedRecord'
import { speedDb } from '../database/SpeedDatabase'
import { LineChartCanvas } from '../components/LineChartCanvas'

@Component
export struct HistoryView {
  @State records: SpeedRecord[] = []

  async aboutToAppear() {
    this.records = await speedDb.queryRecords(20)
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp)
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hour = String(date.getHours()).padStart(2, '0')
    const min = String(date.getMinutes()).padStart(2, '0')
    return `${month}/${day} ${hour}:${min}`
  }

  build() {
    Column({ space: 0 }) {
      // Header
      Text('历史记录')
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: 16, left: 16, right: 16, bottom: 12 })

      // Chart
      LineChartCanvas({ records: this.records })
        .margin({ left: 16, right: 16, bottom: 12 })

      // Refresh button
      Row() {
        Button('刷新')
          .fontSize(13)
          .height(32)
          .backgroundColor('#2196F3')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .onClick(async () => {
            this.records = await speedDb.queryRecords(20)
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ right: 16, bottom: 8 })

      // Record list
      if (this.records.length === 0) {
        Column() {
          Text('暂无测速记录')
            .fontSize(16)
            .fontColor('#9E9E9E')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List() {
          ForEach(this.records, (record: SpeedRecord) => {
            ListItem() {
              Row() {
                Column() {
                  Text(this.formatTime(record.timestamp))
                    .fontSize(13)
                    .fontColor('#9E9E9E')
                  Text(record.networkType)
                    .fontSize(11)
                    .fontColor('#666677')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Column() {
                  Text(`↓ ${record.downloadSpeed.toFixed(1)} Mbps`)
                    .fontSize(14)
                    .fontColor('#2196F3')
                  Text(`↑ ${record.uploadSpeed.toFixed(1)} Mbps`)
                    .fontSize(14)
                    .fontColor('#FF9800')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.End)
                .margin({ right: 12 })

                Column() {
                  Text(`${record.ping} ms`)
                    .fontSize(13)
                    .fontColor('#4CAF50')
                  Text('Ping')
                    .fontSize(11)
                    .fontColor('#9E9E9E')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Center)
                .width(50)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor('#1E1E2E')
            }
            .margin({ bottom: 1 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: '#2A2A3E' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#12121E')
  }
}
