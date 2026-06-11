import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { DatabaseService } from './DatabaseService'
import { WaterRecord } from '../model/WaterRecord'
import { DailyGoal } from '../model/DailyGoal'

export class WaterService {
  private static instance: WaterService = new WaterService()
  private databaseService: DatabaseService = DatabaseService.getInstance()
  private preferences?: preferences.Preferences
  private readonly preferenceName: string = 'harmony_hydrate_preferences'

  static getInstance(): WaterService {
    return WaterService.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      await this.databaseService.init(context)
      if (!this.preferences) {
        this.preferences = await preferences.getPreferences(context, this.preferenceName)
      }
    } catch (error) {
      console.error(`WaterService init failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  async addRecord(amount: number, timestamp: number = Date.now()): Promise<number> {
    try {
      const date = this.formatDate(timestamp)
      return await this.databaseService.insertRecord(amount, timestamp, date)
    } catch (error) {
      console.error(`Add record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async updateRecord(record: WaterRecord): Promise<void> {
    try {
      record.date = this.formatDate(record.timestamp)
      await this.databaseService.updateRecord(record)
    } catch (error) {
      console.error(`Update water record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async deleteRecord(id: number): Promise<void> {
    try {
      await this.databaseService.deleteRecord(id)
    } catch (error) {
      console.error(`Delete water record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getAllRecords(): Promise<WaterRecord[]> {
    try {
      return await this.databaseService.getAllRecords()
    } catch (error) {
      console.error(`Get all records failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getRecordsByDate(date: string): Promise<WaterRecord[]> {
    try {
      return await this.databaseService.getRecordsByDate(date)
    } catch (error) {
      console.error(`Get records by date failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getTodaySum(): Promise<number> {
    try {
      return await this.databaseService.getDailySum(this.formatDate(Date.now()))
    } catch (error) {
      console.error(`Get today sum failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getDailySum(date: string): Promise<number> {
    try {
      return await this.databaseService.getDailySum(date)
    } catch (error) {
      console.error(`Get daily sum failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getGoal(): Promise<DailyGoal> {
    try {
      const storedAmount = Number(this.preferences?.getSync('goalAmount', 2000))
      const reminderEnabled = Boolean(this.preferences?.getSync('reminderEnabled', false))
      const startHour = Number(this.preferences?.getSync('startHour', 9))
      const endHour = Number(this.preferences?.getSync('endHour', 21))
      const intervalMinutes = Number(this.preferences?.getSync('intervalMinutes', 120))
      return new DailyGoal(storedAmount, reminderEnabled, startHour, endHour, intervalMinutes)
    } catch (error) {
      console.error(`Get goal failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async saveGoal(goal: DailyGoal): Promise<void> {
    try {
      this.preferences?.putSync('goalAmount', goal.amount)
      this.preferences?.putSync('reminderEnabled', goal.reminderEnabled)
      this.preferences?.putSync('startHour', goal.startHour)
      this.preferences?.putSync('endHour', goal.endHour)
      this.preferences?.putSync('intervalMinutes', goal.intervalMinutes)
      await this.preferences?.flush()
    } catch (error) {
      console.error(`Save goal failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async clearData(): Promise<void> {
    try {
      await this.databaseService.clearAllRecords()
    } catch (error) {
      console.error(`Clear data failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getStreak(goalAmount: number): Promise<number> {
    try {
      let streak = 0
      for (let offset = 0; offset < 365; offset++) {
        const targetDate = new Date()
        targetDate.setDate(targetDate.getDate() - offset)
        const date = this.formatDate(targetDate.getTime())
        const total = await this.getDailySum(date)
        if (total >= goalAmount) {
          streak++
        } else {
          break
        }
      }
      return streak
    } catch (error) {
      console.error(`Get streak failed: ${JSON.stringify(error)}`)
      throw error
    }
  }
}
