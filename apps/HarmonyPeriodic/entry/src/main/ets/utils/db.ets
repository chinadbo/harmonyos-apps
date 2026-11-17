import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_periodic.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_FAVORITES: string =
  'CREATE TABLE IF NOT EXISTS favorites (' +
  'atomicNumber INTEGER PRIMARY KEY, ' +
  'created_at TEXT NOT NULL)';

const SQL_CREATE_QUIZ_RECORDS: string =
  'CREATE TABLE IF NOT EXISTS quiz_records (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
  'date TEXT NOT NULL, ' +
  'total INTEGER NOT NULL, ' +
  'correct INTEGER NOT NULL)';

export interface QuizRecord {
  id: number;
  date: string;
  total: number;
  correct: number;
}

export class DbHelper {
  private static instance: DbHelper | null = null;
  private store: relationalStore.RdbStore | null = null;

  static getInstance(): DbHelper {
    if (DbHelper.instance === null) {
      DbHelper.instance = new DbHelper();
    }
    return DbHelper.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.store !== null) {
      return;
    }
    const store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await store.executeSql(SQL_CREATE_FAVORITES);
    await store.executeSql(SQL_CREATE_QUIZ_RECORDS);
    this.store = store;
  }

  private requireStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('DbHelper is not initialized. Call init(context) first.');
    }
    return this.store;
  }

  async addFavorite(atomicNumber: number): Promise<void> {
    const store = this.requireStore();
    const args: Array<relationalStore.ValueType> = [atomicNumber, new Date().toISOString()];
    await store.executeSql(
      'INSERT OR REPLACE INTO favorites (atomicNumber, created_at) VALUES (?, ?)', args);
  }

  async removeFavorite(atomicNumber: number): Promise<void> {
    const store = this.requireStore();
    const args: Array<relationalStore.ValueType> = [atomicNumber];
    await store.executeSql('DELETE FROM favorites WHERE atomicNumber = ?', args);
  }

  async isFavorite(atomicNumber: number): Promise<boolean> {
    const store = this.requireStore();
    const args: Array<relationalStore.ValueType> = [atomicNumber];
    const resultSet = await store.querySql(
      'SELECT atomicNumber FROM favorites WHERE atomicNumber = ?', args);
    try {
      return resultSet.goToFirstRow();
    } finally {
      resultSet.close();
    }
  }

  async getFavoriteAtomicNumbers(): Promise<number[]> {
    const store = this.requireStore();
    const resultSet = await store.querySql(
      'SELECT atomicNumber FROM favorites ORDER BY created_at DESC, atomicNumber ASC');
    const atomicNumbers: number[] = [];
    try {
      const index = resultSet.getColumnIndex('atomicNumber');
      while (resultSet.goToNextRow()) {
        atomicNumbers.push(resultSet.getLong(index));
      }
    } finally {
      resultSet.close();
    }
    return atomicNumbers;
  }

  async insertQuizRecord(date: string, total: number, correct: number): Promise<number> {
    const store = this.requireStore();
    const values: relationalStore.ValuesBucket = {
      date: date,
      total: total,
      correct: correct
    };
    return await store.insert('quiz_records', values);
  }

  async getQuizRecords(): Promise<QuizRecord[]> {
    const store = this.requireStore();
    const resultSet = await store.querySql(
      'SELECT id, date, total, correct FROM quiz_records ORDER BY id DESC');
    const records: QuizRecord[] = [];
    try {
      const idIndex = resultSet.getColumnIndex('id');
      const dateIndex = resultSet.getColumnIndex('date');
      const totalIndex = resultSet.getColumnIndex('total');
      const correctIndex = resultSet.getColumnIndex('correct');
      while (resultSet.goToNextRow()) {
        const record: QuizRecord = {
          id: resultSet.getLong(idIndex),
          date: resultSet.getString(dateIndex),
          total: resultSet.getLong(totalIndex),
          correct: resultSet.getLong(correctIndex)
        };
        records.push(record);
      }
    } finally {
      resultSet.close();
    }
    return records;
  }
}

export const dbHelper: DbHelper = DbHelper.getInstance();
