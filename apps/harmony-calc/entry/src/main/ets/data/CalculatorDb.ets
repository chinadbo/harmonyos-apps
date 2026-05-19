import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { HistoryRecord } from '../model/HistoryRecord';

export class CalculatorDb {
  private static store?: relationalStore.RdbStore;
  private static readonly DB_NAME: string = 'harmony_calc.db';
  private static readonly MAX_HISTORY: number = 100;

  private static async getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql('CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, expression TEXT NOT NULL, result TEXT NOT NULL, mode TEXT NOT NULL, created_at INTEGER NOT NULL)');
    return this.store;
  }

  static async insertHistory(context: common.UIAbilityContext, expression: string, result: string, mode: string): Promise<void> {
    const store: relationalStore.RdbStore = await this.getStore(context);
    const values: relationalStore.ValuesBucket = {
      'expression': expression,
      'result': result,
      'mode': mode,
      'created_at': Date.now()
    };
    await store.insert('history', values);
    await this.trimHistory(store);
  }

  static async getHistory(context: common.UIAbilityContext, mode: string = ''): Promise<Array<HistoryRecord>> {
    const store: relationalStore.RdbStore = await this.getStore(context);
    const sql: string = mode.length > 0
      ? 'SELECT id, expression, result, mode, created_at FROM history WHERE mode = ? ORDER BY created_at DESC LIMIT 100'
      : 'SELECT id, expression, result, mode, created_at FROM history ORDER BY created_at DESC LIMIT 100';
    const params: Array<string> = mode.length > 0 ? [mode] : [];
    const resultSet: relationalStore.ResultSet = await store.querySql(sql, params);
    const records: Array<HistoryRecord> = [];

    try {
      if (resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
        do {
          records.push(new HistoryRecord(
            Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
            resultSet.getString(resultSet.getColumnIndex('expression')),
            resultSet.getString(resultSet.getColumnIndex('result')),
            resultSet.getString(resultSet.getColumnIndex('mode')),
            Number(resultSet.getLong(resultSet.getColumnIndex('created_at')))
          ));
        } while (resultSet.goToNextRow());
      }
    } finally {
      resultSet.close();
    }

    return records;
  }

  static async clearHistory(context: common.UIAbilityContext, mode: string = ''): Promise<void> {
    const store: relationalStore.RdbStore = await this.getStore(context);
    if (mode.length > 0) {
      await store.executeSql('DELETE FROM history WHERE mode = ?', [mode]);
      return;
    }
    await store.executeSql('DELETE FROM history');
  }

  private static async trimHistory(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(
      'DELETE FROM history WHERE id NOT IN (SELECT id FROM history ORDER BY created_at DESC LIMIT ' + this.MAX_HISTORY.toString() + ')'
    );
  }
}
