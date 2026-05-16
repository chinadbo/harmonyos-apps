import { DatabaseService } from '../service/DatabaseService'
import { SensorService } from '../service/SensorService'

export class HomeViewModel {
  private todaySteps: number = 0
  private todayCalories: number = 0
  private todayDuration: number = 0

  async loadTodayData(): Promise<void> {
    const today = this.formatDate(new Date())
    const stats = await DatabaseService.getInstance().getDailyStats(today)
    this.todaySteps = SensorService.getInstance().getTodaySteps() + stats.totalSteps
    this.todayCalories = stats.totalCalories
    this.todayDuration = stats.totalDuration
  }

  updateCurrentSteps(sensorSteps: number): void {
    this.todaySteps = sensorSteps
  }

  getTodaySteps(): number {
    return this.todaySteps
  }

  getTodayCalories(): number {
    return this.todayCalories
  }

  getTodayDuration(): number {
    return this.todayDuration
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
