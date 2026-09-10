import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { AppConstants, LapRecord, SessionDetail, SessionRecord } from '../common/constants'

class SettingValue {
  key: string = ''
  value: string = ''
}

export class DataStore {
  private static instance: DataStore = new DataStore()
  private rdbStore: relationalStore.RdbStore | null = null

  static getInstance(): DataStore {
    return DataStore.instance
  }

  async init(context: common.Context): Promise<void> {
    if (this.rdbStore !== null) {
      return
    }
    const config: relationalStore.StoreConfig = {
      name: AppConstants.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.rdbStore = await relationalStore.getRdbStore(context, config)
    await this.createTables()
  }

  async createSession(name: string, startTime: number, createdAt: number): Promise<number> {
    const store = this.requireStore()
    const values: relationalStore.ValuesBucket = {
      name,
      startTime,
      endTime: 0,
      duration: 0,
      createdAt
    }
    const id = await store.insert(AppConstants.SESSIONS_TABLE, values)
    return Number(id)
  }

  async updateSession(sessionId: number, endTime: number, duration: number): Promise<void> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.SESSIONS_TABLE)
    predicates.equalTo('id', sessionId)
    const values: relationalStore.ValuesBucket = {
      endTime,
      duration
    }
    await store.update(values, predicates)
  }

  async deleteSession(sessionId: number): Promise<void> {
    const store = this.requireStore()
    const lapPredicates = new relationalStore.RdbPredicates(AppConstants.LAPS_TABLE)
    lapPredicates.equalTo('sessionId', sessionId)
    await store.delete(lapPredicates)
    const sessionPredicates = new relationalStore.RdbPredicates(AppConstants.SESSIONS_TABLE)
    sessionPredicates.equalTo('id', sessionId)
    await store.delete(sessionPredicates)
  }

  async getSessionById(sessionId: number): Promise<SessionRecord | null> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.SESSIONS_TABLE)
    predicates.equalTo('id', sessionId)
    const resultSet = await store.query(predicates)
    const sessions = this.mapSessions(resultSet)
    return sessions.length > 0 ? sessions[0] : null
  }

  async getSessionsDesc(): Promise<SessionRecord[]> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.SESSIONS_TABLE)
    predicates.orderByDesc('startTime')
    const resultSet = await store.query(predicates)
    return this.mapSessions(resultSet)
  }

  async getUnfinishedSession(): Promise<SessionRecord | null> {
    const sessions = await this.getSessionsDesc()
    for (let index = 0; index < sessions.length; index++) {
      if (sessions[index].endTime <= 0) {
        return sessions[index]
      }
    }
    return null
  }

  async addLap(sessionId: number, lapNumber: number, lapTime: number, totalTime: number, createdAt: number): Promise<number> {
    const store = this.requireStore()
    const values: relationalStore.ValuesBucket = {
      sessionId,
      lapNumber,
      lapTime,
      totalTime,
      createdAt
    }
    const id = await store.insert(AppConstants.LAPS_TABLE, values)
    return Number(id)
  }

  async getLapsBySessionId(sessionId: number): Promise<LapRecord[]> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.LAPS_TABLE)
    predicates.equalTo('sessionId', sessionId)
    predicates.orderByAsc('lapNumber')
    const resultSet = await store.query(predicates)
    return this.mapLaps(resultSet)
  }

  async getSessionDetail(sessionId: number): Promise<SessionDetail | null> {
    const session = await this.getSessionById(sessionId)
    if (session === null) {
      return null
    }
    const laps = await this.getLapsBySessionId(sessionId)
    return {
      ...session,
      laps
    }
  }

  async upsertSetting(key: string, value: string): Promise<void> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.SETTINGS_TABLE)
    predicates.equalTo('key', key)
    const query = await store.query(predicates)
    const existing = this.mapSettings(query)
    if (existing.length > 0) {
      const updateValues: relationalStore.ValuesBucket = {
        value
      }
      await store.update(updateValues, predicates)
      return
    }
    const values: relationalStore.ValuesBucket = {
      key,
      value
    }
    await store.insert(AppConstants.SETTINGS_TABLE, values)
  }

  async getSetting(key: string): Promise<string> {
    const store = this.requireStore()
    const predicates = new relationalStore.RdbPredicates(AppConstants.SETTINGS_TABLE)
    predicates.equalTo('key', key)
    const resultSet = await store.query(predicates)
    const settings = this.mapSettings(resultSet)
    return settings.length > 0 ? settings[0].value : ''
  }

  async getSettings(keys: string[]): Promise<Record<string, string>> {
    const values: Record<string, string> = {}
    for (let index = 0; index < keys.length; index++) {
      values[keys[index]] = await this.getSetting(keys[index])
    }
    return values
  }

  private requireStore(): relationalStore.RdbStore {
    if (this.rdbStore === null) {
      throw new Error('DataStore not initialized')
    }
    return this.rdbStore
  }

  private async createTables(): Promise<void> {
    const store = this.requireStore()
    await store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${AppConstants.SESSIONS_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        duration INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )`
    )
    await store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${AppConstants.LAPS_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        lapNumber INTEGER NOT NULL,
        lapTime INTEGER NOT NULL,
        totalTime INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )`
    )
    await store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${AppConstants.SETTINGS_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )`
    )
  }

  private mapSessions(resultSet: relationalStore.ResultSet): SessionRecord[] {
    const sessions: SessionRecord[] = []
    try {
      if (resultSet.rowCount <= 0) {
        return sessions
      }
      resultSet.goToFirstRow()
      do {
        sessions.push({
          id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          startTime: Number(resultSet.getLong(resultSet.getColumnIndex('startTime'))),
          endTime: Number(resultSet.getLong(resultSet.getColumnIndex('endTime'))),
          duration: Number(resultSet.getLong(resultSet.getColumnIndex('duration'))),
          createdAt: Number(resultSet.getLong(resultSet.getColumnIndex('createdAt')))
        })
      } while (resultSet.goToNextRow())
    } finally {
      resultSet.close()
    }
    return sessions
  }

  private mapLaps(resultSet: relationalStore.ResultSet): LapRecord[] {
    const laps: LapRecord[] = []
    try {
      if (resultSet.rowCount <= 0) {
        return laps
      }
      resultSet.goToFirstRow()
      do {
        laps.push({
          id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
          sessionId: Number(resultSet.getLong(resultSet.getColumnIndex('sessionId'))),
          lapNumber: Number(resultSet.getLong(resultSet.getColumnIndex('lapNumber'))),
          lapTime: Number(resultSet.getLong(resultSet.getColumnIndex('lapTime'))),
          totalTime: Number(resultSet.getLong(resultSet.getColumnIndex('totalTime'))),
          createdAt: Number(resultSet.getLong(resultSet.getColumnIndex('createdAt')))
        })
      } while (resultSet.goToNextRow())
    } finally {
      resultSet.close()
    }
    return laps
  }

  private mapSettings(resultSet: relationalStore.ResultSet): SettingValue[] {
    const settings: SettingValue[] = []
    try {
      if (resultSet.rowCount <= 0) {
        return settings
      }
      resultSet.goToFirstRow()
      do {
        settings.push({
          key: resultSet.getString(resultSet.getColumnIndex('key')),
          value: resultSet.getString(resultSet.getColumnIndex('value'))
        })
      } while (resultSet.goToNextRow())
    } finally {
      resultSet.close()
    }
    return settings
  }
}

export const dataStore: DataStore = DataStore.getInstance()
