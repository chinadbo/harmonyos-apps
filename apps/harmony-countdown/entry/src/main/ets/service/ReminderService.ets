import reminderAgentManager from '@ohos.reminderAgentManager';
import notificationManager from '@ohos.notificationManager';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { CountdownEvent } from '../model/CountdownEvent';
import { DateUtils } from '../utils/DateUtils';

class ReminderService {
  async requestNotification(context: common.UIAbilityContext): Promise<void> {
    try {
      await notificationManager.requestEnableNotification(context);
    } catch (error) {
      promptAction.showToast({ message: '提醒授权请求失败' });
    }
  }

  async syncReminder(event: CountdownEvent): Promise<void> {
    if (!event.isReminderEnabled) {
      return;
    }
    let reminders = await reminderAgentManager.getAllValidReminders();
    if (reminders.length >= 30) {
      throw new Error('系统提醒数量已达上限');
    }
    let targetDate: Date = DateUtils.getEffectiveTargetDate(event);
    let reminderDate: Date = new Date(
      targetDate.getFullYear(),
      targetDate.getMonth(),
      targetDate.getDate(),
      event.reminderHour,
      event.reminderMinute,
      0,
      0
    );
    let reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
      title: event.title,
      content: event.note.length > 0 ? event.note : `${event.title} 已到提醒时间`,
      dateTime: {
        year: reminderDate.getFullYear(),
        month: reminderDate.getMonth() + 1,
        day: reminderDate.getDate(),
        hour: reminderDate.getHours(),
        minute: reminderDate.getMinutes(),
        second: 0
      },
      repeatMonths: event.isRepeatYearly ? [targetDate.getMonth() + 1] : [],
      repeatDays: event.isRepeatYearly ? [targetDate.getDate()] : []
    };
    await reminderAgentManager.publishReminder(reminderRequest);
  }
}

export default new ReminderService();
