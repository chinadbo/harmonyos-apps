import reminderAgentManager from '@ohos.reminderAgentManager'
import { AppStorageKeys, type ActiveReminder } from '../common/AppStorageKeys'
import { DateUtils } from '../common/DateUtils'

export class ReminderService {
  private static readonly MAX_REMINDERS: number = 30

  private readReminderList(): ActiveReminder[] {
    return AppStorage.get<Array<ActiveReminder>>(AppStorageKeys.ACTIVE_REMINDERS) ?? []
  }

  private saveReminderList(items: ActiveReminder[]): void {
    AppStorage.setOrCreate(AppStorageKeys.ACTIVE_REMINDERS, items)
  }

  private async ensureCapacity(): Promise<void> {
    const list: ActiveReminder[] = this.readReminderList()
    if (list.length < ReminderService.MAX_REMINDERS) {
      return
    }
    const oldest: ActiveReminder = list[0]
    await this.cancelReminder(oldest.reminderId)
  }

  async publishFeedReminder(hour: number, minute: number): Promise<number> {
    await this.ensureCapacity()
    const request: Record<string, Object | string | number | boolean> = {
      reminderType: 'ALARM',
      title: '喂食提醒',
      description: `每天 ${DateUtils.timeLabel(hour, minute)} 提醒喂食`,
      hour,
      minute,
      repeatDays: [0, 1, 2, 3, 4, 5, 6],
      ringDuration: 30,
      actionButton: '查看详情'
    }
    let reminderId: number = DateUtils.nowTimestamp()
    const manager = reminderAgentManager as Record<string, Function>
    if (typeof manager.publishReminder === 'function') {
      reminderId = await manager.publishReminder(request) as number
    } else if (typeof manager.publishReminderAgent === 'function') {
      reminderId = await manager.publishReminderAgent(request) as number
    }
    const list: ActiveReminder[] = this.readReminderList()
    list.push({
      reminderId,
      title: '每日喂食提醒',
      timeText: DateUtils.timeLabel(hour, minute),
      reminderType: 'ALARM'
    })
    this.saveReminderList(list)
    AppStorage.setOrCreate(AppStorageKeys.NEXT_FEED_TIME, DateUtils.timeLabel(hour, minute))
    return reminderId
  }

  async publishVaccineReminder(date: string, title: string): Promise<number> {
    await this.ensureCapacity()
    const request: Record<string, Object | string | number | boolean> = {
      reminderType: 'CALENDAR',
      title,
      description: `${title} 到期提醒`,
      date
    }
    let reminderId: number = DateUtils.nowTimestamp()
    const manager = reminderAgentManager as Record<string, Function>
    if (typeof manager.publishReminder === 'function') {
      reminderId = await manager.publishReminder(request) as number
    } else if (typeof manager.publishReminderAgent === 'function') {
      reminderId = await manager.publishReminderAgent(request) as number
    }
    const list: ActiveReminder[] = this.readReminderList()
    list.push({
      reminderId,
      title,
      timeText: date,
      reminderType: 'CALENDAR'
    })
    this.saveReminderList(list)
    return reminderId
  }

  async cancelReminder(reminderId: number): Promise<void> {
    const manager = reminderAgentManager as Record<string, Function>
    if (typeof manager.cancelReminder === 'function') {
      await manager.cancelReminder(reminderId)
    } else if (typeof manager.cancelReminderAgent === 'function') {
      await manager.cancelReminderAgent(reminderId)
    }
    const filtered: ActiveReminder[] = this.readReminderList().filter((item: ActiveReminder) => item.reminderId !== reminderId)
    this.saveReminderList(filtered)
  }
}
