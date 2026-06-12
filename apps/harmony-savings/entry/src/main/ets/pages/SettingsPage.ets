import promptAction from '@ohos.promptAction'
import { NotificationUtils } from '../utils/NotificationUtils'

@Entry
@Component
export struct SettingsPage {
  @StorageLink('notificationEnabled') notificationEnabled: boolean = false

  aboutToAppear(): void {
    AppStorage.SetOrCreate('notificationEnabled', this.notificationEnabled)
  }

  private async enableNotification(value: boolean): Promise<void> {
    if (!value) {
      this.notificationEnabled = false
      return
    }
    const granted: boolean = await NotificationUtils.requestPermission()
    this.notificationEnabled = granted
    promptAction.showToast({ message: granted ? '通知已开启' : '通知权限未开启' })
  }

  build() {
    Column({ space: 18 }) {
      Text('设置')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F1F1F')
        .width('100%')

      Column({ space: 14 }) {
        Row() {
          Column({ space: 4 }) {
            Text('目标完成通知')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text('开启后在完成储蓄目标时发送系统通知')
              .fontSize(13)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
            .onChange((value: boolean) => {
              this.enableNotification(value)
            })
        }
        .width('100%')

        Divider()

        Text('金额以分存储，界面展示为元。')
          .fontSize(14)
          .fontColor('#666666')
        Text('日期格式统一为 YYYY-MM-DD。')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F6F8FB')
  }
}
