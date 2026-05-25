@Component
export struct NetworkInfoCard {
  @Prop networkType: string = 'Unknown'
  @Prop localIP: string = ''
  @Prop wifiSSID: string = ''

  private networkIcon(): string {
    switch (this.networkType) {
      case 'WiFi': return '📶'
      case '4G/5G': return '📡'
      default: return '🔌'
    }
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.networkIcon())
            .fontSize(20)
            .margin({ right: 8 })
          Text(this.networkType)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(VerticalAlign.Center)

        if (this.networkType === 'WiFi' && this.wifiSSID) {
          Text(this.wifiSSID)
            .fontSize(12)
            .fontColor('#9E9E9E')
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.localIP) {
        Text(this.localIP)
          .fontSize(12)
          .fontColor('#9E9E9E')
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#1E1E2E')
    .borderRadius(8)
  }
}
