import common from '@ohos.app.ability.common'
import { AlarmModel } from '../models/AlarmModel'
import { StorageUtils } from '../utils/StorageUtils'
import { NotificationUtils } from '../utils/NotificationUtils'

export class AlarmService {
  private static getNextId(alarms: Array<AlarmModel>): number {
    let nextId: number = 1
    alarms.forEach((alarm: AlarmModel) => {
      if (alarm.id >= nextId) {
        nextId = alarm.id + 1
      }
    })
    return nextId
  }

  static getAllAlarms(): Array<AlarmModel> {
    return StorageUtils.getAlarms()
  }

  static addAlarm(hour: number, minute: number, label: string): Array<AlarmModel> {
    let alarms: Array<AlarmModel> = StorageUtils.getAlarms()
    alarms.push(new AlarmModel(AlarmService.getNextId(alarms), hour, minute, label, true))
    StorageUtils.saveAlarms(alarms)
    return alarms
  }

  static deleteAlarm(alarmId: number, context: common.UIAbilityContext | undefined = undefined): Array<AlarmModel> {
    let alarms: Array<AlarmModel> = StorageUtils.getAlarms().filter((alarm: AlarmModel) => alarm.id !== alarmId)
    StorageUtils.saveAlarms(alarms)
    NotificationUtils.cancelAlarmReminder(context, alarmId)
    return alarms
  }

  static toggleAlarm(alarmId: number, enabled: boolean,
    context: common.UIAbilityContext | undefined = undefined): Array<AlarmModel> {
    let alarms: Array<AlarmModel> = StorageUtils.getAlarms()
    alarms.forEach((alarm: AlarmModel) => {
      if (alarm.id === alarmId) {
        alarm.enabled = enabled
        if (!enabled) {
          NotificationUtils.cancelAlarmReminder(context, alarm.id)
        }
      }
    })
    StorageUtils.saveAlarms(alarms)
    return alarms
  }
}
