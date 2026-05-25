let storage = new LocalStorage()

@Entry(storage)
@Component
struct WidgetCard {
  @LocalStorageProp('downloadSpeed') downloadSpeed: string = '0.0'
  @LocalStorageProp('uploadSpeed') uploadSpeed: string = '0.0'
  @LocalStorageProp('ping') ping: string = '0'

  build() {
    Column({ space: 8 }) {
      Text('HarmonySpeed')
        .fontSize(14)
        .fontColor('#9E9E9E')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Center)

      Column({ space: 4 }) {
        Row() {
          Text('↓')
            .fontSize(16)
            .fontColor('#2196F3')
            .margin({ right: 4 })
          Text(`${this.downloadSpeed}`)
            .fontSize(22)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
          Text(' Mbps')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .alignItems(VerticalAlign.Bottom)

        Row() {
          Text('↑')
            .fontSize(16)
            .fontColor('#FF9800')
            .margin({ right: 4 })
          Text(`${this.uploadSpeed}`)
            .fontSize(22)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
          Text(' Mbps')
            .fontSize(12)
            .fontColor('#9E9E9E')
        }
        .alignItems(VerticalAlign.Bottom)

        Row() {
          Text('⏱ ')
            .fontSize(14)
            .fontColor('#4CAF50')
          Text(`${this.ping} ms`)
            .fontSize(14)
            .fontColor('#9E9E9E')
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#12121E')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
