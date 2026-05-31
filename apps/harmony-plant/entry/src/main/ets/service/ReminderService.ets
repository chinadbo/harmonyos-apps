import reminderAgentManager from '@ohos.reminderAgentManager'
import { Plant } from '../model/Plant'

export class ReminderService {
  private static instance: ReminderService = new ReminderService()

  static getInstance(): ReminderService {
    return ReminderService.instance
  }

  async publishReminder(plant: Plant): Promise<number> {
    const nextWaterDate = plant.getNextWaterDate()
    const reminderRequest = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: {
        year: nextWaterDate.getFullYear(),
        month: nextWaterDate.getMonth() + 1,
        day: nextWaterDate.getDate(),
        hour: 9,
        minute: 0,
        second: 0
      },
      actionButton: [],
      title: `该给 ${plant.name} 浇水了`,
      content: `${plant.name} 今天需要浇水，记得照顾它。`,
      slotType: reminderAgentManager.SlotType.SOCIAL_COMMUNICATION,
      tapDismissed: false,
      autoDeletedTime: nextWaterDate.getTime() + 24 * 60 * 60 * 1000
    }
    const reminderId = await reminderAgentManager.publishReminder(reminderRequest)
    return Number(reminderId)
  }

  async cancelReminder(reminderId: number): Promise<void> {
    if (!reminderId || reminderId <= 0) {
      return
    }
    await reminderAgentManager.cancelReminder(reminderId)
  }

  async refreshPlantReminder(plant: Plant): Promise<number> {
    if (plant.reminderId > 0) {
      await this.cancelReminder(plant.reminderId)
    }
    return await this.publishReminder(plant)
  }
}
