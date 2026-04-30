import { MODE_LABELS, SessionMode, TimerStatus } from '../../common/Constants'

/**
 * Widget 卡片页面
 * 数据通过 formBindingData 注入（不使用 AppStorage，卡片进程无法访问主进程 AppStorage）
 */
@Entry
@Component
struct WidgetCard {
  // 通过 formBindingData 绑定的数据，使用 @LocalStorageProp 接收
  @LocalStorageProp('todayPomodoros') todayPomodoros: number = 0
  @LocalStorageProp('timerStatus') timerStatus: string = TimerStatus.IDLE
  @LocalStorageProp('currentMode') currentMode: string = SessionMode.FOCUS

  private getModeLabel(): string {
    return MODE_LABELS[this.currentMode as SessionMode] ?? '专注'
  }

  private getStatusLabel(): string {
    switch (this.timerStatus as TimerStatus) {
      case TimerStatus.RUNNING:
        return '计时中'
      case TimerStatus.PAUSED:
        return '已暂停'
      default:
        return '待开始'
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('🍅')
          .fontSize(20)
        Text(' HarmonyFocus')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')

      Divider()
        .color('rgba(255,255,255,0.3)')
        .width('100%')

      Row({ space: 8 }) {
        Column({ space: 4 }) {
          Text('今日番茄')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.8)')
          Text(`${this.todayPomodoros}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text('状态')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.8)')
          Text(this.getStatusLabel())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
          Text(this.getModeLabel())
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.7)')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FF6B6B')
    .borderRadius(20)
  }
}
