import notificationManager from '@ohos.notificationManager';
import common from '@ohos.app.ability.common';
import { SolarTerm } from '../model/SolarTerm';
import { SolarTermData } from '../engine/SolarTermData';
import { ReminderPrefs } from './DbHelper';
import { Utils } from './Constants';

const NOTIFICATION_ID: number = 2601;
const DAY_MS: number = 86400000;

export class ReminderService {
  static async requestPermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled();
      if (enabled) {
        return true;
      }
      await notificationManager.requestEnableNotification(context);
      return await notificationManager.isNotificationEnabled();
    } catch (err) {
      console.error('request notification permission failed: ' + String(err));
      return false;
    }
  }

  private static async publish(title: string, text: string): Promise<void> {
    const content: notificationManager.NotificationContent = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal: {
        title: title,
        text: text,
        additionalText: 'HarmonySolar · 二十四节气'
      }
    };
    const request: notificationManager.NotificationRequest = {
      id: NOTIFICATION_ID,
      content: content
    };
    await notificationManager.publish(request);
  }

  static async publishPreview(): Promise<void> {
    const now: Date = new Date();
    const next: SolarTerm | undefined = SolarTermData.getNext(now);
    let text: string = '节气提醒已开启，顺时而作，应节而养。';
    if (next !== undefined) {
      const days: number = SolarTermData.getDaysToNext(now, next);
      text = '「' + next.name + '」将于 ' + Utils.shortMoment(next) + ' 交节，' +
        Utils.daysText(days) + '，记得顺时养生。';
    }
    await ReminderService.publish('HarmonySolar · 提醒已开启', text);
  }

  /**
   * 应用启动时检查：今日是否为节气日，或为设置的提前提醒日。
   * 提醒仅通过本地通知发送，不依赖网络。
   */
  static async notifyDue(context: common.UIAbilityContext): Promise<void> {
    let enabled: boolean = false;
    let advance: number = 0;
    try {
      enabled = await ReminderPrefs.isEnabled(context);
      advance = await ReminderPrefs.getAdvanceDays(context);
    } catch (err) {
      console.error('read reminder settings failed: ' + String(err));
      return;
    }
    if (!enabled || !SolarTermData.isReady()) {
      return;
    }
    const now: Date = new Date();
    const todayStart: number = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const terms: SolarTerm[] = SolarTermData.getAll();
    for (let i: number = 0; i < terms.length; i++) {
      const term: SolarTerm = terms[i];
      const termDate: Date = new Date(term.date);
      const termStart: number = new Date(termDate.getFullYear(), termDate.getMonth(), termDate.getDate()).getTime();
      const targetStart: number = termStart - advance * DAY_MS;
      if (targetStart === todayStart) {
        let text: string = '';
        if (advance === 0) {
          text = '今日「' + term.name + '」，' + term.yuxiang[0] + '。宜' + term.suitable[0] + '，忌' + term.taboos[0] + '。';
        } else {
          text = '距离「' + term.name + '」还有 ' + advance + ' 天（' + Utils.shortMoment(term) + ' 交节），宜' +
            term.suitable[0] + '。';
        }
        try {
          await ReminderService.publish('HarmonySolar · 节气提醒', text);
        } catch (err) {
          console.error('publish reminder failed: ' + String(err));
        }
        return;
      }
    }
  }
}
