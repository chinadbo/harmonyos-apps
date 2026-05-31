import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private store?: relationalStore.RdbStore
  private initPromise?: Promise<relationalStore.RdbStore>

  private constructor() {}

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store
    }
    if (!this.initPromise) {
      this.initPromise = this.createStore(context)
    }
    this.store = await this.initPromise
    return this.store
  }

  private async createStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    const config: relationalStore.StoreConfig = {
      name: 'harmonyplant.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    const store = await relationalStore.getRdbStore(context, config)
    await store.executeSql('CREATE TABLE IF NOT EXISTS plants (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, species TEXT, photoUri TEXT, addedDate TEXT, waterInterval INTEGER DEFAULT 3, fertilizeInterval INTEGER DEFAULT 30, lastWateredAt TEXT, lastFertilizedAt TEXT, reminderId INTEGER, notes TEXT)')
    await store.executeSql('CREATE TABLE IF NOT EXISTS care_records (id INTEGER PRIMARY KEY AUTOINCREMENT, plantId INTEGER NOT NULL, careType TEXT, careDate TEXT, note TEXT)')
    await store.executeSql('CREATE TABLE IF NOT EXISTS plant_diary (id INTEGER PRIMARY KEY AUTOINCREMENT, plantId INTEGER NOT NULL, title TEXT, content TEXT, photoUri TEXT, createdAt TEXT)')
    return store
  }
}
