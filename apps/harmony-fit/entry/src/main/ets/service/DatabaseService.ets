import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { DailyStats, WorkoutRecord } from '../model/WorkoutRecord'

class QueryResultRow {
  id: number = 0
  type: string = ''
  duration: number = 0
  calories: number = 0
  steps: number = 0
  date: string = ''
  startTime: number = 0
  note: string = ''
}

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private rdbStore: relationalStore.RdbStore | null = null
  private readonly tableName: string = 'workout_records'

  private constructor() {
  }

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  async initDB(context: common.Context): Promise<void> {
    if (this.rdbStore !== null) {
      return
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmonyfit.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.rdbStore = await relationalStore.getRdbStore(context, config)
    await this.rdbStore.executeSql(
      `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        steps INTEGER NOT NULL,
        date TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        note TEXT
      )`
    )
  }

  async insertRecord(record: WorkoutRecord): Promise<number> {
    if (this.rdbStore === null) {
      throw new Error('Database not initialized')
    }
    const valueBucket: relationalStore.ValuesBucket = {
      type: record.type,
      duration: record.duration,
      calories: record.calories,
      steps: record.steps,
      date: record.date,
      startTime: record.startTime,
      note: record.note
    }
    const id = await this.rdbStore.insert(this.tableName, valueBucket)
    return Number(id)
  }

  async queryByDate(date: string): Promise<WorkoutRecord[]> {
    if (this.rdbStore === null) {
      return []
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('date', date)
    predicates.orderByDesc('startTime')
    const result = await this.rdbStore.query(predicates)
    return this.mapResultSet(result)
  }

  async queryByDateRange(startDate: string, endDate: string): Promise<WorkoutRecord[]> {
    if (this.rdbStore === null) {
      return []
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.between('date', startDate, endDate)
    predicates.orderByAsc('date')
    predicates.orderByAsc('startTime')
    const result = await this.rdbStore.query(predicates)
    return this.mapResultSet(result)
  }

  async getDailyStats(date: string): Promise<DailyStats> {
    const records = await this.queryByDate(date)
    let totalSteps = 0
    let totalCalories = 0
    let totalDuration = 0
    for (let i = 0; i < records.length; i++) {
      totalSteps += records[i].steps
      totalCalories += records[i].calories
      totalDuration += records[i].duration
    }
    return {
      date,
      totalSteps,
      totalCalories,
      totalDuration,
      recordCount: records.length
    }
  }

  async getWeeklyStats(): Promise<DailyStats[]> {
    const dates: string[] = []
    const now = new Date()
    for (let i = 6; i >= 0; i--) {
      const day = new Date(now.getTime())
      day.setDate(now.getDate() - i)
      dates.push(this.formatDate(day))
    }

    const statsList: DailyStats[] = []
    for (let i = 0; i < dates.length; i++) {
      const stats = await this.getDailyStats(dates[i])
      statsList.push(stats)
    }
    return statsList
  }

  async deleteRecord(id: number): Promise<void> {
    if (this.rdbStore === null) {
      return
    }
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    await this.rdbStore.delete(predicates)
  }

  private mapResultSet(resultSet: relationalStore.ResultSet): WorkoutRecord[] {
    const records: WorkoutRecord[] = []
    try {
      if (resultSet.rowCount <= 0) {
        return records
      }
      resultSet.goToFirstRow()
      do {
        const row: WorkoutRecord = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          type: resultSet.getString(resultSet.getColumnIndex('type')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          calories: resultSet.getLong(resultSet.getColumnIndex('calories')),
          steps: resultSet.getLong(resultSet.getColumnIndex('steps')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          startTime: resultSet.getLong(resultSet.getColumnIndex('startTime')),
          note: resultSet.getString(resultSet.getColumnIndex('note'))
        }
        records.push(row)
      } while (resultSet.goToNextRow())
    } finally {
      resultSet.close()
    }
    return records
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
