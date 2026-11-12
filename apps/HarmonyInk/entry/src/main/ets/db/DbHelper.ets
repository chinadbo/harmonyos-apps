import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { Constants } from '../common/Constants';
import { CharStat, DayStat, OverallStats, PracticeRecord } from '../model/PracticeRecord';

const DOMAIN: number = 0x0000;
const TAG: string = 'HarmonyInk-db';

/**
 * RDB 单例封装：practice 表 + 聚合查询。
 * 表结构见 architecture.md：
 * id / char / score / stroke_count / duration_ms / created_at
 */
export class DbHelper {
  private static instance: DbHelper | undefined = undefined;
  private store: relationalStore.RdbStore | undefined = undefined;
  private initializing: Promise<void> | undefined = undefined;

  static getInstance(): DbHelper {
    if (DbHelper.instance === undefined) {
      DbHelper.instance = new DbHelper();
    }
    return DbHelper.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store !== undefined) {
      return;
    }
    if (this.initializing !== undefined) {
      return this.initializing;
    }
    this.initializing = this.open(context);
    await this.initializing;
    this.initializing = undefined;
  }

  private async open(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: Constants.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config);
      await store.executeSql(Constants.SQL_CREATE_PRACTICE);
      this.store = store;
      hilog.info(DOMAIN, TAG, 'rdb ready');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'open rdb failed: %{public}s', JSON.stringify(err));
    }
  }

  private getStore(): relationalStore.RdbStore | undefined {
    return this.store;
  }

  async insertRecord(record: PracticeRecord): Promise<boolean> {
    const store = this.getStore();
    if (store === undefined) {
      return false;
    }
    try {
      const values: relationalStore.ValuesBucket = {
        'char': record.char,
        'score': record.score,
        'stroke_count': record.strokeCount,
        'duration_ms': record.durationMs,
        'created_at': record.createdAt
      };
      await store.insert(Constants.TABLE_PRACTICE, values);
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'insert failed: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  /** 每字聚合：最佳分 / 次数 / 平均分 */
  async getCharStats(): Promise<CharStat[]> {
    const result: CharStat[] = [];
    const store = this.getStore();
    if (store === undefined) {
      return result;
    }
    const sql: string =
      'SELECT char, MAX(score) AS best_score, COUNT(*) AS attempts, ' +
      'AVG(score) AS avg_score, MAX(created_at) AS last_time ' +
      'FROM practice GROUP BY char ORDER BY best_score DESC';
    try {
      const rs: relationalStore.ResultSet = await store.querySql(sql);
      while (rs.goToNextRow()) {
        const item: CharStat = {
          char: rs.getString(rs.getColumnIndex('char')),
          bestScore: rs.getLong(rs.getColumnIndex('best_score')),
          attempts: rs.getLong(rs.getColumnIndex('attempts')),
          avgScore: Math.round(rs.getDouble(rs.getColumnIndex('avg_score'))),
          lastTime: rs.getLong(rs.getColumnIndex('last_time'))
        };
        result.push(item);
      }
      rs.close();
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'char stats failed: %{public}s', JSON.stringify(err));
    }
    return result;
  }

  async getRecentRecords(limit: number): Promise<PracticeRecord[]> {
    const result: PracticeRecord[] = [];
    const store = this.getStore();
    if (store === undefined) {
      return result;
    }
    try {
      const rs: relationalStore.ResultSet = await store.querySql(
        'SELECT id, char, score, stroke_count, duration_ms, created_at ' +
        'FROM practice ORDER BY created_at DESC LIMIT ?', [limit]);
      while (rs.goToNextRow()) {
        const record: PracticeRecord = {
          id: rs.getLong(rs.getColumnIndex('id')),
          char: rs.getString(rs.getColumnIndex('char')),
          score: rs.getLong(rs.getColumnIndex('score')),
          strokeCount: rs.getLong(rs.getColumnIndex('stroke_count')),
          durationMs: rs.getLong(rs.getColumnIndex('duration_ms')),
          createdAt: rs.getLong(rs.getColumnIndex('created_at'))
        };
        result.push(record);
      }
      rs.close();
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'recent records failed: %{public}s', JSON.stringify(err));
    }
    return result;
  }

  async getRecordsForChar(char: string, limit: number): Promise<PracticeRecord[]> {
    const result: PracticeRecord[] = [];
    const store = this.getStore();
    if (store === undefined) {
      return result;
    }
    try {
      const rs: relationalStore.ResultSet = await store.querySql(
        'SELECT id, char, score, stroke_count, duration_ms, created_at ' +
        'FROM practice WHERE char = ? ORDER BY created_at DESC LIMIT ?', [char, limit]);
      while (rs.goToNextRow()) {
        const record: PracticeRecord = {
          id: rs.getLong(rs.getColumnIndex('id')),
          char: rs.getString(rs.getColumnIndex('char')),
          score: rs.getLong(rs.getColumnIndex('score')),
          strokeCount: rs.getLong(rs.getColumnIndex('stroke_count')),
          durationMs: rs.getLong(rs.getColumnIndex('duration_ms')),
          createdAt: rs.getLong(rs.getColumnIndex('created_at'))
        };
        result.push(record);
      }
      rs.close();
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'char records failed: %{public}s', JSON.stringify(err));
    }
    return result;
  }

  /** 最近 days 天的按天聚合（热力图） */
  async getDailyStats(days: number): Promise<DayStat[]> {
    const result: DayStat[] = [];
    const store = this.getStore();
    if (store === undefined) {
      return result;
    }
    try {
      const start: Date = new Date();
      start.setHours(0, 0, 0, 0);
      start.setDate(start.getDate() - (days - 1));
      const startTs: number = start.getTime();
      const sql: string =
        "SELECT strftime('%Y-%m-%d', created_at / 1000, 'unixepoch', 'localtime') AS day, " +
        'COUNT(*) AS count, AVG(score) AS avg_score FROM practice ' +
        'WHERE created_at >= ? GROUP BY day ORDER BY day ASC';
      const rs: relationalStore.ResultSet = await store.querySql(sql, [startTs]);
      while (rs.goToNextRow()) {
        const item: DayStat = {
          dayKey: rs.getString(rs.getColumnIndex('day')),
          count: rs.getLong(rs.getColumnIndex('count')),
          avgScore: Math.round(rs.getDouble(rs.getColumnIndex('avg_score')))
        };
        result.push(item);
      }
      rs.close();
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'daily stats failed: %{public}s', JSON.stringify(err));
    }
    return result;
  }

  async getOverallStats(): Promise<OverallStats> {
    const stats: OverallStats = {
      totalAttempts: 0,
      totalChars: 0,
      avgScore: 0,
      todayCount: 0,
      masteredCount: 0
    };
    const store = this.getStore();
    if (store === undefined) {
      return stats;
    }
    try {
      const rs: relationalStore.ResultSet = await store.querySql(
        'SELECT COUNT(*) AS total, COUNT(DISTINCT char) AS chars, ' +
        'COALESCE(AVG(score), 0) AS avg_score FROM practice');
      if (rs.goToNextRow()) {
        stats.totalAttempts = rs.getLong(rs.getColumnIndex('total'));
        stats.totalChars = rs.getLong(rs.getColumnIndex('chars'));
        stats.avgScore = Math.round(rs.getDouble(rs.getColumnIndex('avg_score')));
      }
      rs.close();

      const today: Date = new Date();
      today.setHours(0, 0, 0, 0);
      const todayRs: relationalStore.ResultSet = await store.querySql(
        'SELECT COUNT(*) AS count FROM practice WHERE created_at >= ?', [today.getTime()]);
      if (todayRs.goToNextRow()) {
        stats.todayCount = todayRs.getLong(todayRs.getColumnIndex('count'));
      }
      todayRs.close();

      const charStats: CharStat[] = await this.getCharStats();
      let mastered: number = 0;
      for (let i = 0; i < charStats.length; i++) {
        if (charStats[i].bestScore >= Constants.MASTER_SCORE &&
          charStats[i].attempts >= Constants.MASTER_TIMES) {
          mastered++;
        }
      }
      stats.masteredCount = mastered;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'overall stats failed: %{public}s', JSON.stringify(err));
    }
    return stats;
  }

  async getTotalCount(): Promise<number> {
    const store = this.getStore();
    if (store === undefined) {
      return 0;
    }
    try {
      const rs: relationalStore.ResultSet = await store.querySql(
        'SELECT COUNT(*) AS count FROM practice');
      let count: number = 0;
      if (rs.goToNextRow()) {
        count = rs.getLong(rs.getColumnIndex('count'));
      }
      rs.close();
      return count;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'total count failed: %{public}s', JSON.stringify(err));
      return 0;
    }
  }

  async clearAll(): Promise<boolean> {
    const store = this.getStore();
    if (store === undefined) {
      return false;
    }
    try {
      await store.executeSql('DELETE FROM practice');
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'clear failed: %{public}s', JSON.stringify(err));
      return false;
    }
  }
}
