import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

export class DatabaseHelper {
  private static store?: relationalStore.RdbStore;
  private static readonly DB_NAME: string = 'harmony_birth.db';
  private static readonly DB_VERSION: number = 1;

  static async getRdbStore(context: common.Context): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    let config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables(this.store);
    return this.store;
  }

  private static async createTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql('CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, relation TEXT, birthday TEXT NOT NULL, birthday_year INTEGER DEFAULT 0, avatar_color TEXT NOT NULL, reminder_days TEXT NOT NULL, note TEXT, system_contact_id TEXT, created_at INTEGER NOT NULL)');
    await store.executeSql('CREATE TABLE IF NOT EXISTS gifts (id INTEGER PRIMARY KEY AUTOINCREMENT, contact_id INTEGER NOT NULL, name TEXT NOT NULL, price REAL DEFAULT 0, url TEXT, note TEXT, status TEXT NOT NULL, created_at INTEGER NOT NULL)');
  }
}
