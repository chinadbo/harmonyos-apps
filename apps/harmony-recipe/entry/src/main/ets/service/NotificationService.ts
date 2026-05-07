import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
import common from '@ohos.app.ability.common';

export default class NotificationService {
  private static instance: NotificationService = new NotificationService();

  static getInstance(): NotificationService {
    return NotificationService.instance;
  }

  /**
   * 请求通知权限（需要传入 UIAbilityContext）
   */
  async ensureNotificationEnabled(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled();
      if (enabled) {
        return true;
      }
      await notificationManager.requestEnableNotification(context);
      return true;
    } catch (err) {
      return false;
    }
  }

  /**
   * 发布倒计时提醒（triggerTimeInSeconds 秒后触发）
   */
  async publishTimer(seconds: number, title: string, content: string): Promise<number> {
    try {
      const reminderRequest: reminderAgentManager.ReminderRequestTimer = {
        reminderType: reminderAgentManager.ReminderType.TIMER,
        triggerTimeInSeconds: seconds,
        title: title,
        content: content,
        expiredContent: '计时结束',
        actionButton: [],
        wantAgent: {
          pkgName: 'com.chinadbo.harmonyrecipe',
          abilityName: 'EntryAbility'
        }
      };
      const reminderId = await reminderAgentManager.publishReminder(reminderRequest);
      return reminderId;
    } catch (err) {
      return -1;
    }
  }

  async cancelTimer(reminderId: number): Promise<void> {
    if (reminderId > 0) {
      try {
        await reminderAgentManager.cancelReminder(reminderId);
      } catch (err) {
        // ignore
      }
    }
  }
}
