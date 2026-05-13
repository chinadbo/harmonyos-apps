import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import ReminderService from '../service/ReminderService';

@Entry
@Component
struct SettingPage {
  build() {
    Column({ space: 18 }) {
      Row() {
        Button('返回').backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
          router.back();
        });
        Blank();
        Text('设置').fontSize(28).fontWeight(FontWeight.Bold);
        Blank();
      }
      .width('100%');
      Column({ space: 14 }) {
        Text('提醒权限').fontSize(18).fontWeight(FontWeight.Medium);
        Text('本应用仅使用系统级 Reminder 能力，不申请通知控制权限。').fontSize(14).fontColor('#666666');
        Button('请求提醒通知授权').width('100%').height(48).backgroundColor('#FF5B4D').onClick(async () => {
          let context = getContext(this) as common.UIAbilityContext;
          await ReminderService.requestNotification(context);
          promptAction.showToast({ message: '已拉起系统授权页' });
        });
      }
      .padding(18)
      .width('100%')
      .borderRadius(20)
      .backgroundColor('#FFFFFF');
      Column({ space: 14 }) {
        Text('关于应用').fontSize(18).fontWeight(FontWeight.Medium);
        Text('HarmonyCountdown 支持倒计时、纪念日管理、桌面卡片和分享图片。').fontSize(14).fontColor('#666666');
      }
      .padding(18)
      .width('100%')
      .borderRadius(20)
      .backgroundColor('#FFFFFF');
      Blank();
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF7F7F9');
  }
}
