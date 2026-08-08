export class TimezoneModel {
  id: string = ''
  city: string = ''
  country: string = ''
  offsetMinutes: number = 0

  constructor(id: string, city: string, country: string, offsetMinutes: number) {
    this.id = id
    this.city = city
    this.country = country
    this.offsetMinutes = offsetMinutes
  }

  getOffsetLabel(): string {
    let totalMinutes: number = Math.abs(this.offsetMinutes)
    let sign: string = this.offsetMinutes >= 0 ? '+' : '-'
    let hours: number = Math.floor(totalMinutes / 60)
    let minutes: number = totalMinutes % 60
    let hourText: string = hours < 10 ? `0${hours}` : `${hours}`
    let minuteText: string = minutes < 10 ? `0${minutes}` : `${minutes}`
    return `UTC${sign}${hourText}:${minuteText}`
  }
}
