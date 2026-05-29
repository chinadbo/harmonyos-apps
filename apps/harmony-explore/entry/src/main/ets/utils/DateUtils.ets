export class DateUtils {
  static formatDateTime(timestamp: number): string {
    const date: Date = new Date(timestamp)
    return `${date.getFullYear()}-${DateUtils.pad(date.getMonth() + 1)}-${DateUtils.pad(date.getDate())} ${DateUtils.pad(date.getHours())}:${DateUtils.pad(date.getMinutes())}`
  }

  static formatDate(timestamp: number): string {
    const date: Date = new Date(timestamp)
    return `${date.getFullYear()}-${DateUtils.pad(date.getMonth() + 1)}-${DateUtils.pad(date.getDate())}`
  }

  static formatMonthDay(timestamp: number): string {
    const date: Date = new Date(timestamp)
    return `${DateUtils.pad(date.getMonth() + 1)}-${DateUtils.pad(date.getDate())}`
  }

  static startOfDay(timestamp: number): number {
    const date: Date = new Date(timestamp)
    date.setHours(0, 0, 0, 0)
    return date.getTime()
  }

  static recentDays(days: number): number[] {
    const values: number[] = []
    const today: number = DateUtils.startOfDay(Date.now())
    for (let index = days - 1; index >= 0; index--) {
      values.push(today - index * 24 * 60 * 60 * 1000)
    }
    return values
  }

  private static pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`
  }
}
