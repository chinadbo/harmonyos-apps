import reminderAgentManager from '@ohos.reminderAgentManager'
import notificationManager from '@ohos.notificationManager'
import { DailyGoal } from '../model/DailyGoal'

export class ReminderService {
  private static readonly baseReminderId: number = 3001
  private static readonly maxReminderCount: number = 30

  private static buildReminderTimes(goal: DailyGoal): Date[] {
    const times: Date[] = []
    const now = new Date()
    const startMinutes = goal.startHour * 60
    const endMinutes = goal.endHour * 60
    const intervalMinutes = Math.max(30, goal.intervalMinutes)

    if (endMinutes < startMinutes) {
      return times
    }

    let dayOffset = 0
    while (times.length < ReminderService.maxReminderCount) {
      for (let minutes = startMinutes; minutes <= endMinutes && times.length < ReminderService.maxReminderCount; minutes += intervalMinutes) {
        const reminderTime = new Date(now.getTime())
        reminderTime.setDate(now.getDate() + dayOffset)
        reminderTime.setHours(Math.floor(minutes / 60), minutes % 60, 0, 0)
        if (reminderTime.getTime() > now.getTime()) {
          times.push(reminderTime)
        }
      }
      dayOffset++
    }

    return times
  }

  static async publishDailyReminder(goal: DailyGoal): Promise<void> {
    try {
      await ReminderService.cancelReminder()
      if (!goal.reminderEnabled) {
        return
      }

      const reminderTimes = ReminderService.buildReminderTimes(goal)
      for (let index = 0; index < reminderTimes.length; index++) {
        const reminderTime = reminderTimes[index]
        const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
          reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
          dateTime: {
            year: reminderTime.getFullYear(),
            month: reminderTime.getMonth() + 1,
            day: reminderTime.getDate(),
            hour: reminderTime.getHours(),
            minute: reminderTime.getMinutes(),
            second: reminderTime.getSeconds()
          },
          repeatMonths: [],
          repeatDays: [],
          title: '喝水提醒',
          content: '该补水啦，打开 HarmonyHydrate 记录今天的饮水量。',
          slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
          reminderId: ReminderService.baseReminderId + index
        }
        await reminderAgentManager.publishReminder(reminderRequest)
      }
    } catch (error) {
      console.error(`Publish reminder failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  static async cancelReminder(): Promise<void> {
    for (let index = 0; index < ReminderService.maxReminderCount; index++) {
      try {
        await reminderAgentManager.cancelReminder(ReminderService.baseReminderId + index)
      } catch (error) {
        console.error(`Cancel reminder failed: ${JSON.stringify(error)}`)
      }
    }
  }
}
