import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Problem } from './Problem';
import { LearningRecord, STATUS_DONE, STATUS_MASTERED } from './Record';
import { PROBLEM_SEEDS, ProblemSeed } from '../data/problemset';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmonyalgo.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const PROBLEM_COLUMNS: string[] = ['id', 'title', 'category', 'difficulty', 'description',
  'analysis', 'code_arkts', 'code_python', 'tags'];

/** 全局学习统计 */
export class LearnStats {
  total: number = 0;
  done: number = 0;
  mastered: number = 0;
  favorites: number = 0;
  wrong: number = 0;
}

/** 分类进度 */
export class CategoryStat {
  category: string;
  total: number;
  done: number;

  constructor(category: string, total: number, done: number) {
    this.category = category;
    this.total = total;
    this.done = done;
  }
}

/** 近 7 日趋势数据 */
export class TrendData {
  labels: string[];
  values: number[];

  constructor(labels: string[], values: number[]) {
    this.labels = labels;
    this.values = values;
  }
}

/**
 * RDB 数据库封装（单例）
 * 4 张表：problems / records / favorites / notes
 */
export class Database {
  private static instance: Database | null = null;
  private store: relationalStore.RdbStore | null = null;
  private ready: boolean = false;
  private initPromise: Promise<void> | null = null;

  static getInstance(): Database {
    if (Database.instance === null) {
      Database.instance = new Database();
    }
    return Database.instance;
  }

  /** 初始化：建表 + 首次导入题库（并发调用会复用同一 Promise） */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.ready && this.store !== null) {
      return;
    }
    if (this.initPromise === null) {
      this.initPromise = this.doInit(context);
    }
    await this.initPromise;
  }

  private async doInit(context: common.UIAbilityContext): Promise<void> {
    this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await this.createTables();
    await this.importProblemsIfEmpty();
    this.ready = true;
  }

  isReady(): boolean {
    return this.ready && this.store !== null;
  }

  private async createTables(): Promise<void> {
    const store = this.store;
    if (store === null) {
      return;
    }
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS problems (' +
        'id INTEGER PRIMARY KEY, title TEXT, category TEXT, difficulty INTEGER, ' +
        'description TEXT, analysis TEXT, code_arkts TEXT, code_python TEXT, tags TEXT)');
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS records (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, problem_id INTEGER UNIQUE, ' +
        'status INTEGER, wrong_count INTEGER, updated_at INTEGER)');
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS favorites (' +
        'problem_id INTEGER PRIMARY KEY, created_at INTEGER)');
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS notes (' +
        'problem_id INTEGER PRIMARY KEY, content TEXT, updated_at INTEGER)');
  }

  /** 题库为空时导入内置题库 */
  private async importProblemsIfEmpty(): Promise<void> {
    const store = this.store;
    if (store === null) {
      return;
    }
    const count = await this.countTable('problems');
    if (count > 0) {
      return;
    }
    await store.beginTransaction();
    try {
      for (let i = 0; i < PROBLEM_SEEDS.length; i++) {
        const seed: ProblemSeed = PROBLEM_SEEDS[i];
        const bucket: relationalStore.ValuesBucket = {
          'id': seed.id,
          'title': seed.title,
          'category': seed.category,
          'difficulty': seed.difficulty,
          'description': seed.description,
          'analysis': seed.analysis,
          'code_arkts': seed.codeArkts,
          'code_python': seed.codePython,
          'tags': seed.tags
        };
        await store.insert('problems', bucket);
      }
      await store.commit();
    } catch (err) {
      await store.rollBack();
    }
  }

  private async countTable(table: string): Promise<number> {
    const store = this.store;
    if (store === null) {
      return 0;
    }
    const predicates = new relationalStore.RdbPredicates(table);
    const rs = await store.query(predicates, ['count(*) AS c']);
    let count = 0;
    if (rs.goToFirstRow()) {
      count = rs.getLong(rs.getColumnIndex('c'));
    }
    rs.close();
    return count;
  }

  private readProblem(rs: relationalStore.ResultSet): Problem {
    return new Problem(
      rs.getLong(rs.getColumnIndex('id')),
      rs.getString(rs.getColumnIndex('title')),
      rs.getString(rs.getColumnIndex('category')),
      rs.getLong(rs.getColumnIndex('difficulty')),
      rs.getString(rs.getColumnIndex('description')),
      rs.getString(rs.getColumnIndex('analysis')),
      rs.getString(rs.getColumnIndex('code_arkts')),
      rs.getString(rs.getColumnIndex('code_python')),
      rs.getString(rs.getColumnIndex('tags'))
    );
  }

  /** 根据分类 / 难度 / 关键字查询题目（category 为「全部」表示不限，difficulty 为 0 表示不限） */
  async queryProblems(category: string, difficulty: number, keyword: string): Promise<Problem[]> {
    const store = this.store;
    if (store === null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('problems');
    if (category.length > 0 && category !== '全部') {
      predicates.equalTo('category', category);
    }
    if (difficulty > 0) {
      predicates.equalTo('difficulty', difficulty);
    }
    predicates.orderByAsc('id');
    const rs = await store.query(predicates, PROBLEM_COLUMNS);
    const list: Problem[] = [];
    while (rs.goToNextRow()) {
      list.push(this.readProblem(rs));
    }
    rs.close();
    const kw = keyword.trim();
    if (kw.length === 0) {
      return list;
    }
    const filtered: Problem[] = [];
    for (let i = 0; i < list.length; i++) {
      const p = list[i];
      if (p.title.indexOf(kw) >= 0 || p.tags.indexOf(kw) >= 0 || p.category.indexOf(kw) >= 0) {
        filtered.push(p);
      }
    }
    return filtered;
  }

  async getProblemById(id: number): Promise<Problem | null> {
    const store = this.store;
    if (store === null) {
      return null;
    }
    const predicates = new relationalStore.RdbPredicates('problems');
    predicates.equalTo('id', id);
    const rs = await store.query(predicates, PROBLEM_COLUMNS);
    let problem: Problem | null = null;
    if (rs.goToFirstRow()) {
      problem = this.readProblem(rs);
    }
    rs.close();
    return problem;
  }

  /** 按给定 id 顺序返回题目 */
  async getProblemsByIds(ids: number[]): Promise<Problem[]> {
    const store = this.store;
    if (store === null || ids.length === 0) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('problems');
    predicates.in('id', ids);
    const rs = await store.query(predicates, PROBLEM_COLUMNS);
    const map: Map<number, Problem> = new Map<number, Problem>();
    while (rs.goToNextRow()) {
      const p = this.readProblem(rs);
      map.set(p.id, p);
    }
    rs.close();
    const ordered: Problem[] = [];
    for (let i = 0; i < ids.length; i++) {
      const p = map.get(ids[i]);
      if (p !== undefined) {
        ordered.push(p);
      }
    }
    return ordered;
  }

  async getAllProblems(): Promise<Problem[]> {
    return this.queryProblems('全部', 0, '');
  }

  // ===================== records =====================

  async getRecord(problemId: number): Promise<LearningRecord | null> {
    const store = this.store;
    if (store === null) {
      return null;
    }
    const predicates = new relationalStore.RdbPredicates('records');
    predicates.equalTo('problem_id', problemId);
    const rs = await store.query(predicates,
      ['problem_id', 'status', 'wrong_count', 'updated_at']);
    let record: LearningRecord | null = null;
    if (rs.goToFirstRow()) {
      record = new LearningRecord(
        rs.getLong(rs.getColumnIndex('problem_id')),
        rs.getLong(rs.getColumnIndex('status')),
        rs.getLong(rs.getColumnIndex('wrong_count')),
        rs.getLong(rs.getColumnIndex('updated_at'))
      );
    }
    rs.close();
    return record;
  }

  /** 写入刷题状态（不存在则插入，存在则更新状态与时间），成功返回 true */
  async setStatus(problemId: number, status: number): Promise<boolean> {
    const store = this.store;
    if (store === null) {
      return false;
    }
    try {
      const now = Date.now();
      const existing = await this.getRecord(problemId);
      if (existing === null) {
        const bucket: relationalStore.ValuesBucket = {
          'problem_id': problemId,
          'status': status,
          'wrong_count': 0,
          'updated_at': now
        };
        await store.insert('records', bucket);
      } else {
        const values: relationalStore.ValuesBucket = {
          'status': status,
          'updated_at': now
        };
        const predicates = new relationalStore.RdbPredicates('records');
        predicates.equalTo('problem_id', problemId);
        await store.update(values, predicates);
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  /** 标记做错：错误次数 +1，状态回退为「已做」，成功返回 true */
  async addWrong(problemId: number): Promise<boolean> {
    const store = this.store;
    if (store === null) {
      return false;
    }
    try {
      const now = Date.now();
      const existing = await this.getRecord(problemId);
      if (existing === null) {
        const bucket: relationalStore.ValuesBucket = {
          'problem_id': problemId,
          'status': STATUS_DONE,
          'wrong_count': 1,
          'updated_at': now
        };
        await store.insert('records', bucket);
      } else {
        const values: relationalStore.ValuesBucket = {
          'status': STATUS_DONE,
          'wrong_count': existing.wrongCount + 1,
          'updated_at': now
        };
        const predicates = new relationalStore.RdbPredicates('records');
        predicates.equalTo('problem_id', problemId);
        await store.update(values, predicates);
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  /** 错题本题目 id（状态为「已做」即未掌握） */
  async getWrongProblemIds(): Promise<number[]> {
    return this.queryRecordIds(STATUS_DONE);
  }

  private async queryRecordIds(status: number): Promise<number[]> {
    const store = this.store;
    if (store === null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('records');
    predicates.equalTo('status', status);
    predicates.orderByDesc('updated_at');
    const rs = await store.query(predicates, ['problem_id']);
    const ids: number[] = [];
    while (rs.goToNextRow()) {
      ids.push(rs.getLong(rs.getColumnIndex('problem_id')));
    }
    rs.close();
    return ids;
  }

  // ===================== favorites =====================

  async isFavorite(problemId: number): Promise<boolean> {
    const store = this.store;
    if (store === null) {
      return false;
    }
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.equalTo('problem_id', problemId);
    const rs = await store.query(predicates, ['problem_id']);
    const exists = rs.goToFirstRow();
    rs.close();
    return exists;
  }

  /** 切换收藏，成功返回 true，失败返回 false */
  async toggleFavorite(problemId: number): Promise<boolean> {
    const store = this.store;
    if (store === null) {
      return false;
    }
    try {
      const isFav = await this.isFavorite(problemId);
      if (isFav) {
        const predicates = new relationalStore.RdbPredicates('favorites');
        predicates.equalTo('problem_id', problemId);
        await store.delete(predicates);
      } else {
        const bucket: relationalStore.ValuesBucket = {
          'problem_id': problemId,
          'created_at': Date.now()
        };
        await store.insert('favorites', bucket);
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  async getFavoriteProblemIds(): Promise<number[]> {
    const store = this.store;
    if (store === null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('favorites');
    predicates.orderByDesc('created_at');
    const rs = await store.query(predicates, ['problem_id']);
    const ids: number[] = [];
    while (rs.goToNextRow()) {
      ids.push(rs.getLong(rs.getColumnIndex('problem_id')));
    }
    rs.close();
    return ids;
  }

  async getFavoriteProblems(): Promise<Problem[]> {
    const ids = await this.getFavoriteProblemIds();
    return this.getProblemsByIds(ids);
  }

  // ===================== notes =====================

  async getNote(problemId: number): Promise<string> {
    const store = this.store;
    if (store === null) {
      return '';
    }
    const predicates = new relationalStore.RdbPredicates('notes');
    predicates.equalTo('problem_id', problemId);
    const rs = await store.query(predicates, ['content']);
    let content = '';
    if (rs.goToFirstRow()) {
      content = rs.getString(rs.getColumnIndex('content'));
    }
    rs.close();
    return content;
  }

  async saveNote(problemId: number, content: string): Promise<boolean> {
    const store = this.store;
    if (store === null) {
      return false;
    }
    try {
      const existing = await this.getNote(problemId);
      const predicates = new relationalStore.RdbPredicates('notes');
      predicates.equalTo('problem_id', problemId);
      if (existing.length === 0) {
        const bucket: relationalStore.ValuesBucket = {
          'problem_id': problemId,
          'content': content,
          'updated_at': Date.now()
        };
        await store.insert('notes', bucket);
      } else {
        const values: relationalStore.ValuesBucket = {
          'content': content,
          'updated_at': Date.now()
        };
        await store.update(values, predicates);
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  async deleteNote(problemId: number): Promise<void> {
    const store = this.store;
    if (store === null) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates('notes');
    predicates.equalTo('problem_id', problemId);
    await store.delete(predicates);
  }

  // ===================== 统计 =====================

  async getStats(): Promise<LearnStats> {
    const stats = new LearnStats();
    stats.total = await this.countTable('problems');
    stats.mastered = await this.countByStatus(STATUS_MASTERED);
    stats.wrong = await this.countByStatus(STATUS_DONE);
    stats.done = stats.mastered + stats.wrong;
    stats.favorites = await this.countTable('favorites');
    return stats;
  }

  private async countByStatus(status: number): Promise<number> {
    const store = this.store;
    if (store === null) {
      return 0;
    }
    const predicates = new relationalStore.RdbPredicates('records');
    predicates.equalTo('status', status);
    const rs = await store.query(predicates, ['count(*) AS c']);
    let count = 0;
    if (rs.goToFirstRow()) {
      count = rs.getLong(rs.getColumnIndex('c'));
    }
    rs.close();
    return count;
  }

  /** 各分类完成进度 */
  async getCategoryProgress(categories: string[]): Promise<CategoryStat[]> {
    const all = await this.getAllProblems();
    const records = await this.getAllRecords();
    const doneSet: Set<number> = new Set<number>();
    for (let i = 0; i < records.length; i++) {
      if (records[i].status >= STATUS_DONE) {
        doneSet.add(records[i].problemId);
      }
    }
    const result: CategoryStat[] = [];
    for (let i = 0; i < categories.length; i++) {
      const cat = categories[i];
      let total = 0;
      let done = 0;
      for (let j = 0; j < all.length; j++) {
        if (all[j].category === cat) {
          total++;
          if (doneSet.has(all[j].id)) {
            done++;
          }
        }
      }
      result.push(new CategoryStat(cat, total, done));
    }
    return result;
  }

  private async getAllRecords(): Promise<LearningRecord[]> {
    const store = this.store;
    if (store === null) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('records');
    const rs = await store.query(predicates,
      ['problem_id', 'status', 'wrong_count', 'updated_at']);
    const list: LearningRecord[] = [];
    while (rs.goToNextRow()) {
      list.push(new LearningRecord(
        rs.getLong(rs.getColumnIndex('problem_id')),
        rs.getLong(rs.getColumnIndex('status')),
        rs.getLong(rs.getColumnIndex('wrong_count')),
        rs.getLong(rs.getColumnIndex('updated_at'))
      ));
    }
    rs.close();
    return list;
  }

  /** problemId -> status 映射，供列表页批量渲染状态 */
  async getStatusMap(): Promise<Map<number, number>> {
    const records = await this.getAllRecords();
    const map: Map<number, number> = new Map<number, number>();
    for (let i = 0; i < records.length; i++) {
      map.set(records[i].problemId, records[i].status);
    }
    return map;
  }

  /** 收藏题目 id 集合 */
  async getFavoriteIdSet(): Promise<Set<number>> {
    const ids = await this.getFavoriteProblemIds();
    return new Set<number>(ids);
  }

  /** problemId -> 错误次数 映射 */
  async getWrongCountMap(): Promise<Map<number, number>> {
    const records = await this.getAllRecords();
    const map: Map<number, number> = new Map<number, number>();
    for (let i = 0; i < records.length; i++) {
      if (records[i].wrongCount > 0) {
        map.set(records[i].problemId, records[i].wrongCount);
      }
    }
    return map;
  }

  /** 近 7 日刷题趋势（按 records.updated_at 统计每日活跃题数） */
  async getLast7DayTrend(): Promise<TrendData> {
    const records = await this.getAllRecords();
    const labels: string[] = [];
    const values: number[] = [];
    const dayMs = 24 * 60 * 60 * 1000;
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    for (let i = 6; i >= 0; i--) {
      const start = todayStart - i * dayMs;
      const end = start + dayMs;
      const d = new Date(start);
      const label = (d.getMonth() + 1).toString() + '-' + d.getDate().toString();
      labels.push(label);
      let count = 0;
      for (let j = 0; j < records.length; j++) {
        if (records[j].status >= STATUS_DONE &&
          records[j].updatedAt >= start && records[j].updatedAt < end) {
          count++;
        }
      }
      values.push(count);
    }
    return new TrendData(labels, values);
  }
}
