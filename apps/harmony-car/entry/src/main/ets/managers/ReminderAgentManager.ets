import reminderAgentManager from '@ohos.reminderAgentManager';
import { ReminderItem } from '../models/Reminder';

class ReminderAgentManagerWrapper {
  async publish(reminder: ReminderItem): Promise<number> {
    const triggerTime: number = new Date(reminder.triggerDate).getTime();
    const targetId: number = reminder.id > 0 ? reminder.id : Date.now();
    try {
      const reminderRequest: reminderAgentManager.ReminderRequest = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
        actionButton: [],
        wantAgent: {
          wants: [
            {
              bundleName: 'com.chinadbo.harmonycar',
              abilityName: 'EntryAbility'
            }
          ],
          operationType: reminderAgentManager.OperationType.START_ABILITY
        },
        title: reminder.title,
        content: reminder.content,
        slotType: reminderAgentManager.SlotType.SERVICE_INFORMATION,
        reminderId: targetId,
        triggerTimeInSeconds: Math.floor(triggerTime / 1000)
      };
      await reminderAgentManager.publishReminder(reminderRequest);
      return targetId;
    } catch (_) {
      return targetId;
    }
  }

  async cancel(reminderId: number): Promise<void> {
    if (reminderId <= 0) {
      return;
    }
    try {
      await reminderAgentManager.cancelReminder(reminderId);
    } catch (_) {
    }
  }
}

export const reminderAgentService: ReminderAgentManagerWrapper = new ReminderAgentManagerWrapper();
