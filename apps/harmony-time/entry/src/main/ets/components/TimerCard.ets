@Component
export struct TimerCard {
  @Prop projectName: string = ''
  @Prop projectColor: string = '#4FC3F7'
  @Prop projectIcon: string = '⏱'
  @StorageProp('isTimerRunning') isRunning: boolean = false
  @StorageProp('elapsedSeconds') elapsed: number = 0
  onPause: () => void = () => {}
  onStop: () => void = () => {}

  private formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = seconds % 60
    return `${this.pad(h)}:${this.pad(m)}:${this.pad(s)}`
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }

  build() {
    Column() {
      // Project info
      Row() {
        Text(this.projectIcon)
          .fontSize(28)
        Text(this.projectName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 8 })
      }
      .margin({ bottom: 24 })

      // Timer display
      Text(this.formatTime(this.elapsed))
        .fontSize(56)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.projectColor)
        .margin({ bottom: 32 })

      // Status indicator
      Row() {
        Circle()
          .width(10)
          .height(10)
          .fill(this.isRunning ? '#4CAF50' : '#FF9800')
        Text(this.isRunning ? '计时中' : '已暂停')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 6 })
      }
      .margin({ bottom: 24 })

      // Control buttons
      Row() {
        Button(this.isRunning ? '暂停' : '继续')
          .type(ButtonType.Capsule)
          .backgroundColor(this.isRunning ? '#FF9800' : '#4CAF50')
          .width(120)
          .height(44)
          .onClick(() => {
            this.onPause()
          })

        Button('停止')
          .type(ButtonType.Capsule)
          .backgroundColor('#F44336')
          .width(120)
          .height(44)
          .margin({ left: 16 })
          .onClick(() => {
            this.onStop()
          })
      }
    }
    .width('100%')
    .padding(24)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .alignItems(HorizontalAlign.Center)
  }
}
