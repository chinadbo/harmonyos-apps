import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Constants } from '../common/Constants';

export class DatabaseHelper {
  private static instance?: DatabaseHelper;
  private context?: common.UIAbilityContext;
  private store?: relationalStore.RdbStore;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    this.context = context;
    if (this.store) {
      return this.store;
    }
    const config: relationalStore.StoreConfig = {
      name: Constants.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables();
    return this.store;
  }

  async getStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    if (!this.context) {
      throw new Error('DatabaseHelper has not been initialized');
    }
    return this.initialize(this.context);
  }

  private async createTables(): Promise<void> {
    if (!this.store) {
      return;
    }
    await this.store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${Constants.FOOD_TABLE} (` +
      `id INTEGER PRIMARY KEY AUTOINCREMENT, ` +
      `name TEXT NOT NULL, ` +
      `quantity REAL NOT NULL, ` +
      `unit TEXT NOT NULL, ` +
      `category TEXT NOT NULL, ` +
      `expiryDate TEXT NOT NULL, ` +
      `storageArea TEXT NOT NULL, ` +
      `note TEXT, ` +
      `createdAt INTEGER NOT NULL, ` +
      `updatedAt INTEGER NOT NULL)`
    );
    await this.store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${Constants.SHOPPING_TABLE} (` +
      `id INTEGER PRIMARY KEY AUTOINCREMENT, ` +
      `foodItemId INTEGER DEFAULT 0, ` +
      `name TEXT NOT NULL, ` +
      `quantityText TEXT NOT NULL, ` +
      `completed INTEGER NOT NULL DEFAULT 0, ` +
      `createdAt INTEGER NOT NULL)`
    );
  }
}
