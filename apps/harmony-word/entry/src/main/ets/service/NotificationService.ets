import notification from '@ohos.notification'

export class NotificationService {
  static async publishDailyWord(title: string, content: string): Promise<void> {
    try {
      await notification.publish({
        id: 1001,
        content: {
          contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title,
            text: content
          }
        }
      })
    } catch (error) {
      console.error(`publish notification failed: ${JSON.stringify(error)}`)
    }
  }
}
