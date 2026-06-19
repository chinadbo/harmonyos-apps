import reminderAgentManager from '@ohos.reminderAgentManager';
import { Course } from '../data/CourseModel';

interface ReminderRecord {
  id: number;
  createdAt: number;
}

class ReminderService {
  private reminderRecords: ReminderRecord[] = [];

  private milsToLocalDateTime(ms: number): reminderAgentManager.LocalDateTime {
    const d = new Date(ms);
    return {
      year: d.getFullYear(),
      month: d.getMonth() + 1,
      day: d.getDate(),
      hour: d.getHours(),
      minute: d.getMinutes(),
      second: d.getSeconds()
    };
  }

  private trimOldestReminder(): Promise<void> {
    if (this.reminderRecords.length < 30) {
      return Promise.resolve();
    }
    const oldest = this.reminderRecords.slice().sort((left, right) => left.createdAt - right.createdAt)[0];
    return reminderAgentManager.cancelReminder(oldest.id)
      .catch(() => undefined)
      .then(() => {
        this.reminderRecords = this.reminderRecords.filter((item: ReminderRecord) => item.id !== oldest.id);
      });
  }

  publishReminder(course: Course, triggerTime: number): Promise<number> {
    if (!course.reminderEnabled) {
      return Promise.resolve(0);
    }
    // triggerTime is Unix ms; only schedule future reminders
    if (triggerTime <= Date.now()) {
      return Promise.resolve(0);
    }
    return this.trimOldestReminder().then(() => {
      const reminderRequest: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: this.milsToLocalDateTime(triggerTime),
        title: course.name,
        content: `${course.location} · ${course.teacher}`
      };
      return reminderAgentManager.publishReminder(reminderRequest).then((reminderId: number) => {
        this.reminderRecords.push({ id: reminderId, createdAt: Date.now() });
        return reminderId;
      });
    });
  }

  cancelReminder(reminderId: number): Promise<void> {
    if (reminderId <= 0) {
      return Promise.resolve();
    }
    return reminderAgentManager.cancelReminder(reminderId)
      .catch(() => undefined)
      .then(() => {
        this.reminderRecords = this.reminderRecords.filter((item: ReminderRecord) => item.id !== reminderId);
      });
  }
}

export const reminderService: ReminderService = new ReminderService();
