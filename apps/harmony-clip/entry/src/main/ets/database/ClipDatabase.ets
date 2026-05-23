import relationalStore from '@ohos.data.relationalStore';
import { ClipEntry, ClipType } from '../model/ClipEntry';

const DB_NAME = 'harmonyclip.db';
const TABLE_NAME = 'clip_history';
const DB_VERSION = 1;

const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    content    TEXT    NOT NULL,
    type       TEXT    NOT NULL DEFAULT 'text',
    is_private INTEGER NOT NULL DEFAULT 0,
    is_favorite INTEGER NOT NULL DEFAULT 0,
    create_time INTEGER NOT NULL,
    preview_text TEXT NOT NULL DEFAULT ''
  )
`;

const CREATE_INDEX_SQL = `
  CREATE INDEX IF NOT EXISTS idx_create_time ON ${TABLE_NAME}(create_time DESC)
`;

export class ClipDatabase {
  private static instance: ClipDatabase | null = null;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {}

  static getInstance(): ClipDatabase {
    if (!ClipDatabase.instance) {
      ClipDatabase.instance = new ClipDatabase();
    }
    return ClipDatabase.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.store) {
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1,
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql(CREATE_TABLE_SQL);
    await this.store.executeSql(CREATE_INDEX_SQL);
    await this.migrateIfNeeded();
  }

  private async migrateIfNeeded(): Promise<void> {
    // Reserved for future schema migrations
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('ClipDatabase not initialized. Call init() first.');
    }
    return this.store;
  }

  async insertClip(entry: Omit<ClipEntry, 'id'>): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      content: entry.content,
      type: entry.type,
      is_private: entry.isPrivate ? 1 : 0,
      is_favorite: entry.isFavorite ? 1 : 0,
      create_time: entry.createTime,
      preview_text: entry.previewText,
    };
    return await store.insert(TABLE_NAME, valueBucket);
  }

  async queryHistory(limit: number = 200, offset: number = 0): Promise<ClipEntry[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('create_time');
    predicates.limitAs(limit);
    predicates.offsetAs(offset);
    const resultSet = await store.query(predicates, [
      'id', 'content', 'type', 'is_private', 'is_favorite', 'create_time', 'preview_text'
    ]);
    return this.parseResultSet(resultSet);
  }

  async queryFavorites(): Promise<ClipEntry[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('is_favorite', 1);
    predicates.orderByDesc('create_time');
    const resultSet = await store.query(predicates, [
      'id', 'content', 'type', 'is_private', 'is_favorite', 'create_time', 'preview_text'
    ]);
    return this.parseResultSet(resultSet);
  }

  async searchByKeyword(keyword: string, limit: number = 100): Promise<ClipEntry[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.contains('content', keyword);
    predicates.orderByDesc('create_time');
    predicates.limitAs(limit);
    const resultSet = await store.query(predicates, [
      'id', 'content', 'type', 'is_private', 'is_favorite', 'create_time', 'preview_text'
    ]);
    return this.parseResultSet(resultSet);
  }

  async toggleFavorite(id: number, isFavorite: boolean): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      is_favorite: isFavorite ? 1 : 0,
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.update(valueBucket, predicates);
  }

  async deleteById(id: number): Promise<number> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.delete(predicates);
  }

  async cleanExpired(retentionDays: number): Promise<number> {
    const store = this.getStore();
    const cutoff = Date.now() - retentionDays * 24 * 60 * 60 * 1000;
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.lessThan('create_time', cutoff);
    predicates.equalTo('is_favorite', 0);
    return await store.delete(predicates);
  }

  async clearAllHistory(): Promise<number> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('is_favorite', 0);
    return await store.delete(predicates);
  }

  async existsByContent(content: string): Promise<boolean> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('content', content);
    predicates.limitAs(1);
    const resultSet = await store.query(predicates, ['id']);
    const exists = resultSet.rowCount > 0;
    resultSet.close();
    return exists;
  }

  private parseResultSet(resultSet: relationalStore.ResultSet): ClipEntry[] {
    const entries: ClipEntry[] = [];
    while (resultSet.goToNextRow()) {
      entries.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        type: resultSet.getString(resultSet.getColumnIndex('type')) as ClipType,
        isPrivate: resultSet.getLong(resultSet.getColumnIndex('is_private')) === 1,
        isFavorite: resultSet.getLong(resultSet.getColumnIndex('is_favorite')) === 1,
        createTime: resultSet.getLong(resultSet.getColumnIndex('create_time')),
        previewText: resultSet.getString(resultSet.getColumnIndex('preview_text')),
      });
    }
    resultSet.close();
    return entries;
  }
}
