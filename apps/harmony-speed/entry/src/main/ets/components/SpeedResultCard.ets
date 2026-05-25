@Component
export struct SpeedResultCard {
  @Prop downloadSpeed: number = 0
  @Prop uploadSpeed: number = 0
  @Prop ping: number = 0
  @Prop jitter: number = 0

  @Builder
  MetricItem(icon: string, label: string, value: string, unit: string) {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 4 })
      Text(value)
        .fontSize(22)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
      Text(unit)
        .fontSize(11)
        .fontColor('#9E9E9E')
        .margin({ top: 2 })
      Text(label)
        .fontSize(12)
        .fontColor('#9E9E9E')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .padding(10)
  }

  build() {
    Row() {
      this.MetricItem('↓', '下载', this.downloadSpeed.toFixed(1), 'Mbps')
      Divider().vertical(true).height(48).color('#333344')
      this.MetricItem('↑', '上传', this.uploadSpeed.toFixed(1), 'Mbps')
      Divider().vertical(true).height(48).color('#333344')
      this.MetricItem('⏱', 'Ping', String(this.ping), 'ms')
      Divider().vertical(true).height(48).color('#333344')
      this.MetricItem('≈', '抖动', String(this.jitter), 'ms')
    }
    .width('100%')
    .backgroundColor('#1E1E2E')
    .borderRadius(8)
    .padding({ top: 8, bottom: 8 })
  }
}
