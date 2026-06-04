import { ReminderItem, createEmptyReminder } from '../models/Reminder';
import { databaseService } from './DatabaseService';
import { reminderAgentService } from '../managers/ReminderAgentManager';
import { normalizeReminderType } from '../utils/Constants';
import { todayString } from '../utils/Formatters';

class ReminderService {
  async list(vehicleId?: number): Promise<ReminderItem[]> {
    return await databaseService.queryReminders(vehicleId);
  }

  async getById(id: number): Promise<ReminderItem> {
    const reminders: ReminderItem[] = await this.list();
    return reminders.find((item: ReminderItem) => item.id === id) ?? createEmptyReminder();
  }

  async save(reminder: ReminderItem): Promise<ReminderItem> {
    let payload: ReminderItem = {
      ...reminder,
      type: normalizeReminderType(reminder.type),
      createdAt: reminder.createdAt && reminder.createdAt.length > 0 ? reminder.createdAt : todayString()
    };

    if (payload.isActive) {
      const reminderId: number = await reminderAgentService.publish(payload);
      payload = {
        ...payload,
        reminderId
      };
    } else if (payload.reminderId > 0) {
      await reminderAgentService.cancel(payload.reminderId);
    }

    if (payload.id > 0) {
      await databaseService.updateReminder(payload);
      return payload;
    }
    const id: number = await databaseService.insertReminder(payload);
    return {
      ...payload,
      id
    };
  }

  async toggle(reminder: ReminderItem, isActive: boolean): Promise<ReminderItem> {
    return await this.save({
      ...reminder,
      isActive
    });
  }
}

export const reminderService: ReminderService = new ReminderService();
