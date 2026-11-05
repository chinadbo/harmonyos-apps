/**
 * DbService：RDB 单例 + ready() Promise + 建表 + 首次启动种子灌入 + Preferences 封装。
 * 入口时机：EntryAbility.onCreate 中调用 initDb(context) 注入上下文，
 * 各页面/仓储统一 await dbReady() 后再访问 getStore()。
 */
import relationalStore from '@ohos.data.relationalStore';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { MovieItem, CineStatus } from '../model/Movie';
import { SEED_MOVIES, buildSeedMovie } from './SeedData';

const DB_NAME: string = 'harmonycine.db';
const PREF_NAME: string = 'cine_prefs';
const DAY_MS: number = 24 * 60 * 60 * 1000;

/** Preferences 键名常量 */
export const PREF_KEY_LAST_TAB: string = 'last_tab_index';
export const PREF_KEY_POSTER_OFFSET: string = 'poster_color_offset';

let appContext: common.Context | null = null;
let store: relationalStore.Store | null = null;
let prefs: preferences.Preferences | null = null;
let readyPromise: Promise<void> | null = null;

/** 在 EntryAbility onCreate 中调用，注入应用上下文 */
export function initDb(context: common.Context): void {
  appContext = context;
}

/** 数据库就绪 Promise（幂等，只初始化一次） */
export function dbReady(): Promise<void> {
  if (readyPromise === null) {
    readyPromise = openDb();
  }
  return readyPromise;
}

/** 获取已就绪的 RDB Store（需先 await dbReady()） */
export function getStore(): relationalStore.Store {
  if (store === null) {
    throw new Error('Database is not ready, await dbReady() first');
  }
  return store;
}

async function openDb(): Promise<void> {
  if (appContext === null) {
    throw new Error('DbService is not initialized, call initDb(context) first');
  }
  const config: relationalStore.StoreConfig = {
    name: DB_NAME,
    securityLevel: relationalStore.SecurityLevel.S1
  };
  try {
    store = await relationalStore.getRdbStore(appContext, config);
  } catch (err) {
    const e = err as BusinessError;
    throw new Error(`getRdbStore failed, code=${e.code} message=${e.message}`);
  }
  await createTables();
  await seedIfEmpty();
}

async function createTables(): Promise<void> {
  if (store === null) {
    return;
  }
  const sqlList: string[] = [
    `CREATE TABLE IF NOT EXISTS movie_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category TEXT NOT NULL,
      status TEXT NOT NULL,
      rating REAL DEFAULT 0,
      progress INTEGER DEFAULT 0,
      totalEpisodes INTEGER DEFAULT 0,
      comment TEXT DEFAULT '',
      createdTime INTEGER NOT NULL,
      updatedTime INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS watch_record (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      movieId INTEGER NOT NULL,
      action TEXT NOT NULL,
      recordTime INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS achievement (
      id TEXT PRIMARY KEY,
      unlockedTime INTEGER NOT NULL
    )`
  ];
  for (const sql of sqlList) {
    try {
      await store.executeSql(sql);
    } catch (err) {
      const e = err as BusinessError;
      throw new Error(`executeSql failed, code=${e.code} message=${e.message}`);
    }
  }
}

/** 首次启动检测空表，自动灌入种子库 */
async function seedIfEmpty(): Promise<void> {
  if (store === null) {
    return;
  }
  let count: number = 0;
  try {
    const rs = await store.querySql('SELECT COUNT(*) AS cnt FROM movie_item');
    if (rs.goToNextRow()) {
      count = rs.getLong(rs.getColumnIndex('cnt'));
    }
    rs.close();
  } catch (err) {
    const e = err as BusinessError;
    throw new Error(`query seed count failed, code=${e.code} message=${e.message}`);
  }
  if (count > 0) {
    return;
  }
  const now = Date.now();
  for (let i = 0; i < SEED_MOVIES.length; i++) {
    const seed = SEED_MOVIES[i];
    const movie = buildSeedMovie(seed, now);
    try {
      const rowId = await store.insert('movie_item', movieToBucket(movie));
      if (rowId > 0) {
        // 同步补一条「加入片单」观看记录；已看条目补一条状态流转
        await insertWatchRecord(rowId, 'add', movie.createdTime);
        if (movie.status === CineStatus.WATCHED) {
          await insertWatchRecord(rowId, 'status_change', movie.updatedTime);
        }
      }
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] seed insert failed for ${movie.title}, code=${e.code}`);
    }
  }
}

export function movieToBucket(movie: MovieItem): relationalStore.ValuesBucket {
  const bucket: relationalStore.ValuesBucket = {
    'id': movie.id > 0 ? movie.id : null,
    'title': movie.title,
    'category': movie.category,
    'status': movie.status,
    'rating': movie.rating,
    'progress': movie.progress,
    'totalEpisodes': movie.totalEpisodes,
    'comment': movie.comment,
    'createdTime': movie.createdTime,
    'updatedTime': movie.updatedTime
  };
  return bucket;
}

export async function insertWatchRecord(movieId: number, action: string, recordTime: number): Promise<void> {
  if (store === null) {
    return;
  }
  const bucket: relationalStore.ValuesBucket = {
    'movieId': movieId,
    'action': action,
    'recordTime': recordTime
  };
  try {
    await store.insert('watch_record', bucket);
  } catch (err) {
    const e = err as BusinessError;
    console.error(`[HarmonyCine] insertWatchRecord failed, code=${e.code}`);
  }
}

/** 把「days 天前」换算为时间戳（用于种子与展示辅助） */
export function daysAgo(now: number, days: number): number {
  return now - days * DAY_MS;
}

// ---------------- Preferences 封装 ----------------

async function ensurePrefs(): Promise<preferences.Preferences> {
  if (prefs === null) {
    if (appContext === null) {
      throw new Error('DbService is not initialized');
    }
    const options: preferences.Options = {
      name: PREF_NAME
    };
    prefs = await preferences.getPreferences(appContext, options);
  }
  return prefs;
}

/** 读取数字型偏好值 */
export async function getPrefNumber(key: string, defaultValue: number): Promise<number> {
  try {
    const p = await ensurePrefs();
    return p.getSync(key, defaultValue) as number;
  } catch (err) {
    const e = err as BusinessError;
    console.error(`[HarmonyCine] getPrefNumber(${key}) failed, code=${e.code}`);
    return defaultValue;
  }
}

/** 写入数字型偏好值（立即落盘） */
export async function putPrefNumber(key: string, value: number): Promise<void> {
  try {
    const p = await ensurePrefs();
    await p.put(key, value);
    await p.flush();
  } catch (err) {
    const e = err as BusinessError;
    console.error(`[HarmonyCine] putPrefNumber(${key}) failed, code=${e.code}`);
  }
}
