import notificationManager from '@ohos.notificationManager'

const NOTIFICATION_ID: number = 1001

export class NotificationService {
  private static instance: NotificationService | null = null

  private constructor() {}

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService()
    }
    return NotificationService.instance
  }

  async showTimerNotification(projectName: string): Promise<void> {
    const request: notificationManager.NotificationRequest = {
      id: NOTIFICATION_ID,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '计时中',
          text: `${projectName} - 00:00:00`,
          additionalText: 'HarmonyTime'
        }
      },
      isOngoing: true
    }
    try {
      await notificationManager.publish(request)
    } catch (err) {
      console.error('NotificationService show error: ' + JSON.stringify(err))
    }
  }

  async updateTimerNotification(projectName: string, elapsedSeconds: number): Promise<void> {
    const timeStr = this.formatTime(elapsedSeconds)
    const request: notificationManager.NotificationRequest = {
      id: NOTIFICATION_ID,
      content: {
        contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '计时中',
          text: `${projectName} - ${timeStr}`,
          additionalText: 'HarmonyTime'
        }
      },
      isOngoing: true
    }
    try {
      await notificationManager.publish(request)
    } catch (err) {
      console.error('NotificationService update error: ' + JSON.stringify(err))
    }
  }

  async cancelTimerNotification(): Promise<void> {
    try {
      await notificationManager.cancel(NOTIFICATION_ID)
    } catch (err) {
      console.error('NotificationService cancel error: ' + JSON.stringify(err))
    }
  }

  private formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = seconds % 60
    return `${this.pad(h)}:${this.pad(m)}:${this.pad(s)}`
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }
}
