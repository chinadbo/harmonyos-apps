import notificationManager from '@ohos.notificationManager';
import { STATUS_LABELS } from '../utils/Constants';
import type { PackageRecord } from '../model/PackageModel';

export class NotificationService {
  static async publishStatusNotification(record: PackageRecord, _enableVibration: boolean = true): Promise<void> {
    const request: notificationManager.NotificationRequest = {
      id: Number(record.id ?? Date.now()),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: `${record.courierName} ${STATUS_LABELS[record.status] ?? '状态更新'}`,
          text: record.latestDesc,
          additionalText: record.trackingNo
        }
      },
      slotType: notificationManager.SlotType.SERVICE_INFORMATION
    };
    await notificationManager.publish(request);
  }
}
