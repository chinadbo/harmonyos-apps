import relationalStore from '@ohos.data.relationalStore';
import { SleepRecord } from '../model/SleepRecord';
import common from '@ohos.app.ability.common';

export interface SleepRecordInput {
  sleepTime: number;
  wakeTime: number;
  duration: number;
  quality: number;
  note: string;
  createdAt: number;
}

const DB_NAME = 'harmonysleep.db';
const TABLE_NAME = 'sleep_records';
const CREATE_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sleep_time INTEGER NOT NULL,
  wake_time INTEGER NOT NULL,
  duration INTEGER NOT NULL,
  quality INTEGER DEFAULT 0,
  note TEXT DEFAULT '',
  created_at INTEGER NOT NULL
)`;

class DatabaseService {
  private static _instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore | null = null;

  static instance(): DatabaseService {
    if (!DatabaseService._instance) {
      DatabaseService._instance = new DatabaseService();
    }
    return DatabaseService._instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.rdbStore.executeSql(CREATE_TABLE_SQL, []);
      await this.rdbStore.executeSql(
        `CREATE INDEX IF NOT EXISTS idx_sleep_time ON ${TABLE_NAME}(sleep_time DESC)`, []);
    } catch (err) {
      console.error('[DatabaseService] init error:', JSON.stringify(err));
    }
  }

  async insertRecord(record: SleepRecordInput): Promise<number> {
    if (!this.rdbStore) return -1;
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        sleep_time: record.sleepTime,
        wake_time: record.wakeTime,
        duration: record.duration,
        quality: record.quality,
        note: record.note,
        created_at: record.createdAt
      };
      const rowId = await this.rdbStore.insert(TABLE_NAME, valueBucket);
      return rowId;
    } catch (err) {
      console.error('[DatabaseService] insertRecord error:', JSON.stringify(err));
      return -1;
    }
  }

  async updateQuality(id: number, quality: number, note: string): Promise<void> {
    if (!this.rdbStore) return;
    try {
      const valueBucket: relationalStore.ValuesBucket = { quality, note };
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo('id', id);
      await this.rdbStore.update(valueBucket, predicates);
    } catch (err) {
      console.error('[DatabaseService] updateQuality error:', JSON.stringify(err));
    }
  }

  async deleteRecord(id: number): Promise<void> {
    if (!this.rdbStore) return;
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo('id', id);
      await this.rdbStore.delete(predicates);
    } catch (err) {
      console.error('[DatabaseService] deleteRecord error:', JSON.stringify(err));
    }
  }

  private rowToRecord(rs: relationalStore.ResultSet): SleepRecord {
    return {
      id: rs.getLong(rs.getColumnIndex('id')),
      sleepTime: rs.getLong(rs.getColumnIndex('sleep_time')),
      wakeTime: rs.getLong(rs.getColumnIndex('wake_time')),
      duration: rs.getLong(rs.getColumnIndex('duration')),
      quality: rs.getLong(rs.getColumnIndex('quality')),
      note: rs.getString(rs.getColumnIndex('note')),
      createdAt: rs.getLong(rs.getColumnIndex('created_at'))
    };
  }

  async getRecords(limit: number, offset: number): Promise<SleepRecord[]> {
    if (!this.rdbStore) return [];
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.orderByDesc('sleep_time').limitAs(limit).offsetAs(offset);
      const rs = await this.rdbStore.query(predicates, ['id','sleep_time','wake_time','duration','quality','note','created_at']);
      const result: SleepRecord[] = [];
      while (rs.goToNextRow()) {
        result.push(this.rowToRecord(rs));
      }
      rs.close();
      return result;
    } catch (err) {
      console.error('[DatabaseService] getRecords error:', JSON.stringify(err));
      return [];
    }
  }

  async getRecordsInRange(from: number, to: number): Promise<SleepRecord[]> {
    if (!this.rdbStore) return [];
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.greaterThanOrEqualTo('sleep_time', from)
        .and()
        .lessThanOrEqualTo('sleep_time', to)
        .orderByDesc('sleep_time');
      const rs = await this.rdbStore.query(predicates, ['id','sleep_time','wake_time','duration','quality','note','created_at']);
      const result: SleepRecord[] = [];
      while (rs.goToNextRow()) {
        result.push(this.rowToRecord(rs));
      }
      rs.close();
      return result;
    } catch (err) {
      console.error('[DatabaseService] getRecordsInRange error:', JSON.stringify(err));
      return [];
    }
  }

  async getTodayRecord(): Promise<SleepRecord | null> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStart = today.getTime();
    const todayEnd = todayStart + 86400000;
    const records = await this.getRecordsInRange(todayStart, todayEnd);
    return records.length > 0 ? records[0] : null;
  }

  async getWeeklyStats(): Promise<SleepRecord[]> {
    const weekAgo = Date.now() - 7 * 86400000;
    return this.getRecordsInRange(weekAgo, Date.now());
  }

  async getMonthlyStats(): Promise<SleepRecord[]> {
    const monthAgo = Date.now() - 30 * 86400000;
    return this.getRecordsInRange(monthAgo, Date.now());
  }
}

export default DatabaseService;
