/**
 * MovieRepository：影视条目 CRUD、条件查询、观影统计、观看记录与成就查询。
 * 全部为静态函数风格的独立异步函数，内部依赖 DbService.getStore()。
 */
import relationalStore from '@ohos.data.relationalStore';
import { BusinessError } from '@ohos.base';
import {
  MovieItem,
  WatchRecordItem,
  RingSegment,
  BarItem,
  TabCounts,
  CineStatus,
  WatchAction,
  CineCategory,
  ACHIEVEMENT_DEFS,
  categoryColor,
  categoryLabel,
  monthLabel,
  recentMonthStarts
} from '../model/Movie';
import { getStore, movieToBucket, insertWatchRecord } from './DbService';

const MOVIE_TABLE: string = 'movie_item';
const RECORD_TABLE: string = 'watch_record';
const ACHIEVEMENT_TABLE: string = 'achievement';

// ---------------- 行映射 ----------------

function rowToMovie(rs: relationalStore.ResultSet): MovieItem {
  return {
    id: rs.getLong(rs.getColumnIndex('id')),
    title: rs.getString(rs.getColumnIndex('title')),
    category: rs.getString(rs.getColumnIndex('category')),
    status: rs.getString(rs.getColumnIndex('status')),
    rating: rs.getDouble(rs.getColumnIndex('rating')),
    progress: rs.getLong(rs.getColumnIndex('progress')),
    totalEpisodes: rs.getLong(rs.getColumnIndex('totalEpisodes')),
    comment: rs.getString(rs.getColumnIndex('comment')),
    createdTime: rs.getLong(rs.getColumnIndex('createdTime')),
    updatedTime: rs.getLong(rs.getColumnIndex('updatedTime'))
  };
}

function rowToRecord(rs: relationalStore.ResultSet): WatchRecordItem {
  return {
    id: rs.getLong(rs.getColumnIndex('id')),
    movieId: rs.getLong(rs.getColumnIndex('movieId')),
    action: rs.getString(rs.getColumnIndex('action')),
    recordTime: rs.getLong(rs.getColumnIndex('recordTime'))
  };
}

async function queryMovieList(predicates: relationalStore.RdbPredicates): Promise<MovieItem[]> {
  const store = getStore();
  predicates.orderByDesc('updatedTime');
  const rs = await store.query(MOVIE_TABLE, predicates);
  const list: MovieItem[] = [];
  while (rs.goToNextRow()) {
    list.push(rowToMovie(rs));
  }
  rs.close();
  return list;
}

// ---------------- 查询 ----------------

/** 按状态与关键字查询（status/keyword 传空串表示不筛选），按更新时间倒序 */
export async function queryMovies(status: string, keyword: string): Promise<MovieItem[]> {
  const predicates = new relationalStore.RdbPredicates(MOVIE_TABLE);
  if (status !== '') {
    predicates.equalTo('status', status);
  }
  if (keyword !== '') {
    predicates.like('title', `%${keyword}%`);
  }
  return queryMovieList(predicates);
}

export async function getMovieById(id: number): Promise<MovieItem | null> {
  const predicates = new relationalStore.RdbPredicates(MOVIE_TABLE);
  predicates.equalTo('id', id);
  const list = await queryMovieList(predicates);
  if (list.length === 0) {
    return null;
  }
  return list[0];
}

export async function getWatchRecords(movieId: number): Promise<WatchRecordItem[]> {
  const store = getStore();
  const predicates = new relationalStore.RdbPredicates(RECORD_TABLE);
  predicates.equalTo('movieId', movieId).orderByDesc('recordTime');
  const rs = await store.query(RECORD_TABLE, predicates);
  const list: WatchRecordItem[] = [];
  while (rs.goToNextRow()) {
    list.push(rowToRecord(rs));
  }
  rs.close();
  return list;
}

// ---------------- 增 ----------------

export async function insertMovie(movie: MovieItem): Promise<number> {
  const store = getStore();
  const now = Date.now();
  if (movie.createdTime <= 0) {
    movie.createdTime = now;
  }
  movie.updatedTime = movie.createdTime;
  const rowId = await store.insert(MOVIE_TABLE, movieToBucket(movie));
  if (rowId > 0) {
    await insertWatchRecord(rowId, WatchAction.ADD, movie.createdTime);
  }
  return rowId;
}

export async function insertMovies(movies: MovieItem[]): Promise<number> {
  let inserted = 0;
  for (const movie of movies) {
    try {
      const rowId = await insertMovie(movie);
      if (rowId > 0) {
        inserted++;
      }
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] insertMovies(${movie.title}) failed, code=${e.code}`);
    }
  }
  return inserted;
}

// ---------------- 改 ----------------

async function updateColumns(id: number, changes: relationalStore.ValuesBucket): Promise<void> {
  const store = getStore();
  const predicates = new relationalStore.RdbPredicates(MOVIE_TABLE);
  predicates.equalTo('id', id);
  await store.update(changes, predicates);
}

/** 状态流转：更新状态并写入 watch_record */
export async function updateStatus(id: number, newStatus: string): Promise<void> {
  const old = await getMovieById(id);
  if (old === null || old.status === newStatus) {
    return;
  }
  const now = Date.now();
  const changes: relationalStore.ValuesBucket = {
    'status': newStatus,
    'updatedTime': now
  };
  await updateColumns(id, changes);
  await insertWatchRecord(id, WatchAction.STATUS_CHANGE, now);
}

/** 更新评分：写入 watch_record */
export async function updateRating(id: number, rating: number): Promise<void> {
  const old = await getMovieById(id);
  if (old === null || old.rating === rating) {
    return;
  }
  const now = Date.now();
  const changes: relationalStore.ValuesBucket = {
    'rating': rating,
    'updatedTime': now
  };
  await updateColumns(id, changes);
  await insertWatchRecord(id, WatchAction.RATING, now);
}

/** 更新编辑字段（标题/类型/进度/总集数/评论），不产生观看记录 */
export async function updateMovieFields(movie: MovieItem): Promise<void> {
  const now = Date.now();
  const changes: relationalStore.ValuesBucket = {
    'title': movie.title,
    'category': movie.category,
    'progress': movie.progress,
    'totalEpisodes': movie.totalEpisodes,
    'comment': movie.comment,
    'updatedTime': now
  };
  await updateColumns(movie.id, changes);
}

// ---------------- 删 ----------------

export async function deleteMovie(id: number): Promise<void> {
  const store = getStore();
  const predicates = new relationalStore.RdbPredicates(MOVIE_TABLE);
  predicates.equalTo('id', id);
  await store.delete(predicates);
  const recordPredicates = new relationalStore.RdbPredicates(RECORD_TABLE);
  recordPredicates.equalTo('movieId', id);
  await store.delete(recordPredicates);
}

export async function deleteAllData(): Promise<void> {
  const store = getStore();
  await store.executeSql('DELETE FROM movie_item');
  await store.executeSql('DELETE FROM watch_record');
  await store.executeSql('DELETE FROM achievement');
}

// ---------------- 统计 ----------------

export async function getCounts(): Promise<TabCounts> {
  const store = getStore();
  const counts: TabCounts = {
    watching: 0,
    wish: 0,
    watched: 0,
    total: 0
  };
  const rs = await store.querySql('SELECT status, COUNT(*) AS cnt FROM movie_item GROUP BY status');
  while (rs.goToNextRow()) {
    const status = rs.getString(rs.getColumnIndex('status'));
    const cnt = rs.getLong(rs.getColumnIndex('cnt'));
    counts.total += cnt;
    if (status === CineStatus.WATCHING) {
      counts.watching = cnt;
    } else if (status === CineStatus.WISH) {
      counts.wish = cnt;
    } else if (status === CineStatus.WATCHED) {
      counts.watched = cnt;
    }
  }
  rs.close();
  return counts;
}

/** 已看完条目的类型分布（环形图数据） */
export async function getCategorySegments(): Promise<RingSegment[]> {
  const store = getStore();
  const segments: RingSegment[] = [];
  const rs = await store.querySql(
    'SELECT category, COUNT(*) AS cnt FROM movie_item WHERE status = ? GROUP BY category',
    [CineStatus.WATCHED]);
  while (rs.goToNextRow()) {
    const category = rs.getString(rs.getColumnIndex('category'));
    segments.push({
      label: categoryLabel(category),
      value: rs.getLong(rs.getColumnIndex('cnt')),
      color: categoryColor(category)
    });
  }
  rs.close();
  return segments;
}

/** 已看完且有评分条目的平均分（rating>0 参与均分，看过状态计入统计） */
export async function getAverageRating(): Promise<number> {
  const store = getStore();
  const rs = await store.querySql(
    'SELECT AVG(rating) AS avgRating FROM movie_item WHERE status = ? AND rating > 0',
    [CineStatus.WATCHED]);
  let avg = 0;
  if (rs.goToNextRow()) {
    avg = rs.getDouble(rs.getColumnIndex('avgRating'));
  }
  rs.close();
  return avg;
}

/** 近 6 个月每月看完的条目数（柱状图数据） */
export async function getMonthlyBars(monthCount: number): Promise<BarItem[]> {
  const store = getStore();
  const now = Date.now();
  const starts = recentMonthStarts(monthCount, now);
  const bars: BarItem[] = [];
  for (let i = 0; i < starts.length; i++) {
    const start = starts[i];
    const end = i + 1 < starts.length ? starts[i + 1] : now + 1;
    const rs = await store.querySql(
      'SELECT COUNT(*) AS cnt FROM movie_item WHERE status = ? AND updatedTime >= ? AND updatedTime < ?',
      [CineStatus.WATCHED, start, end]);
    let cnt = 0;
    if (rs.goToNextRow()) {
      cnt = rs.getLong(rs.getColumnIndex('cnt'));
    }
    rs.close();
    bars.push({
      label: monthLabel(start),
      value: cnt
    });
  }
  return bars;
}

// ---------------- 成就 ----------------

/** 已解锁成就 -> 解锁时间戳 的映射 */
export async function getUnlockedAchievements(): Promise<Map<string, number>> {
  const store = getStore();
  const result = new Map<string, number>();
  const rs = await store.querySql('SELECT id, unlockedTime FROM achievement');
  while (rs.goToNextRow()) {
    result.set(rs.getString(rs.getColumnIndex('id')), rs.getLong(rs.getColumnIndex('unlockedTime')));
  }
  rs.close();
  return result;
}

/** 检查并解锁新成就，返回本次新解锁的 id 列表 */
export async function checkAchievements(): Promise<string[]> {
  const counts = await getCounts();
  const unlocked = await getUnlockedAchievements();
  const newlyUnlocked: string[] = [];
  const store = getStore();
  const now = Date.now();
  for (const def of ACHIEVEMENT_DEFS) {
    if (counts.watched >= def.threshold && !unlocked.has(def.id)) {
      try {
        const bucket: relationalStore.ValuesBucket = {
          'id': def.id,
          'unlockedTime': now
        };
        await store.insert(ACHIEVEMENT_TABLE, bucket);
        newlyUnlocked.push(def.id);
      } catch (err) {
        const e = err as BusinessError;
        console.error(`[HarmonyCine] unlock ${def.id} failed, code=${e.code}`);
      }
    }
  }
  return newlyUnlocked;
}

/** 判断条目是否为剧集类（显示进度字段） */
export function isSeriesLike(movie: MovieItem): boolean {
  return movie.category === CineCategory.TV || movie.category === CineCategory.ANIME;
}
