import { WaterService } from './WaterService'
import { DayStats, WeekStats } from '../model/WeekStats'

export class StatsService {
  private static instance: StatsService = new StatsService()
  private waterService: WaterService = WaterService.getInstance()

  static getInstance(): StatsService {
    return StatsService.instance
  }

  async getWeekStats(goalAmount: number): Promise<WeekStats> {
    try {
      const items: DayStats[] = []
      let completedDays = 0
      let totalIntake = 0

      for (let index = 6; index >= 0; index--) {
        const date = new Date()
        date.setDate(date.getDate() - index)
        const formattedDate = this.waterService.formatDate(date.getTime())
        const total = await this.waterService.getDailySum(formattedDate)
        items.push(new DayStats(formattedDate, total, goalAmount))
        totalIntake += total
        if (total >= goalAmount) {
          completedDays++
        }
      }

      const weeklyAverage = Math.round(totalIntake / 7)
      const completionRate = Math.round((completedDays / 7) * 100)
      return new WeekStats(items, weeklyAverage, completionRate, totalIntake)
    } catch (error) {
      console.error(`Get week stats failed: ${JSON.stringify(error)}`)
      throw error
    }
  }
}
