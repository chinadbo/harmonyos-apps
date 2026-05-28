import reminderAgentManager from '@ohos.reminderAgentManager';

class ReminderService {
  async setSleepReminder(hour: number, minute: number): Promise<number> {
    try {
      const reminder: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: hour,
        minute: minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: '该睡觉了',
        content: '保持规律作息，今晚好好休息',
        notificationId: 1001,
        ringDuration: 10,
        snoozeTimes: 0,
        timeInterval: 0,
        actionButton: [
          {
            title: '好的',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ]
      };
      const reminderId = await reminderAgentManager.publishReminder(reminder);
      return reminderId;
    } catch (err) {
      console.error('[ReminderService] setSleepReminder error:', JSON.stringify(err));
      return -1;
    }
  }

  async setWakeReminder(hour: number, minute: number): Promise<number> {
    try {
      const reminder: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: hour,
        minute: minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: '起床时间到',
        content: '美好的一天从充足睡眠开始',
        notificationId: 1002,
        ringDuration: 10,
        snoozeTimes: 0,
        timeInterval: 0,
        actionButton: [
          {
            title: '关闭',
            type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
          }
        ]
      };
      const reminderId = await reminderAgentManager.publishReminder(reminder);
      return reminderId;
    } catch (err) {
      console.error('[ReminderService] setWakeReminder error:', JSON.stringify(err));
      return -1;
    }
  }

  async cancelReminder(reminderId: number): Promise<void> {
    try {
      if (reminderId > 0) {
        await reminderAgentManager.cancelReminder(reminderId);
      }
    } catch (err) {
      console.error('[ReminderService] cancelReminder error:', JSON.stringify(err));
    }
  }
}

export default new ReminderService();
