import { AlarmModel } from '../models/AlarmModel'
import { TimezoneModel } from '../models/TimezoneModel'

export class TimeUtils {
  static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }

  static formatTime(hour: number, minute: number, use24Hour: boolean = true): string {
    if (use24Hour) {
      return `${TimeUtils.pad(hour)}:${TimeUtils.pad(minute)}`
    }
    let period: string = hour >= 12 ? 'PM' : 'AM'
    let normalizedHour: number = hour % 12
    if (normalizedHour === 0) {
      normalizedHour = 12
    }
    return `${TimeUtils.pad(normalizedHour)}:${TimeUtils.pad(minute)} ${period}`
  }

  static formatCurrentTime(date: Date, use24Hour: boolean = true): string {
    return TimeUtils.formatTime(date.getHours(), date.getMinutes(), use24Hour)
  }

  static formatDate(date: Date): string {
    let weekdays: Array<string> = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    let months: Array<string> = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    return `${weekdays[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}`
  }

  static formatDuration(totalMilliseconds: number): string {
    let safeMilliseconds: number = totalMilliseconds < 0 ? 0 : totalMilliseconds
    let totalSeconds: number = Math.floor(safeMilliseconds / 1000)
    let minutes: number = Math.floor(totalSeconds / 60)
    let seconds: number = totalSeconds % 60
    let centiseconds: number = Math.floor((safeMilliseconds % 1000) / 10)
    return `${TimeUtils.pad(minutes)}:${TimeUtils.pad(seconds)}.${TimeUtils.pad(centiseconds)}`
  }

  static formatTimer(totalSeconds: number): string {
    let safeSeconds: number = totalSeconds < 0 ? 0 : totalSeconds
    let hours: number = Math.floor(safeSeconds / 3600)
    let minutes: number = Math.floor((safeSeconds % 3600) / 60)
    let seconds: number = safeSeconds % 60
    return `${TimeUtils.pad(hours)}:${TimeUtils.pad(minutes)}:${TimeUtils.pad(seconds)}`
  }

  static getWorldClockTime(zone: TimezoneModel, now: Date): string {
    let utcTime: number = now.getTime() + now.getTimezoneOffset() * 60 * 1000
    let zoneTime: Date = new Date(utcTime + zone.offsetMinutes * 60 * 1000)
    return TimeUtils.formatCurrentTime(zoneTime, true)
  }

  static getNextAlarmSummary(alarms: Array<AlarmModel>, use24Hour: boolean = true): string {
    let enabledAlarms: Array<AlarmModel> = alarms.filter((alarm: AlarmModel) => alarm.enabled)
    if (enabledAlarms.length === 0) {
      return 'No alarms enabled'
    }
    let sortedAlarms: Array<AlarmModel> = enabledAlarms.sort((left: AlarmModel, right: AlarmModel) => {
      let leftValue: number = left.hour * 60 + left.minute
      let rightValue: number = right.hour * 60 + right.minute
      return leftValue - rightValue
    })
    let nextAlarm: AlarmModel = sortedAlarms[0]
    return `Next alarm ${TimeUtils.formatTime(nextAlarm.hour, nextAlarm.minute, use24Hour)}`
  }
}
