import reminderAgentManager from '@ohos.reminderAgentManager';
import { BUNDLE_NAME, ENTRY_ABILITY_NAME, MAX_REMINDERS } from '../common/Constants';

export interface ReminderMeta {
  id: number;
  createdAt: number;
}

export class ReminderService {
  private static reminderMetas: ReminderMeta[] = [];

  // P0-3 修复：publishReminder 不接受 context 参数
  // P1-3 修复：改用 REMINDER_TYPE_ALARM + daysOfWeek 实现每日重复提醒
  static async publishDailyReminder(habitName: string, reminderTime: string): Promise<number> {
    if (!reminderTime) {
      return -1;
    }
    await this.evictOldestIfNeeded();
    const timeParts = reminderTime.split(':');
    const request: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      hour: Number(timeParts[0]),
      minute: Number(timeParts[1]),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // 每天重复
      actionButton: [
        {
          title: '打卡',
          buttonType: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CUSTOM
        }
      ],
      wantAgent: {
        pkgName: BUNDLE_NAME,
        abilityName: ENTRY_ABILITY_NAME
      },
      title: habitName,
      content: '该打卡了！',
      ringDuration: 5
    };
    // P0-3: 只传 request，不传 context
    const reminderId = await reminderAgentManager.publishReminder(request);
    this.reminderMetas.push({ id: reminderId, createdAt: Date.now() });
    return reminderId;
  }

  static async cancelReminder(reminderId: number): Promise<void> {
    if (reminderId < 0) {
      return;
    }
    await reminderAgentManager.cancelReminder(reminderId);
    this.reminderMetas = this.reminderMetas.filter((item) => item.id !== reminderId);
  }

  private static async evictOldestIfNeeded(): Promise<void> {
    if (this.reminderMetas.length < MAX_REMINDERS) {
      return;
    }
    this.reminderMetas.sort((a, b) => a.createdAt - b.createdAt);
    const oldest = this.reminderMetas.shift();
    if (oldest) {
      await reminderAgentManager.cancelReminder(oldest.id);
    }
  }
}
