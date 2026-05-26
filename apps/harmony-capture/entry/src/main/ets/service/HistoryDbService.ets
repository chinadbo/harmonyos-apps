import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { HistoryRecord } from '../model/HistoryRecord';

const DB_NAME: string = 'harmony_capture.db';
const TABLE_NAME: string = 'annotate_history';
const SQL_CREATE_TABLE: string = 'CREATE TABLE IF NOT EXISTS annotate_history (id INTEGER PRIMARY KEY AUTOINCREMENT, image_path TEXT NOT NULL, saved_path TEXT NOT NULL, thumbnail_uri TEXT NOT NULL, created_at INTEGER NOT NULL)';

export class HistoryDbService {
  private static instance: HistoryDbService = new HistoryDbService();
  private store?: relationalStore.RdbStore;

  static getInstance(): HistoryDbService {
    return HistoryDbService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      AppStorage.setOrCreate('dbStore', this.store);
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql(SQL_CREATE_TABLE);
    AppStorage.setOrCreate('dbStore', this.store);
  }

  getStore(): relationalStore.RdbStore {
    if (this.store) {
      return this.store;
    }
    const appStore = AppStorage.get('dbStore') as relationalStore.RdbStore;
    if (!appStore) {
      throw new Error('RdbStore is not initialized');
    }
    this.store = appStore;
    return this.store;
  }

  async insertRecord(record: HistoryRecord): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'image_path': record.imagePath,
      'saved_path': record.savedPath,
      'thumbnail_uri': record.thumbnailUri,
      'created_at': record.createdAt
    };
    return this.getStore().insert(TABLE_NAME, values);
  }

  async queryAll(): Promise<HistoryRecord[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('created_at');
    const result = await this.getStore().query(predicates);
    const records: HistoryRecord[] = [];
    while (result.goToNextRow()) {
      records.push({
        id: result.getLong(result.getColumnIndex('id')),
        imagePath: result.getString(result.getColumnIndex('image_path')),
        savedPath: result.getString(result.getColumnIndex('saved_path')),
        thumbnailUri: result.getString(result.getColumnIndex('thumbnail_uri')),
        createdAt: result.getLong(result.getColumnIndex('created_at'))
      });
    }
    result.close();
    return records;
  }

  async deleteRecord(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    return this.getStore().delete(predicates);
  }
}

export default HistoryDbService.getInstance();
