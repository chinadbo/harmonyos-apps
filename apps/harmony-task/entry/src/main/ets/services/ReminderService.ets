import reminderAgentManager from '@ohos.reminderAgentManager';
import hilog from '@ohos.hilog';

const TAG: string = 'ReminderService';
const DOMAIN: number = 0xFF00;

export class ReminderService {

  async publishReminder(title: string, dueDate: number, minutesBefore: number): Promise<number> {
    try {
      const reminderTime = dueDate - minutesBefore * 60 * 1000;
      if (reminderTime <= Date.now()) {
        hilog.warn(DOMAIN, TAG, 'Reminder time is in the past, skipping');
        return -1;
      }

      const dateObj = new Date(reminderTime);
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: dateObj.getFullYear(),
          month: dateObj.getMonth() + 1,
          day: dateObj.getDate(),
          hour: dateObj.getHours(),
          minute: dateObj.getMinutes(),
          second: dateObj.getSeconds()
        },
        title: '任务提醒',
        content: title,
        expiredContent: `任务「${title}」即将到期`,
        notificationId: Math.floor(Math.random() * 100000),
        slotType: 3, // SOCIAL_COMMUNICATION
        wantAgent: {
          pkgName: 'com.example.harmonytask',
          abilityName: 'EntryAbility'
        },
        actionButton: [
          {
            title: '查看',
            type: 0
          },
          {
            title: '关闭',
            type: 1
          }
        ]
      };

      const reminderId = await reminderAgentManager.publishReminder(reminderRequest);
      hilog.info(DOMAIN, TAG, 'Published reminder id: %{public}d', reminderId);
      return reminderId;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to publish reminder: %{public}s', JSON.stringify(err));
      return -1;
    }
  }

  async cancelReminder(reminderId: number): Promise<void> {
    try {
      await reminderAgentManager.cancelReminder(reminderId);
      hilog.info(DOMAIN, TAG, 'Cancelled reminder id: %{public}d', reminderId);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to cancel reminder: %{public}s', JSON.stringify(err));
    }
  }

  async cancelAllReminders(): Promise<void> {
    try {
      await reminderAgentManager.cancelAllReminders();
      hilog.info(DOMAIN, TAG, 'Cancelled all reminders');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to cancel all reminders: %{public}s', JSON.stringify(err));
    }
  }
}
