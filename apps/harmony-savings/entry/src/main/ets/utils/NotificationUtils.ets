import notificationManager from '@ohos.notificationManager'

export class NotificationUtils {
  static async requestPermission(): Promise<boolean> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled()
      if (enabled) {
        return true
      }
      await notificationManager.requestEnableNotification()
      return await notificationManager.isNotificationEnabled()
    } catch (error) {
      console.error(`request notification permission failed: ${JSON.stringify(error)}`)
      return false
    }
  }

  static async publishGoalCompleted(goalName: string): Promise<void> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        return
      }
      await notificationManager.publish({
        id: Date.now() % 2147483647,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '储蓄目标已完成',
            text: `恭喜你完成目标：${goalName}`,
            additionalText: '继续保持储蓄习惯'
          }
        }
      })
    } catch (error) {
      console.error(`publish notification failed: ${JSON.stringify(error)}`)
    }
  }
}
