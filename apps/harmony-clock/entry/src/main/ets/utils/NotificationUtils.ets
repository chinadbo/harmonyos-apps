import common from '@ohos.app.ability.common'
import * as notification from '@ohos.notification'

export class NotificationUtils {
  static nextNotificationId: number = 1

  static getNotificationSummary(alarmLabel: string, triggerAt: Date): string {
    return `${alarmLabel} at ${triggerAt.getHours()}:${triggerAt.getMinutes()}`
  }

  static scheduleAlarmReminder(_context: common.UIAbilityContext | undefined, alarmId: number,
    alarmLabel: string, triggerAt: Date): void {
    const title: string = alarmLabel.length > 0 ? alarmLabel : 'Alarm reminder'
    const notificationRequest: notification.NotificationRequest = {
      id: alarmId,
      deliveryTime: triggerAt.getTime(),
      slotType: notification.SlotType.SERVICE_REMINDER,
      content: {
        contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title,
          text: this.getNotificationSummary(title, triggerAt),
          additionalText: 'HarmonyClock'
        }
      }
    }

    notification.publishNotification(notificationRequest).catch((error: Error) => {
      console.error(`scheduleAlarmReminder failed: ${JSON.stringify(error)}`)
    })
  }

  static cancelAlarmReminder(_context: common.UIAbilityContext | undefined, alarmId: number,
    _alarmLabel: string = '', _triggerAt: Date = new Date()): void {
    notification.cancel(alarmId).catch((error: Error) => {
      console.error(`cancelAlarmReminder failed: ${JSON.stringify(error)}`)
    })
  }
}
