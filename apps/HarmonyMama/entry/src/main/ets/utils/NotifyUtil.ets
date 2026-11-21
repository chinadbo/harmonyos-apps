import notificationManager from '@ohos.notificationManager';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';

const DOMAIN: number = 0x0000;
const TAG: string = 'NotifyUtil';

export class NotifyUtil {
  private static nextId: number = Math.floor(Date.now() % 100000);

  static async requestPermission(context?: common.UIAbilityContext): Promise<boolean> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled();
      if (enabled) {
        return true;
      }
      if (context !== undefined) {
        await notificationManager.requestEnableNotification(context);
      } else {
        await notificationManager.requestEnableNotification();
      }
      return await notificationManager.isNotificationEnabled();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'requestPermission failed: %{public}d %{public}s', error.code, error.message);
      return false;
    }
  }

  static async publishCheckupNotify(name: string, date: string): Promise<boolean> {
    try {
      NotifyUtil.nextId = NotifyUtil.nextId >= 2000000000 ? 1 : NotifyUtil.nextId + 1;
      const request: notificationManager.NotificationRequest = {
        id: NotifyUtil.nextId,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '产检提醒',
            text: `该进行「${name}」产检了，请携带档案按时就诊。`,
            additionalText: `产检日期：${date}`
          }
        }
      };
      await notificationManager.publish(request);
      hilog.info(DOMAIN, TAG, 'publishCheckupNotify succeeded: %{public}s', name);
      return true;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'publishCheckupNotify failed: %{public}d %{public}s', error.code, error.message);
      return false;
    }
  }
}
