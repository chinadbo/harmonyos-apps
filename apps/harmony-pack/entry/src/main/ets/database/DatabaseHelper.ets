import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'

export default class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper()
  private store: relationalStore.RdbStore | null = null
  private initializing: Promise<relationalStore.RdbStore> | null = null

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance
  }

  async getStore(context: common.Context): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store
    }
    if (this.initializing) {
      return this.initializing
    }
    this.initializing = this.createStore(context)
    this.store = await this.initializing
    this.initializing = null
    return this.store
  }

  private async createStore(context: common.Context): Promise<relationalStore.RdbStore> {
    const config: relationalStore.StoreConfig = {
      name: 'harmonypack.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    const store = await relationalStore.getRdbStore(context, config)
    await this.createTables(store)
    return store
  }

  private async createTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        destination TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        trip_type TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT,
        reminder_24_id INTEGER DEFAULT 0,
        reminder_2_id INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `)
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id INTEGER NOT NULL,
        template_id TEXT DEFAULT '',
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        importance INTEGER DEFAULT 1,
        note TEXT DEFAULT '',
        is_packed INTEGER DEFAULT 0,
        is_missed INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `)
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        trip_type TEXT NOT NULL,
        is_builtin INTEGER DEFAULT 0,
        item_count INTEGER DEFAULT 0,
        item_payload TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `)
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status)')
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_trips_start_date ON trips(start_date)')
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_items_trip_id ON items(trip_id)')
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_items_category ON items(category)')
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_templates_builtin ON templates(is_builtin)')
  }
}
