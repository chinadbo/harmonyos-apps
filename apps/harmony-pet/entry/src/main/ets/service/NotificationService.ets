import notificationManager from '@ohos.notificationManager'

export class NotificationService {
  async sendVaccineNotification(petName: string, vaccineName: string, daysLeft: number): Promise<void> {
    const label: string = daysLeft === 0 ? '今天到期' : `${daysLeft} 天后到期`
    const request: Record<string, Object | string | number | boolean | Array<Object>> = {
      id: new Date().getTime(),
      slotType: 'SERVICE_REMINDER',
      content: {
        title: `${petName} 的健康提醒`,
        text: `${vaccineName}${label}`,
        additionalText: '点击查看详情'
      },
      actionButtons: [
        {
          title: '查看详情'
        }
      ]
    }
    const manager = notificationManager as Record<string, Function>
    if (typeof manager.publish === 'function') {
      await manager.publish(request)
    } else if (typeof manager.publishNotification === 'function') {
      await manager.publishNotification(request)
    }
  }
}
