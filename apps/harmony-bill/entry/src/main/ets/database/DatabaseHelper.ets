import relationalStore from '@ohos.data.relationalStore';

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper();
  private store?: relationalStore.RdbStore;
  private context?: any;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance;
  }

  setContext(context: any): void {
    this.context = context;
  }

  async getStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    if (!this.context) {
      throw new Error('Database context is not initialized');
    }

    this.store = await relationalStore.getRdbStore(this.context, {
      name: 'harmony_bill.db',
      securityLevel: relationalStore.SecurityLevel.S1
    });

    await this.store.executeSql('CREATE TABLE IF NOT EXISTS groups (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, scene TEXT DEFAULT \'other\', created_at INTEGER NOT NULL, is_settled INTEGER DEFAULT 0)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS members (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, name TEXT NOT NULL, color_index INTEGER DEFAULT 0)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS bills (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, title TEXT NOT NULL, amount INTEGER NOT NULL, payer_id INTEGER NOT NULL, category TEXT DEFAULT \'其他\', split_type TEXT DEFAULT \'equal\', created_at INTEGER NOT NULL, note TEXT DEFAULT \'\')');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS bill_splits (id INTEGER PRIMARY KEY AUTOINCREMENT, bill_id INTEGER NOT NULL, member_id INTEGER NOT NULL, amount INTEGER NOT NULL)');
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS settlements (id INTEGER PRIMARY KEY AUTOINCREMENT, group_id INTEGER NOT NULL, from_member_id INTEGER NOT NULL, to_member_id INTEGER NOT NULL, amount INTEGER NOT NULL, is_paid INTEGER DEFAULT 0, paid_at INTEGER DEFAULT 0)');

    return this.store;
  }
}
