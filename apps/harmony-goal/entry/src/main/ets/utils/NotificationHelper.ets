import reminderAgentManager from '@ohos.reminderAgentManager';
import { ReminderSettings } from '../model/GoalModel';

const REMINDER_TITLE: string = 'HarmonyGoal 每日回顾';
const REMINDER_CONTENT: string = '记录今天的关键进展，让目标始终向前。';
const DEFAULT_REMINDER_ID: number = 1001;

export class NotificationHelper {
  static defaultSettings(): ReminderSettings {
    return {
      enabled: false,
      hour: 21,
      minute: 0,
      reminderId: DEFAULT_REMINDER_ID
    };
  }

  static loadSettings(): ReminderSettings {
    let saved: ReminderSettings | undefined = AppStorage.Get<ReminderSettings>('reminderSettings');
    if (saved === undefined) {
      let defaults: ReminderSettings = this.defaultSettings();
      AppStorage.SetOrCreate('reminderSettings', defaults);
      return defaults;
    }
    return saved;
  }

  static saveSettings(settings: ReminderSettings): void {
    AppStorage.SetOrCreate('reminderSettings', settings);
    AppStorage.SetOrCreate('reminderEnabled', settings.enabled);
    AppStorage.SetOrCreate('reminderHour', settings.hour);
    AppStorage.SetOrCreate('reminderMinute', settings.minute);
    AppStorage.SetOrCreate('reminderId', settings.reminderId);
  }

  static async applyDailyReminder(settings: ReminderSettings): Promise<void> {
    this.saveSettings(settings);
    if (!settings.enabled) {
      await this.cancelReminder(settings.reminderId);
      return;
    }
    await this.publishReminder(settings);
  }

  static async publishReminder(settings: ReminderSettings): Promise<void> {
    await this.cancelReminder(settings.reminderId);
    let reminderRequest = {
      reminderType: 1,
      reminderId: settings.reminderId,
      title: REMINDER_TITLE,
      content: REMINDER_CONTENT,
      hour: settings.hour,
      minute: settings.minute,
      repeatMonths: [],
      repeatDays: [],
      actionButton: [],
      autoDeletedTime: -1
    } as Object;
    await reminderAgentManager.publishReminder(reminderRequest);
  }

  static async cancelReminder(reminderId: number): Promise<void> {
    try {
      await reminderAgentManager.cancelReminder(reminderId);
    } catch (error) {
    }
  }
}
