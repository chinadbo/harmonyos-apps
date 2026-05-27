@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('currentProject') currentProject: string = '无计时'
  @LocalStorageProp('elapsedTime') elapsedTime: string = '00:00:00'
  @LocalStorageProp('isRunning') isRunning: boolean = false

  build() {
    Column() {
      // Project name
      Text(this.currentProject)
        .fontSize(14)
        .fontColor(this.isRunning ? '#333333' : '#999999')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Timer display
      Text(this.elapsedTime)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isRunning ? '#4FC3F7' : '#CCCCCC')
        .margin({ top: 8 })

      // Status indicator
      Row() {
        Circle()
          .width(6)
          .height(6)
          .fill(this.isRunning ? '#4CAF50' : '#BDBDBD')
        Text(this.isRunning ? '计时中' : '未开始')
          .fontSize(11)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .margin({ top: 8 })

      // Action button
      Button(this.isRunning ? '打开' : '开始')
        .type(ButtonType.Capsule)
        .fontSize(12)
        .height(28)
        .width(64)
        .backgroundColor(this.isRunning ? '#4FC3F7' : '#E0E0E0')
        .fontColor(this.isRunning ? '#FFFFFF' : '#666666')
        .margin({ top: 8 })
        .onClick(() => {
          postCardAction(this, {
            'action': 'router',
            'abilityName': 'EntryAbility',
            'params': {}
          })
        })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
