import relationalStore from '@ohos.data.relationalStore';
import { Constants } from '../utils/Constants';
import { Bookmark } from '../model/Bookmark';
import { HistoryItem } from '../model/HistoryItem';

const TAG = 'BrowserDatabase';

export class BrowserDatabase {
  private static instance: BrowserDatabase;
  private rdbStore: relationalStore.RdbStore | undefined;

  private constructor() {}

  static getInstance(): BrowserDatabase {
    if (!BrowserDatabase.instance) {
      BrowserDatabase.instance = new BrowserDatabase();
    }
    return BrowserDatabase.instance;
  }

  async init(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: Constants.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
    } catch (e) {
      console.error(TAG, 'init database failed', JSON.stringify(e));
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;
    const createBookmarks = `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_BOOKMARKS} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      url TEXT NOT NULL,
      title TEXT NOT NULL,
      folder TEXT,
      createTime INTEGER
    )`;
    const createHistory = `CREATE TABLE IF NOT EXISTS ${Constants.TABLE_HISTORY} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      url TEXT NOT NULL,
      title TEXT NOT NULL,
      visitTime INTEGER
    )`;
    await this.rdbStore.executeSql(createBookmarks);
    await this.rdbStore.executeSql(createHistory);
  }

  async insertBookmark(bookmark: Bookmark): Promise<number> {
    if (!this.rdbStore) return -1;
    const valueBucket = {
      url: bookmark.url,
      title: bookmark.title,
      folder: bookmark.folder,
      createTime: bookmark.createTime
    };
    return await this.rdbStore.insert(Constants.TABLE_BOOKMARKS, valueBucket);
  }

  async deleteBookmark(id: number): Promise<void> {
    if (!this.rdbStore) return;
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_BOOKMARKS);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }

  async queryBookmarks(folder?: string): Promise<Bookmark[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_BOOKMARKS);
    if (folder) {
      predicates.equalTo('folder', folder);
    }
    predicates.orderByDesc('createTime');
    const resultSet = await this.rdbStore.query(predicates, ['id', 'url', 'title', 'folder', 'createTime']);
    const bookmarks: Bookmark[] = [];
    while (resultSet.goToNextRow()) {
      bookmarks.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        folder: resultSet.getString(resultSet.getColumnIndex('folder')),
        createTime: resultSet.getLong(resultSet.getColumnIndex('createTime'))
      });
    }
    resultSet.close();
    return bookmarks;
  }

  async insertHistory(item: HistoryItem): Promise<number> {
    if (!this.rdbStore) return -1;
    const valueBucket = {
      url: item.url,
      title: item.title,
      visitTime: item.visitTime
    };
    return await this.rdbStore.insert(Constants.TABLE_HISTORY, valueBucket);
  }

  async queryHistory(): Promise<HistoryItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_HISTORY);
    predicates.orderByDesc('visitTime');
    const resultSet = await this.rdbStore.query(predicates, ['id', 'url', 'title', 'visitTime']);
    const history: HistoryItem[] = [];
    while (resultSet.goToNextRow()) {
      history.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        url: resultSet.getString(resultSet.getColumnIndex('url')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        visitTime: resultSet.getLong(resultSet.getColumnIndex('visitTime'))
      });
    }
    resultSet.close();
    return history;
  }

  async clearHistory(): Promise<void> {
    if (!this.rdbStore) return;
    const predicates = new relationalStore.RdbPredicates(Constants.TABLE_HISTORY);
    await this.rdbStore.delete(predicates);
  }

  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = undefined;
    }
  }
}
