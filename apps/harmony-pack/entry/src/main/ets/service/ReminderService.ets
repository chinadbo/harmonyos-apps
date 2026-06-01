import common from '@ohos.app.ability.common'
import reminderAgentManager from '@ohos.reminderAgentManager'
import { Trip } from '../model/Trip'
import TripDao from '../database/TripDao'

export default class ReminderService {
  static async syncTripReminders(context: common.Context, trip: Trip): Promise<Trip> {
    await ReminderService.cancelTripReminders(trip)
    const reminder24Id = await ReminderService.publishReminder(trip, 24)
    const reminder2Id = await ReminderService.publishReminder(trip, 2)
    trip.reminder24Id = reminder24Id
    trip.reminder2Id = reminder2Id
    await TripDao.updateReminderIds(context, trip.id, reminder24Id, reminder2Id)
    return trip
  }

  static async cancelTripReminders(trip: Trip): Promise<void> {
    if (trip.reminder24Id > 0) {
      await reminderAgentManager.cancelReminder(trip.reminder24Id)
    }
    if (trip.reminder2Id > 0) {
      await reminderAgentManager.cancelReminder(trip.reminder2Id)
    }
  }

  private static async publishReminder(trip: Trip, hoursBefore: number): Promise<number> {
    const triggerTime = trip.startDate - hoursBefore * 60 * 60 * 1000
    if (triggerTime <= Date.now()) {
      return 0
    }
    const date = new Date(triggerTime)
    const request: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      title: `${trip.destination} 出行提醒`,
      content: `距离 ${trip.title} 出发还有 ${hoursBefore} 小时，请检查打包清单。`,
      dateTime: {
        year: date.getFullYear(),
        month: date.getMonth() + 1,
        day: date.getDate(),
        hour: date.getHours(),
        minute: date.getMinutes(),
        second: 0
      }
    }
    return await reminderAgentManager.publishReminder(request)
  }
}
