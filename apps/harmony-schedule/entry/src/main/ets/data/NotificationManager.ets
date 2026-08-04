import * as notification from '@ohos.notification';
import * as router from '@ohos.router';
import { EventModel } from '../models/EventModel';
import { formatDateTime } from '../utils/DateUtils';

// 通知管理器，负责日程提醒通知的创建、取消和跳转数据封装
export class NotificationManager {
  private static instance: NotificationManager = new NotificationManager();

  static getInstance(): NotificationManager {
    return NotificationManager.instance;
  }

  async scheduleEventReminders(event: EventModel): Promise<void> {
    await this.cancelEventReminders(event.id);
    for (let index = 0; index < event.reminderTimes.length; index++) {
      const reminderMinutes: number = event.reminderTimes[index];
      const triggerTime: number = event.startTime - reminderMinutes * 60 * 1000;
      if (triggerTime <= Date.now()) {
        continue;
      }
      const notificationRequest: notification.NotificationRequest = {
        id: this.createNotificationId(event.id, reminderMinutes),
        content: {
          contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `即将开始：${event.title}`,
            text: `${formatDateTime(event.startTime)} · ${event.location || '未设置地点'}`,
            additionalText: '点击查看日程详情'
          }
        },
        deliveryTime: triggerTime,
        tapDismissed: true,
        slotType: notification.SlotType.SERVICE_REMINDER,
        actionButtons: [],
        wantAgent: {
          bundleName: 'com.harmonyschedule.app',
          abilityName: 'EntryAbility',
          parameters: {
            eventId: event.id
          }
        }
      } as notification.NotificationRequest;
      await notification.publishNotification(notificationRequest);
    }
  }

  async cancelEventReminders(eventId: number): Promise<void> {
    const reminderOffsets: number[] = [15, 30, 60, 120, 1440];
    for (const reminderOffset of reminderOffsets) {
      try {
        await notification.cancel(this.createNotificationId(eventId, reminderOffset));
      } catch (error) {
        console.error(`Failed to cancel notification: ${JSON.stringify(error)}`);
      }
    }
  }

  navigateToEventDetail(eventId: number): void {
    router.pushUrl({
      url: 'pages/EventDetailPage',
      params: {
        eventId
      }
    });
  }

  private createNotificationId(eventId: number, reminderMinutes: number): number {
    return eventId * 10000 + reminderMinutes;
  }
}

export default NotificationManager.getInstance();
