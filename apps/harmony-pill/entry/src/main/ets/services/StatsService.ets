import { pillDatabase } from './PillDatabase'

export interface WeeklyStatsResult {
  daily: Array<{ label: string; planned: number; taken: number }>
  complianceRate: number
  totalMedicines: number
  totalSchedules: number
  streakDays: number
}

export class StatsService {
  async getWeeklyStats(): Promise<WeeklyStatsResult> {
    const today = new Date()
    const day = today.getDay() === 0 ? 7 : today.getDay()
    const start = new Date(today.getTime())
    start.setDate(today.getDate() - day + 1)
    const end = new Date(start.getTime())
    end.setDate(start.getDate() + 6)

    const items = await pillDatabase.getWeeklyStats(this.formatDate(start), this.formatDate(end))
    const totalPlanned = items.reduce((sum: number, item) => sum + item.planned, 0)
    const totalTaken = items.reduce((sum: number, item) => sum + item.taken, 0)

    return {
      daily: items.map((item) => ({
        label: item.date.slice(5),
        planned: item.planned,
        taken: item.taken
      })),
      complianceRate: totalPlanned === 0 ? 0 : Math.round(totalTaken * 100 / totalPlanned),
      totalMedicines: await pillDatabase.getTotalMedicineCount(),
      totalSchedules: await pillDatabase.getTotalScheduleCount(),
      streakDays: await this.getStreakDays()
    }
  }

  async getComplianceRate(): Promise<number> {
    const stats = await this.getWeeklyStats()
    return stats.complianceRate
  }

  async getStreakDays(): Promise<number> {
    let streak = 0
    let current = new Date()
    while (true) {
      const records = await pillDatabase.getRecordsByDate(this.formatDate(current))
      if (records.length === 0 || records.some((record) => record.status !== 1)) {
        break
      }
      streak++
      current.setDate(current.getDate() - 1)
    }
    return streak
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}

export const statsService = new StatsService()
