import promptAction from '@ohos.promptAction';
import { Constants } from '../common/Constants';
import { NotificationService } from '../service/NotificationService';
import { ExpiryChecker } from '../service/ExpiryChecker';

@Component
export struct SettingsPage {
  @StorageProp(Constants.STORAGE_NOTIFICATION) notificationEnabled: boolean = false;
  @StorageProp(Constants.STORAGE_TOTAL) totalCount: number = 0;
  @StorageProp(Constants.STORAGE_EXPIRED) expiredCount: number = 0;
  @StorageProp(Constants.STORAGE_EXPIRING) expiringSoonCount: number = 0;

  private async requestNotification(): Promise<void> {
    await NotificationService.getInstance().requestPermission();
    promptAction.showToast({ message: '已发起通知授权请求' });
  }

  private async refreshExpiryState(): Promise<void> {
    await ExpiryChecker.getInstance().refreshAll();
    promptAction.showToast({ message: '临期状态已刷新' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20331E')
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 10 }) {
          Text('应用状态')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#294328')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`食材总数：${this.totalCount}`)
          Text(`已过期：${this.expiredCount}`)
          Text(`7 天内到期：${this.expiringSoonCount}`)
          Text(`通知状态：${this.notificationEnabled ? '已授权' : '未授权'}`)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('请求通知权限')
          .width('100%')
          .height(46)
          .backgroundColor('#E8F3E7')
          .fontColor('#294328')
          .onClick(() => {
            this.requestNotification();
          })

        Button('立即检查有效期')
          .width('100%')
          .height(46)
          .backgroundColor('#5E8E5A')
          .onClick(() => {
            this.refreshExpiryState();
          })

        Text('HarmonyFridge 仅在本地保存食材与购物清单数据，用于帮助管理冰箱库存和临期提醒。')
          .fontSize(13)
          .fontColor('#6D816B')
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F8F4')
  }
}
