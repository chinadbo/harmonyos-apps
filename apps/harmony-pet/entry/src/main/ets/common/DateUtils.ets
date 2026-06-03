import type { FeedLog } from '../model/FeedLog'
import type { HealthEvent } from '../model/HealthEvent'
import type { WeightRecord } from '../model/WeightRecord'

export class DateUtils {
  static toDateOnly(date: Date): string {
    const year: number = date.getFullYear()
    const month: string = `${date.getMonth() + 1}`.padStart(2, '0')
    const day: string = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  static today(): string {
    return DateUtils.toDateOnly(new Date())
  }

  static nowTimestamp(): number {
    return new Date().getTime()
  }

  static parseDate(value: string): Date {
    if (!value) {
      return new Date()
    }
    return new Date(`${value}T00:00:00`)
  }

  static calculateAge(birthDate: string): string {
    if (!birthDate) {
      return '未知年龄'
    }
    const birth: Date = DateUtils.parseDate(birthDate)
    const now: Date = new Date()
    let years: number = now.getFullYear() - birth.getFullYear()
    let months: number = now.getMonth() - birth.getMonth()
    if (months < 0 || (months === 0 && now.getDate() < birth.getDate())) {
      years -= 1
      months += 12
    }
    if (years <= 0) {
      const monthCount: number = Math.max(1, Math.floor((now.getTime() - birth.getTime()) / (1000 * 60 * 60 * 24 * 30)))
      return `${monthCount}个月`
    }
    if (months === 0) {
      return `${years}岁`
    }
    return `${years}岁${months}个月`
  }

  static formatDisplayDate(dateText: string): string {
    if (!dateText) {
      return '--'
    }
    const date: Date = DateUtils.parseDate(dateText)
    return `${date.getMonth() + 1}月${date.getDate()}日`
  }

  static formatDisplayDateTime(dateTime: string): string {
    if (!dateTime) {
      return '--'
    }
    const date: Date = new Date(dateTime)
    const month: number = date.getMonth() + 1
    const day: number = date.getDate()
    const hour: string = `${date.getHours()}`.padStart(2, '0')
    const minute: string = `${date.getMinutes()}`.padStart(2, '0')
    return `${month}月${day}日 ${hour}:${minute}`
  }

  static daysUntil(targetDate: string): number {
    if (!targetDate) {
      return Number.MAX_SAFE_INTEGER
    }
    const start: Date = DateUtils.parseDate(DateUtils.today())
    const target: Date = DateUtils.parseDate(targetDate)
    return Math.floor((target.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))
  }

  static isWithinDays(targetDate: string, days: number): boolean {
    const distance: number = DateUtils.daysUntil(targetDate)
    return distance >= 0 && distance <= days
  }

  static isToday(dateText: string): boolean {
    if (!dateText) {
      return false
    }
    return dateText.startsWith(DateUtils.today())
  }

  static groupFeedLogsByDate(items: FeedLog[]): Array<{ date: string; items: FeedLog[] }> {
    const map: Record<string, FeedLog[]> = {}
    items.forEach((item: FeedLog) => {
      const key: string = item.feedTime.slice(0, 10)
      if (!map[key]) {
        map[key] = []
      }
      map[key].push(item)
    })
    const keys: string[] = Object.keys(map).sort((left: string, right: string) => right.localeCompare(left))
    return keys.map((key: string) => ({
      date: key,
      items: map[key].sort((left: FeedLog, right: FeedLog) => right.feedTime.localeCompare(left.feedTime))
    }))
  }

  static recentWeight(records: WeightRecord[]): WeightRecord | null {
    if (records.length === 0) {
      return null
    }
    const sorted: WeightRecord[] = records.sort((left: WeightRecord, right: WeightRecord) =>
      right.recordDate.localeCompare(left.recordDate)
    )
    return sorted[0]
  }

  static nextHealthEvent(items: HealthEvent[]): HealthEvent | null {
    const upcoming: HealthEvent[] = items
      .filter((item: HealthEvent) => item.nextDate && DateUtils.daysUntil(item.nextDate) >= 0)
      .sort((left: HealthEvent, right: HealthEvent) => left.nextDate.localeCompare(right.nextDate))
    return upcoming.length > 0 ? upcoming[0] : null
  }

  static toDateTimeText(date: Date, hour: number, minute: number): string {
    const merged: Date = new Date(date.getTime())
    merged.setHours(hour, minute, 0, 0)
    const month: string = `${merged.getMonth() + 1}`.padStart(2, '0')
    const day: string = `${merged.getDate()}`.padStart(2, '0')
    const hh: string = `${merged.getHours()}`.padStart(2, '0')
    const mm: string = `${merged.getMinutes()}`.padStart(2, '0')
    return `${merged.getFullYear()}-${month}-${day}T${hh}:${mm}:00`
  }

  static timeLabel(hour: number, minute: number): string {
    return `${`${hour}`.padStart(2, '0')}:${`${minute}`.padStart(2, '0')}`
  }
}
