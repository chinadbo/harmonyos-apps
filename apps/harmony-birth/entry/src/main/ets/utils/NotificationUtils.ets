import common from '@ohos.app.ability.common';
import notificationManager from '@ohos.notificationManager';
import reminderAgentManager from '@ohos.reminderAgentManager';
import { Contact } from '../model/Contact';
import { ContactDao } from '../database/ContactDao';
import { DateUtils } from './DateUtils';

export class NotificationUtils {
  static async ensureNotificationEnabled(): Promise<boolean> {
    try {
      return await (notificationManager as any).isNotificationEnabled();
    } catch (_err) {
      return true;
    }
  }

  static async syncContactReminders(contact: Contact): Promise<void> {
    await this.cancelContactReminders(contact.id ?? 0);
    for (let index = 0; index < contact.reminderDays.length; index++) {
      await this.publishCalendarReminder(contact, contact.reminderDays[index]);
    }
  }

  static async syncAllReminders(context: common.Context): Promise<void> {
    let contacts = await ContactDao.getAll(context);
    for (let index = 0; index < contacts.length; index++) {
      await this.syncContactReminders(contacts[index]);
    }
  }

  static async cancelContactReminders(contactId: number): Promise<void> {
    if (!contactId) {
      return;
    }
    try {
      let reminders: any[] = await (reminderAgentManager as any).getValidReminders();
      for (let index = 0; index < reminders.length; index++) {
        let item: any = reminders[index];
        // 精确匹配格式 HB_<contactId>_<daysBefore>，避免 contactId=10 匹配 HB_100_
        let prefix = `HB_${contactId}_`;
        let title: string = item.title ?? '';
        let endsWithNumber = /^HB_\d+_\d+$/.test(title);
        if (title.startsWith(prefix) && endsWithNumber && title.split('_')[1] === String(contactId)) {
          await (reminderAgentManager as any).cancelReminder(item.reminderId);
        }
      }
    } catch (_err) {
      console.error('cancelContactReminders failed');
    }
  }

  private static async publishCalendarReminder(contact: Contact, daysBefore: number): Promise<void> {
    try {
      let reminderDate = DateUtils.getReminderDate(contact.birthday, daysBefore);
      let request: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        title: `HB_${contact.id ?? 0}_${daysBefore}`,
        content: `${contact.name}将在${daysBefore}天后过生日，记得准备祝福与礼物。`,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        dateTime: {
          year: reminderDate.getFullYear(),
          month: reminderDate.getMonth() + 1,
          day: reminderDate.getDate(),
          hour: 9,
          minute: 0,
          second: 0
        },
        repeatMonths: [],
        repeatDays: []
      };
      await reminderAgentManager.publishReminder(request);
    } catch (err) {
      console.error(`publishCalendarReminder failed: ${JSON.stringify(err)}`);
    }
  }
}
