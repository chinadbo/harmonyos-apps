export class DateUtils {
  static today(): string {
    const now: Date = new Date()
    return this.formatDate(now)
  }

  static formatDate(date: Date): string {
    const year: number = date.getFullYear()
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0')
    const day: string = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  static formatDateLabel(dateString: string): string {
    if (!dateString) {
      return '--'
    }
    return dateString
  }

  static isExpired(dateString: string): boolean {
    if (!dateString) {
      return false
    }
    return dateString < this.today()
  }

  static daysUntil(dateString: string): number {
    if (!dateString) {
      return 0
    }
    const todayDate: Date = new Date(`${this.today()}T00:00:00`)
    const targetDate: Date = new Date(`${dateString}T00:00:00`)
    const diff: number = targetDate.getTime() - todayDate.getTime()
    return Math.ceil(diff / (24 * 60 * 60 * 1000))
  }
}
