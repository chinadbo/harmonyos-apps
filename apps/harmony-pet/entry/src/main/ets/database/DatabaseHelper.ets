import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper()
  private store: relationalStore.RdbStore | null = null

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance
  }

  async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store !== null) {
      return this.store
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmonypet.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.store = await relationalStore.getRdbStore(context, config)
    await this.createTables(this.store)
    return this.store
  }

  private async createTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(`CREATE TABLE IF NOT EXISTS pets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      species TEXT NOT NULL,
      breed TEXT NOT NULL,
      birth_date TEXT NOT NULL,
      gender TEXT NOT NULL,
      avatar_uri TEXT,
      created_at INTEGER NOT NULL
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS weight_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pet_id INTEGER NOT NULL,
      weight REAL NOT NULL,
      record_date TEXT NOT NULL,
      note TEXT,
      created_at INTEGER NOT NULL
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS feed_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pet_id INTEGER NOT NULL,
      food_type TEXT NOT NULL,
      amount REAL NOT NULL,
      unit TEXT NOT NULL,
      feed_time TEXT NOT NULL,
      note TEXT,
      created_at INTEGER NOT NULL
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS health_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pet_id INTEGER NOT NULL,
      event_type TEXT NOT NULL,
      title TEXT NOT NULL,
      event_date TEXT NOT NULL,
      next_date TEXT,
      hospital TEXT,
      note TEXT,
      reminder_id INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS pet_photos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pet_id INTEGER NOT NULL,
      photo_uri TEXT NOT NULL,
      shot_date TEXT NOT NULL,
      note TEXT,
      created_at INTEGER NOT NULL
    )`)
  }
}
