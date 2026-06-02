import notificationManager from '@ohos.notificationManager';
import common from '@ohos.app.ability.common';
import { Constants } from '../common/Constants';

export class NotificationService {
  private static instance?: NotificationService;
  private context?: common.UIAbilityContext;

  private constructor() {
  }

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    await this.requestPermission();
  }

  async requestPermission(): Promise<void> {
    try {
      await notificationManager.requestEnableNotification();
      AppStorage.SetOrCreate(Constants.STORAGE_NOTIFICATION, true);
    } catch (error) {
      AppStorage.SetOrCreate(Constants.STORAGE_NOTIFICATION, false);
    }
  }

  async publishExpiryNotification(expiredCount: number, expiringSoonCount: number): Promise<void> {
    if (expiredCount <= 0 && expiringSoonCount <= 0) {
      return;
    }
    const message: string = expiredCount > 0
      ? `已过期 ${expiredCount} 项，另有 ${expiringSoonCount} 项即将到期。`
      : `${expiringSoonCount} 项食材将在 7 天内到期。`;
    const request: notificationManager.NotificationRequest = {
      id: 1001,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: 'HarmonyFridge 临期提醒',
          text: message,
          additionalText: '及时处理冰箱食材，减少浪费。'
        }
      }
    };
    try {
      await notificationManager.publish(request);
    } catch (error) {
    }
  }
}
