import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_poem.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_FAVORITES = `CREATE TABLE IF NOT EXISTS favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  poem_id INTEGER NOT NULL,
  note TEXT DEFAULT '',
  tag TEXT DEFAULT '',
  created_at INTEGER NOT NULL
)`;

const SQL_CREATE_HISTORY = `CREATE TABLE IF NOT EXISTS reading_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  poem_id INTEGER NOT NULL UNIQUE,
  view_count INTEGER DEFAULT 1,
  last_viewed INTEGER NOT NULL
)`;

export class DatabaseHelper {
  private static store: relationalStore.RdbStore | null = null;

  static async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (DatabaseHelper.store) {
      return DatabaseHelper.store;
    }
    DatabaseHelper.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await DatabaseHelper.store.executeSql(SQL_CREATE_FAVORITES);
    await DatabaseHelper.store.executeSql(SQL_CREATE_HISTORY);
    return DatabaseHelper.store;
  }
}
