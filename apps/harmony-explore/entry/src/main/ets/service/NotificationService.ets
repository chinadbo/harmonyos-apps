import notificationManager from '@ohos.notificationManager'

export class NotificationService {
  private static instance: NotificationService = new NotificationService()

  static getInstance(): NotificationService {
    return NotificationService.instance
  }

  async publishBasicText(id: number, title: string, text: string): Promise<void> {
    const request: notificationManager.NotificationRequest = {
      id,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title,
          text,
          additionalText: ''
        }
      }
    }
    await notificationManager.publish(request)
  }
}
