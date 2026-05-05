import UIAbilityContext from '@ohos.app.ability.UIAbilityContext';
import relationalStore from '@ohos.data.relationalStore';
import { DB_NAME } from '../common/Constants';

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper();
  private store?: relationalStore.RdbStore;

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance;
  }

  async getStore(context: UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS habit (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT DEFAULT '✅',
      colorIndex INTEGER DEFAULT 0,
      targetDays TEXT DEFAULT '1111111',
      reminderTime TEXT DEFAULT '',
      reminderId INTEGER DEFAULT -1,
      createdAt INTEGER NOT NULL,
      isActive INTEGER DEFAULT 1
    )`);
    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS checkin (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habitId INTEGER NOT NULL,
      checkDate TEXT NOT NULL,
      note TEXT DEFAULT '',
      createdAt INTEGER NOT NULL,
      UNIQUE(habitId, checkDate),
      FOREIGN KEY(habitId) REFERENCES habit(id) ON DELETE CASCADE
    )`);
    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_checkin_date ON checkin(checkDate)');
    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_checkin_habit ON checkin(habitId)');
    return this.store;
  }
}
