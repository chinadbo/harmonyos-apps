import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper();
  private store?: relationalStore.RdbStore;
  private initialized: boolean = false;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance;
  }

  async init(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.initialized && this.store) {
      return this.store;
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmonytune.db',
      securityLevel: relationalStore.SecurityLevel.S1,
      encrypt: false
    };
    try {
      this.store = await relationalStore.getRdbStore(context, config, 1, {
        onCreate: async (store: relationalStore.RdbStore) => {
          await store.executeSql(`CREATE TABLE IF NOT EXISTS songs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            artist TEXT,
            album TEXT,
            duration INTEGER,
            path TEXT UNIQUE NOT NULL,
            cover_path TEXT,
            added_at INTEGER,
            play_count INTEGER DEFAULT 0,
            is_favorite INTEGER DEFAULT 0
          )`);
          await store.executeSql(`CREATE TABLE IF NOT EXISTS playlists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at INTEGER
          )`);
          await store.executeSql(`CREATE TABLE IF NOT EXISTS playlist_songs (
            playlist_id INTEGER NOT NULL,
            song_id INTEGER NOT NULL,
            position INTEGER DEFAULT 0,
            PRIMARY KEY (playlist_id, song_id)
          )`);
        },
        onUpgrade: async (_store: relationalStore.RdbStore, oldVersion: number, newVersion: number) => {
          console.info(`[DatabaseHelper] onUpgrade ${oldVersion} -> ${newVersion}`);
        }
      });
      this.initialized = true;
      return this.store;
    } catch (error) {
      console.error(`[DatabaseHelper] init failed: ${JSON.stringify(error)}`);
      throw error;
    }
  }

  async getStore(context?: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    if (!context) {
      throw new Error('Database not initialized');
    }
    return this.init(context);
  }

  async execute(context: common.UIAbilityContext, sql: string, bindArgs: relationalStore.ValueType[] = []): Promise<void> {
    const store = await this.getStore(context);
    await store.executeSql(sql, bindArgs);
  }

  async clearAll(context: common.UIAbilityContext): Promise<void> {
    const store = await this.getStore(context);
    await store.executeSql('DELETE FROM playlist_songs');
    await store.executeSql('DELETE FROM playlists');
    await store.executeSql('DELETE FROM songs');
  }
}
