export class AlarmModel {
  id: number = 0
  hour: number = 0
  minute: number = 0
  label: string = ''
  enabled: boolean = true
  repeatDays: Array<number> = []

  constructor(id: number, hour: number, minute: number, label: string, enabled: boolean = true,
    repeatDays: Array<number> = []) {
    this.id = id
    this.hour = hour
    this.minute = minute
    this.label = label
    this.enabled = enabled
    this.repeatDays = repeatDays
  }

  getTimeLabel(): string {
    let hourText: string = this.hour < 10 ? `0${this.hour}` : `${this.hour}`
    let minuteText: string = this.minute < 10 ? `0${this.minute}` : `${this.minute}`
    return `${hourText}:${minuteText}`
  }
}
