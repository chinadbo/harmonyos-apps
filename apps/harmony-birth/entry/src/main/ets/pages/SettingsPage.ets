import promptAction from '@ohos.promptAction';
import { NotificationUtils } from '../utils/NotificationUtils';

@Component
struct SettingsPage {
  @State notificationEnabled: boolean = true;

  async aboutToAppear(): Promise<void> {
    this.notificationEnabled = await NotificationUtils.ensureNotificationEnabled();
  }

  build() {
    Column({ space: 16 }) {
      Text('设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Column({ space: 12 }) {
        Row() {
          Column({ space: 6 }) {
            Text('生日提醒状态')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.notificationEnabled ? '系统通知已启用' : '请在系统设置中启用通知')
              .fontSize(13)
              .fontColor('#6B7280')
          }
          .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
            .enabled(false)
        }
        .width('100%')

        Button('重新同步所有提醒')
          .width('100%')
          .height(42)
          .backgroundColor('#FF7A59')
          .onClick(async () => {
            await NotificationUtils.syncAllReminders(getContext(this));
            promptAction.showToast({ message: '提醒已重新同步' });
          })
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)

      Column({ space: 10 }) {
        Text('关于应用')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Text('HarmonyBirth 是一个生日提醒与社交辅助工具，帮助你管理联系人、礼物心愿单和祝福消息模板。')
          .fontSize(14)
          .fontColor('#4B5563')
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
