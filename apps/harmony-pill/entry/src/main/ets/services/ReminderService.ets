import reminderAgentManager from '@ohos.reminderAgentManager'

import { Medicine } from '../models/MedicineModel'
import { Schedule } from '../models/ScheduleModel'

export class ReminderService {
  async createReminder(schedule: Schedule, medicine: Medicine): Promise<number> {
    const nextDate = this.getNextReminderDate(schedule)
    const request = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      dateTime: {
        year: nextDate.getFullYear(),
        month: nextDate.getMonth() + 1,
        day: nextDate.getDate(),
        hour: schedule.hour,
        minute: schedule.minute
      },
      title: '该吃药了',
      content: `${medicine.name} ${schedule.dose}${medicine.unit}`,
      actionButtons: [
        {
          title: '已服用',
          type: reminderAgentManager.ActionButtonType.SEND_COMMON_EVENT
        }
      ]
    }
    return await reminderAgentManager.publishReminder(request)
  }

  async cancelReminder(reminderId: number): Promise<void> {
    if (reminderId <= 0) {
      return
    }
    await reminderAgentManager.cancelReminder(reminderId)
  }

  async refreshNextDayReminders(): Promise<void> {
  }

  getNextReminderDate(schedule: Schedule): Date {
    const now = new Date()
    const next = new Date(now.getTime())
    next.setHours(schedule.hour, schedule.minute, 0, 0)
    if (schedule.frequency === 'DAILY') {
      if (next.getTime() <= now.getTime()) {
        next.setDate(next.getDate() + 1)
      }
      return next
    }

    if (schedule.frequency === 'EVERY_OTHER_DAY') {
      if (next.getTime() <= now.getTime()) {
        next.setDate(next.getDate() + 1)
      }
      if (next.getDate() % 2 === 0) {
        next.setDate(next.getDate() + 1)
      }
      return next
    }

    const allowedDays = schedule.weekDays.split(',').filter((item: string) => item.length > 0).map((item: string) => Number(item))
    for (let i = 0; i < 8; i++) {
      const weekDay = next.getDay() === 0 ? 7 : next.getDay()
      if (allowedDays.includes(weekDay) && next.getTime() > now.getTime()) {
        return next
      }
      next.setDate(next.getDate() + 1)
      next.setHours(schedule.hour, schedule.minute, 0, 0)
    }
    return next
  }
}

export const reminderService = new ReminderService()
