import { AlarmModel } from '../models/AlarmModel'
import { TimezoneModel } from '../models/TimezoneModel'

export class SettingsModel {
  use24Hour: boolean = true
  vibrationEnabled: boolean = true
  defaultTimerSeconds: number = 300

  constructor(use24Hour: boolean = true, vibrationEnabled: boolean = true, defaultTimerSeconds: number = 300) {
    this.use24Hour = use24Hour
    this.vibrationEnabled = vibrationEnabled
    this.defaultTimerSeconds = defaultTimerSeconds
  }
}

export class StorageUtils {
  private static alarms: Array<AlarmModel> = [
    new AlarmModel(1, 7, 30, 'Morning'),
    new AlarmModel(2, 21, 45, 'Workout', false)
  ]

  private static worldClocks: Array<TimezoneModel> = [
    new TimezoneModel('london', 'London', 'United Kingdom', 0),
    new TimezoneModel('new_york', 'New York', 'United States', -4 * 60),
    new TimezoneModel('tokyo', 'Tokyo', 'Japan', 9 * 60),
    new TimezoneModel('sydney', 'Sydney', 'Australia', 10 * 60)
  ]

  private static settings: SettingsModel = new SettingsModel(true, true, 300)

  static getAlarms(): Array<AlarmModel> {
    return StorageUtils.alarms.map((alarm: AlarmModel) => {
      return new AlarmModel(alarm.id, alarm.hour, alarm.minute, alarm.label, alarm.enabled, [...alarm.repeatDays])
    })
  }

  static saveAlarms(alarms: Array<AlarmModel>): void {
    StorageUtils.alarms = alarms.map((alarm: AlarmModel) => {
      return new AlarmModel(alarm.id, alarm.hour, alarm.minute, alarm.label, alarm.enabled, [...alarm.repeatDays])
    })
  }

  static getWorldClocks(): Array<TimezoneModel> {
    return StorageUtils.worldClocks.map((zone: TimezoneModel) => {
      return new TimezoneModel(zone.id, zone.city, zone.country, zone.offsetMinutes)
    })
  }

  static getSettings(): SettingsModel {
    return new SettingsModel(
      StorageUtils.settings.use24Hour,
      StorageUtils.settings.vibrationEnabled,
      StorageUtils.settings.defaultTimerSeconds
    )
  }

  static saveSettings(settings: SettingsModel): void {
    StorageUtils.settings = new SettingsModel(
      settings.use24Hour,
      settings.vibrationEnabled,
      settings.defaultTimerSeconds
    )
  }
}
