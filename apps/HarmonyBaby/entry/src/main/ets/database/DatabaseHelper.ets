import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import {
  FeedRecord,
  DiaperRecord,
  SleepRecord,
  GrowthRecord,
  DaySummary,
  PeriodRecords,
  FeedType
} from '../model/Models';
import { TimeUtils } from '../utils/TimeUtils';

const DOMAIN: number = 0x0101;
const TAG: string = 'HarmonyBabyDB';
const DB_NAME: string = 'harmonybaby.db';

const CREATE_FEEDS: string = `CREATE TABLE IF NOT EXISTS feeds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  amount REAL DEFAULT 0,
  duration INTEGER DEFAULT 0,
  note TEXT DEFAULT '',
  startTime INTEGER NOT NULL,
  endTime INTEGER NOT NULL
)`;

const CREATE_DIAPERS: string = `CREATE TABLE IF NOT EXISTS diapers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  note TEXT DEFAULT '',
  changeTime INTEGER NOT NULL
)`;

const CREATE_SLEEPS: string = `CREATE TABLE IF NOT EXISTS sleeps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  startTime INTEGER NOT NULL,
  endTime INTEGER NOT NULL DEFAULT 0,
  quality TEXT DEFAULT '',
  note TEXT DEFAULT ''
)`;

const CREATE_GROWTH: string = `CREATE TABLE IF NOT EXISTS growth (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  measureTime INTEGER NOT NULL,
  weight REAL DEFAULT 0,
  height REAL DEFAULT 0,
  headCirc REAL DEFAULT 0,
  note TEXT DEFAULT ''
)`;

/**
 * 本地关系型数据库（RDB）单例，管理 feeds / diapers / sleeps / growth 四张表。
 * 所有时间字段均为毫秒时间戳（Number）。
 */
export class DatabaseHelper {
  private static instance: DatabaseHelper | null = null;
  private rdb: relationalStore.RdbStore | null = null;
  private initTask: Promise<void> | null = null;

  private constructor() {
  }

  static getInstance(): DatabaseHelper {
    if (DatabaseHelper.instance === null) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  init(context: common.UIAbilityContext): void {
    if (this.initTask !== null) {
      return;
    }
    this.initTask = this.doInit(context);
  }

  private async doInit(context: common.UIAbilityContext): Promise<void> {
    try {
      const store = await relationalStore.getRdbStore(context, {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      });
      await store.execute(CREATE_FEEDS);
      await store.execute(CREATE_DIAPERS);
      await store.execute(CREATE_SLEEPS);
      await store.execute(CREATE_GROWTH);
      this.rdb = store;
      hilog.info(DOMAIN, TAG, 'rdb store ready');
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'rdb init failed: %{public}s', JSON.stringify(e));
    }
  }

  private async ready(): Promise<relationalStore.RdbStore> {
    if (this.initTask !== null) {
      await this.initTask;
    }
    if (this.rdb === null) {
      throw new Error('rdb store is unavailable');
    }
    return this.rdb;
  }

  // ---------------- 喂养 feeds ----------------

  async insertFeed(record: FeedRecord): Promise<number> {
    const rdb = await this.ready();
    const values: relationalStore.ValuesBucket = {
      'type': record.type,
      'amount': record.amount,
      'duration': record.duration,
      'note': record.note,
      'startTime': record.startTime,
      'endTime': record.endTime
    };
    return await rdb.insert('feeds', values);
  }

  async deleteFeed(id: number): Promise<number> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('feeds');
    pred.equalTo('id', id);
    return await rdb.delete(pred);
  }

  async queryFeedsBetween(startMs: number, endMs: number): Promise<FeedRecord[]> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('feeds');
    pred.greaterThanOrEqualTo('startTime', startMs)
      .and()
      .lessThan('startTime', endMs)
      .orderByDesc('startTime');
    const rs = await rdb.query(pred);
    const list: FeedRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readFeed(rs));
    }
    rs.close();
    return list;
  }

  async queryTodayFeeds(): Promise<FeedRecord[]> {
    const start = TimeUtils.todayStart();
    return await this.queryFeedsBetween(start, start + TimeUtils.DAY);
  }

  private readFeed(rs: relationalStore.ResultSet): FeedRecord {
    const r = new FeedRecord();
    r.id = rs.getLong(rs.getColumnIndex('id'));
    r.type = rs.getString(rs.getColumnIndex('type'));
    r.amount = rs.getDouble(rs.getColumnIndex('amount'));
    r.duration = rs.getLong(rs.getColumnIndex('duration'));
    r.note = rs.getString(rs.getColumnIndex('note'));
    r.startTime = rs.getLong(rs.getColumnIndex('startTime'));
    r.endTime = rs.getLong(rs.getColumnIndex('endTime'));
    return r;
  }

  // ---------------- 尿布 diapers ----------------

  async insertDiaper(record: DiaperRecord): Promise<number> {
    const rdb = await this.ready();
    const values: relationalStore.ValuesBucket = {
      'type': record.type,
      'note': record.note,
      'changeTime': record.changeTime
    };
    return await rdb.insert('diapers', values);
  }

  async deleteDiaper(id: number): Promise<number> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('diapers');
    pred.equalTo('id', id);
    return await rdb.delete(pred);
  }

  async queryDiapersBetween(startMs: number, endMs: number): Promise<DiaperRecord[]> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('diapers');
    pred.greaterThanOrEqualTo('changeTime', startMs)
      .and()
      .lessThan('changeTime', endMs)
      .orderByDesc('changeTime');
    const rs = await rdb.query(pred);
    const list: DiaperRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readDiaper(rs));
    }
    rs.close();
    return list;
  }

  async queryTodayDiapers(): Promise<DiaperRecord[]> {
    const start = TimeUtils.todayStart();
    return await this.queryDiapersBetween(start, start + TimeUtils.DAY);
  }

  private readDiaper(rs: relationalStore.ResultSet): DiaperRecord {
    const r = new DiaperRecord();
    r.id = rs.getLong(rs.getColumnIndex('id'));
    r.type = rs.getString(rs.getColumnIndex('type'));
    r.note = rs.getString(rs.getColumnIndex('note'));
    r.changeTime = rs.getLong(rs.getColumnIndex('changeTime'));
    return r;
  }

  // ---------------- 睡眠 sleeps ----------------

  /** 开始一次睡眠：endTime 为 0 表示进行中 */
  async startSleep(startTime: number): Promise<number> {
    const rdb = await this.ready();
    const values: relationalStore.ValuesBucket = {
      'startTime': startTime,
      'endTime': 0,
      'quality': '',
      'note': ''
    };
    return await rdb.insert('sleeps', values);
  }

  /** 结束睡眠，自动计算时长 */
  async finishSleep(id: number, endTime: number, quality: string): Promise<number> {
    const rdb = await this.ready();
    const values: relationalStore.ValuesBucket = {
      'endTime': endTime,
      'quality': quality
    };
    const pred = new relationalStore.RdbPredicates('sleeps');
    pred.equalTo('id', id);
    return await rdb.update(values, pred);
  }

  async deleteSleep(id: number): Promise<number> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('sleeps');
    pred.equalTo('id', id);
    return await rdb.delete(pred);
  }

  /** 获取进行中的睡眠（endTime == 0），无则返回 null */
  async getOngoingSleep(): Promise<SleepRecord | null> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('sleeps');
    pred.equalTo('endTime', 0).orderByDesc('startTime').limitAs(1);
    const rs = await rdb.query(pred);
    let result: SleepRecord | null = null;
    if (rs.goToNextRow()) {
      result = this.readSleep(rs);
    }
    rs.close();
    return result;
  }

  async querySleepsBetween(startMs: number, endMs: number): Promise<SleepRecord[]> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('sleeps');
    pred.greaterThanOrEqualTo('startTime', startMs)
      .and()
      .lessThan('startTime', endMs)
      .orderByDesc('startTime');
    const rs = await rdb.query(pred);
    const list: SleepRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readSleep(rs));
    }
    rs.close();
    return list;
  }

  async queryTodaySleeps(): Promise<SleepRecord[]> {
    const start = TimeUtils.todayStart();
    return await this.querySleepsBetween(start, start + TimeUtils.DAY);
  }

  private readSleep(rs: relationalStore.ResultSet): SleepRecord {
    const r = new SleepRecord();
    r.id = rs.getLong(rs.getColumnIndex('id'));
    r.startTime = rs.getLong(rs.getColumnIndex('startTime'));
    r.endTime = rs.getLong(rs.getColumnIndex('endTime'));
    r.quality = rs.getString(rs.getColumnIndex('quality'));
    r.note = rs.getString(rs.getColumnIndex('note'));
    return r;
  }

  // ---------------- 成长 growth ----------------

  async insertGrowth(record: GrowthRecord): Promise<number> {
    const rdb = await this.ready();
    const values: relationalStore.ValuesBucket = {
      'measureTime': record.measureTime,
      'weight': record.weight,
      'height': record.height,
      'headCirc': record.headCirc,
      'note': record.note
    };
    return await rdb.insert('growth', values);
  }

  async deleteGrowth(id: number): Promise<number> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('growth');
    pred.equalTo('id', id);
    return await rdb.delete(pred);
  }

  /** 按测量时间正序，用于绘制成长曲线 */
  async queryGrowthBetween(startMs: number, endMs: number): Promise<GrowthRecord[]> {
    const rdb = await this.ready();
    const pred = new relationalStore.RdbPredicates('growth');
    pred.greaterThanOrEqualTo('measureTime', startMs)
      .and()
      .lessThan('measureTime', endMs)
      .orderByAsc('measureTime');
    const rs = await rdb.query(pred);
    const list: GrowthRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readGrowth(rs));
    }
    rs.close();
    return list;
  }

  async queryAllGrowth(): Promise<GrowthRecord[]> {
    const pred = new relationalStore.RdbPredicates('growth');
    pred.greaterThanOrEqualTo('measureTime', 0).orderByAsc('measureTime');
    const rdb = await this.ready();
    const rs = await rdb.query(pred);
    const list: GrowthRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readGrowth(rs));
    }
    rs.close();
    return list;
  }

  private readGrowth(rs: relationalStore.ResultSet): GrowthRecord {
    const r = new GrowthRecord();
    r.id = rs.getLong(rs.getColumnIndex('id'));
    r.measureTime = rs.getLong(rs.getColumnIndex('measureTime'));
    r.weight = rs.getDouble(rs.getColumnIndex('weight'));
    r.height = rs.getDouble(rs.getColumnIndex('height'));
    r.headCirc = rs.getDouble(rs.getColumnIndex('headCirc'));
    r.note = rs.getString(rs.getColumnIndex('note'));
    return r;
  }

  // ---------------- 聚合查询 ----------------

  /** 查询一段时间内四类记录的集合（看板 / 月历共用） */
  async queryPeriodRecords(startMs: number, endMs: number): Promise<PeriodRecords> {
    const result = new PeriodRecords();
    result.feeds = await this.queryFeedsBetween(startMs, endMs);
    result.diapers = await this.queryDiapersBetween(startMs, endMs);
    result.sleeps = await this.querySleepsBetween(startMs, endMs);
    result.growth = await this.queryGrowthBetween(startMs, endMs);
    return result;
  }

  /** 最近 n 天逐日统计（含今天），索引 0 为最旧一天 */
  async queryDaySummaries(n: number): Promise<DaySummary[]> {
    const todayStart = TimeUtils.todayStart();
    const rangeStart = todayStart - (n - 1) * TimeUtils.DAY;
    const now = Date.now();
    const records = await this.queryPeriodRecords(rangeStart, rangeStart + n * TimeUtils.DAY);

    const summaries: DaySummary[] = [];
    for (let i = 0; i < n; i++) {
      const s = new DaySummary();
      s.startMs = rangeStart + i * TimeUtils.DAY;
      if (s.startMs === todayStart) {
        s.label = '今';
      } else {
        s.label = TimeUtils.weekdayShort(s.startMs);
      }
      summaries.push(s);
    }

    const feeds = records.feeds;
    for (let i = 0; i < feeds.length; i++) {
      const r = feeds[i];
      const idx = Math.floor((TimeUtils.dayStart(r.startTime) - rangeStart) / TimeUtils.DAY);
      if (idx >= 0 && idx < summaries.length) {
        summaries[idx].feedCount++;
        if (r.type === FeedType.Bottle || r.type === FeedType.Solid) {
          summaries[idx].feedMl += r.amount;
        }
      }
    }
    const diapers = records.diapers;
    for (let i = 0; i < diapers.length; i++) {
      const r = diapers[i];
      const idx = Math.floor((TimeUtils.dayStart(r.changeTime) - rangeStart) / TimeUtils.DAY);
      if (idx >= 0 && idx < summaries.length) {
        summaries[idx].diaperCount++;
      }
    }
    const sleeps = records.sleeps;
    for (let i = 0; i < sleeps.length; i++) {
      const r = sleeps[i];
      const idx = Math.floor((TimeUtils.dayStart(r.startTime) - rangeStart) / TimeUtils.DAY);
      if (idx >= 0 && idx < summaries.length) {
        const end = r.endTime > 0 ? r.endTime : now;
        summaries[idx].sleepMs += end - r.startTime;
      }
    }
    return summaries;
  }

  /** 近 n 天总喂养毫升数（母乳按次计） */
  static calcTotalFeedMl(feeds: FeedRecord[]): number {
    let total = 0;
    for (let i = 0; i < feeds.length; i++) {
      if (feeds[i].type === FeedType.Bottle || feeds[i].type === FeedType.Solid) {
        total += feeds[i].amount;
      }
    }
    return total;
  }

  /** 近 n 天总睡眠毫秒数（进行中的算到当前） */
  static calcTotalSleepMs(sleeps: SleepRecord[]): number {
    const now = Date.now();
    let total = 0;
    for (let i = 0; i < sleeps.length; i++) {
      const end = sleeps[i].endTime > 0 ? sleeps[i].endTime : now;
      total += end - sleeps[i].startTime;
    }
    return total;
  }
}

/** 构造一条喂养记录（纯函数，页面侧使用） */
export function makeFeedRecord(type: string, amount: number, duration: number, note: string): FeedRecord {
  const r = new FeedRecord();
  r.type = type;
  r.amount = amount;
  r.duration = duration;
  r.note = note;
  const now = Date.now();
  r.startTime = now - duration;
  r.endTime = now;
  return r;
}

/** 构造一条尿布记录 */
export function makeDiaperRecord(type: string, note: string): DiaperRecord {
  const r = new DiaperRecord();
  r.type = type;
  r.note = note;
  r.changeTime = Date.now();
  return r;
}
