import notificationManager from '@ohos.notificationManager';
import { BudgetStatus } from '../data/DataModels';
import { FormatUtils } from './FormatUtils';

export class NotificationHelper {
  static async requestEnabled(): Promise<boolean> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled();
      return enabled;
    } catch (error) {
      return false;
    }
  }

  static async notifyBudgetExceeded(status: BudgetStatus, currency: string): Promise<void> {
    const enabled: boolean = await this.requestEnabled();
    if (!enabled || !status.overBudget) {
      return;
    }
    await notificationManager.publish({
      id: Number(`${status.category.id}${status.budget.month.replace('-', '')}`),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: `${status.category.name} 预算已超支`,
          text: `已使用 ${FormatUtils.formatAmount(status.spent, currency)} / 预算 ${FormatUtils.formatAmount(status.budget.amount, currency)}`
        }
      }
    });
  }
}
