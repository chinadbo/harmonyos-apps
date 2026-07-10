import { relationalStore } from '@ohos.data.relationalStore';
import { TranslateRecord } from '../model/TranslateRecord';

const DB_NAME = 'translate.db';
const DB_VERSION = 1;
const TABLE_NAME = 'translate_records';

export class DatabaseService {
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: Context;

  constructor(context: Context) {
    this.context = context;
  }

  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.rdbStore = await relationalStore.getRdbStore(this.context, config);
    await this.createTable();
  }

  close(): void {
    if (this.rdbStore) {
      this.rdbStore.close();
      this.rdbStore = null;
    }
  }

  private async createTable(): Promise<void> {
    const sql = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_text TEXT NOT NULL,
      result_text TEXT NOT NULL,
      source_lang TEXT NOT NULL,
      target_lang TEXT NOT NULL,
      is_favorite INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )`;
    await this.rdbStore!.executeSql(sql);
  }

  async insert(record: TranslateRecord): Promise<number> {
    const values = {
      source_text: record.sourceText,
      result_text: record.resultText,
      source_lang: record.sourceLang,
      target_lang: record.targetLang,
      is_favorite: record.isFavorite ? 1 : 0,
      created_at: record.createdAt
    };
    const result = await this.rdbStore!.insert(TABLE_NAME, values);
    return result;
  }

  async queryAll(): Promise<TranslateRecord[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('created_at');
    const result = await this.rdbStore!.query(predicates, [
      'id', 'source_text', 'result_text', 'source_lang', 'target_lang', 'is_favorite', 'created_at'
    ]);
    const records: TranslateRecord[] = [];
    while (result.goToNextRow()) {
      records.push(this.rowToRecord(result));
    }
    result.close();
    return records;
  }

  async queryFavorites(): Promise<TranslateRecord[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('is_favorite', 1).orderByDesc('created_at');
    const result = await this.rdbStore!.query(predicates, [
      'id', 'source_text', 'result_text', 'source_lang', 'target_lang', 'is_favorite', 'created_at'
    ]);
    const records: TranslateRecord[] = [];
    while (result.goToNextRow()) {
      records.push(this.rowToRecord(result));
    }
    result.close();
    return records;
  }

  async updateFavorite(id: number, isFavorite: boolean): Promise<void> {
    const values = { is_favorite: isFavorite ? 1 : 0 };
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await this.rdbStore!.update(values, predicates);
  }

  async delete(id: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await this.rdbStore!.delete(predicates);
  }

  async clearAll(): Promise<void> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    await this.rdbStore!.delete(predicates);
  }

  private rowToRecord(result: relationalStore.ResultSet): TranslateRecord {
    const record = new TranslateRecord(
      result.getString(result.getColumnIndex('source_text')),
      result.getString(result.getColumnIndex('result_text')),
      result.getString(result.getColumnIndex('source_lang')),
      result.getString(result.getColumnIndex('target_lang'))
    );
    record.id = result.getLong(result.getColumnIndex('id'));
    record.isFavorite = result.getLong(result.getColumnIndex('is_favorite')) === 1;
    record.createdAt = result.getLong(result.getColumnIndex('created_at'));
    return record;
  }
}
