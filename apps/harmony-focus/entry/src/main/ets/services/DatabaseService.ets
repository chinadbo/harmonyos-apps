import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { AppDefaults } from '../common/Constants'
import { Task } from '../model/Task'
import { PomodoroRecord } from '../model/PomodoroRecord'
import { AppSettings } from '../model/AppSettings'

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private store?: relationalStore.RdbStore
  private context?: common.UIAbilityContext

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  async init(context?: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return
    }
    if (context) {
      this.context = context
    }
    if (!this.context) {
      return
    }
    const config: relationalStore.StoreConfig = {
      name: AppDefaults.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.store = await relationalStore.getRdbStore(this.context, config, AppDefaults.DATABASE_VERSION)
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, note TEXT, is_completed INTEGER DEFAULT 0, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, estimated_pomodoros INTEGER DEFAULT 1, completed_pomodoros INTEGER DEFAULT 0)')
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS pomodoro_records (id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER DEFAULT 0, mode TEXT NOT NULL, duration_seconds INTEGER NOT NULL, start_time INTEGER NOT NULL, end_time INTEGER NOT NULL, completed INTEGER DEFAULT 1, date_key TEXT NOT NULL)')
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY, focus_minutes INTEGER NOT NULL, short_break_minutes INTEGER NOT NULL, long_break_minutes INTEGER NOT NULL, long_break_interval INTEGER NOT NULL, white_noise_type TEXT NOT NULL, notification_enabled INTEGER NOT NULL)')
    await this.ensureDefaultSettings()
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('DatabaseService not initialized')
    }
    return this.store
  }

  private async ensureDefaultSettings(): Promise<void> {
    const existing: AppSettings = await this.getSettings()
    if (existing.id === 1) {
      return
    }
    await this.saveSettings(new AppSettings())
  }

  private async resultSetToRows(resultSet: relationalStore.ResultSet): Promise<Record<string, Object | string | number | boolean>[]> {
    const rows: Record<string, Object | string | number | boolean>[] = []
    if (resultSet.rowCount <= 0) {
      resultSet.close()
      return rows
    }
    const columns: string[] = resultSet.columnNames
    resultSet.goToFirstRow()
    do {
      const row: Record<string, Object | string | number | boolean> = {}
      columns.forEach((column: string, index: number) => {
        row[column] = resultSet.getString(index)
      })
      rows.push(row)
    } while (resultSet.goToNextRow())
    resultSet.close()
    return rows
  }

  async getTasks(): Promise<Task[]> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql('SELECT * FROM tasks ORDER BY is_completed ASC, updated_at DESC')
    const rows = await this.resultSetToRows(resultSet)
    return rows.map((row: Record<string, Object | string | number | boolean>) => Task.fromRow(row))
  }

  async addTask(task: Task): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'title': task.title,
      'note': task.note,
      'is_completed': task.isCompleted ? 1 : 0,
      'created_at': task.createdAt,
      'updated_at': task.updatedAt,
      'estimated_pomodoros': task.estimatedPomodoros,
      'completed_pomodoros': task.completedPomodoros
    }
    return await this.getStore().insert('tasks', values)
  }

  async updateTask(task: Task): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('id', task.id)
    await this.getStore().update({
      'title': task.title,
      'note': task.note,
      'is_completed': task.isCompleted ? 1 : 0,
      'updated_at': task.updatedAt,
      'estimated_pomodoros': task.estimatedPomodoros,
      'completed_pomodoros': task.completedPomodoros
    }, predicates)
  }

  async deleteTask(taskId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('id', taskId)
    await this.getStore().delete(predicates)
  }

  async incrementTaskPomodoro(taskId: number): Promise<void> {
    await this.getStore().executeSql(`UPDATE tasks SET completed_pomodoros = completed_pomodoros + 1, updated_at = ${Date.now()} WHERE id = ${taskId}`)
  }

  async addRecord(record: PomodoroRecord): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'task_id': record.taskId,
      'mode': record.mode,
      'duration_seconds': record.durationSeconds,
      'start_time': record.startTime,
      'end_time': record.endTime,
      'completed': record.completed ? 1 : 0,
      'date_key': record.dateKey
    }
    return await this.getStore().insert('pomodoro_records', values)
  }

  async getRecentRecords(limit: number = 30): Promise<PomodoroRecord[]> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql(`SELECT * FROM pomodoro_records ORDER BY end_time DESC LIMIT ${limit}`)
    const rows = await this.resultSetToRows(resultSet)
    return rows.map((row: Record<string, Object | string | number | boolean>) => PomodoroRecord.fromRow(row))
  }

  async getDailyFocusCounts(days: number = 30): Promise<Record<string, number>> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql(`SELECT date_key, COUNT(*) AS focus_count FROM pomodoro_records WHERE mode = 'FOCUS' AND completed = 1 GROUP BY date_key ORDER BY date_key DESC LIMIT ${days}`)
    const rows = await this.resultSetToRows(resultSet)
    const values: Record<string, number> = {}
    rows.forEach((row: Record<string, Object | string | number | boolean>) => {
      values[String(row['date_key'])] = Number(row['focus_count'] ?? 0)
    })
    return values
  }

  async getModeSummary(): Promise<Record<string, number>> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql('SELECT mode, COUNT(*) AS count FROM pomodoro_records WHERE completed = 1 GROUP BY mode')
    const rows = await this.resultSetToRows(resultSet)
    const summary: Record<string, number> = {
      FOCUS: 0,
      SHORT_BREAK: 0,
      LONG_BREAK: 0
    }
    rows.forEach((row: Record<string, Object | string | number | boolean>) => {
      summary[String(row['mode'])] = Number(row['count'] ?? 0)
    })
    return summary
  }

  async getSettings(): Promise<AppSettings> {
    const resultSet: relationalStore.ResultSet = await this.getStore().querySql('SELECT * FROM settings WHERE id = 1')
    if (resultSet.rowCount <= 0) {
      resultSet.close()
      return new AppSettings(0)
    }
    const rows = await this.resultSetToRows(resultSet)
    if (rows.length === 0) {
      return new AppSettings(0)
    }
    return AppSettings.fromRow(rows[0])
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    await this.getStore().executeSql('DELETE FROM settings WHERE id = 1')
    await this.getStore().insert('settings', {
      'id': 1,
      'focus_minutes': settings.focusMinutes,
      'short_break_minutes': settings.shortBreakMinutes,
      'long_break_minutes': settings.longBreakMinutes,
      'long_break_interval': settings.longBreakInterval,
      'white_noise_type': settings.whiteNoiseType,
      'notification_enabled': settings.notificationEnabled ? 1 : 0
    })
  }
}

export const databaseService: DatabaseService = DatabaseService.getInstance()
