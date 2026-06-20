export class DateUtil {
  static formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  static formatDateTime(date: Date): string {
    const day = this.formatDate(date)
    const hour = `${date.getHours()}`.padStart(2, '0')
    const minute = `${date.getMinutes()}`.padStart(2, '0')
    return `${day} ${hour}:${minute}`
  }

  static now(): string {
    return this.formatDateTime(new Date())
  }
}
