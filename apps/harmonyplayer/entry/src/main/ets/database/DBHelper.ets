import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

export class DBHelper {
  private static instance: DBHelper = new DBHelper();
  private rdb: relationalStore.RdbStore | null = null;

  static getInstance(): DBHelper {
    return DBHelper.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.rdb !== null) {
      return this.rdb;
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmonyplayer.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.rdb = await relationalStore.getRdbStore(context, config);
    await this.rdb.executeSql('CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, song_uri TEXT NOT NULL UNIQUE, added_at INTEGER)');
    await this.rdb.executeSql('CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, song_uri TEXT NOT NULL, played_at INTEGER)');
    await this.rdb.executeSql('CREATE TABLE IF NOT EXISTS playlist_cache (position INTEGER PRIMARY KEY, song_uri TEXT NOT NULL)');
    return this.rdb;
  }

  getRdb(): relationalStore.RdbStore {
    if (this.rdb === null) {
      throw new Error('RdbStore has not been initialized');
    }
    return this.rdb;
  }
}
