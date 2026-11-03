import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { WrongItem } from '../model/Models';

const DB_NAME: string = 'harmonymath.db';
const TABLE_RECORD: string = 'practice_record';
const TABLE_WRONG: string = 'wrong_question';
const TABLE_ACHIEVEMENT: string = 'achievement';

const SQL_CREATE_RECORD: string = `CREATE TABLE IF NOT EXISTS practice_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  mode TEXT NOT NULL,
  difficulty INTEGER NOT NULL,
  total INTEGER NOT NULL,
  correct INTEGER NOT NULL,
  duration_sec INTEGER NOT NULL,
  created_at INTEGER NOT NULL
)`;

const SQL_CREATE_WRONG: string = `CREATE TABLE IF NOT EXISTS wrong_question (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  stem TEXT NOT NULL,
  answer INTEGER NOT NULL,
  user_answer INTEGER NOT NULL,
  wrong_count INTEGER NOT NULL DEFAULT 1,
  mastered INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
)`;

const SQL_CREATE_ACHIEVEMENT: string = `CREATE TABLE IF NOT EXISTS achievement (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,
  unlocked_at INTEGER NOT NULL
)`;

export interface RecordRow {
  date: string;
  mode: string;
  difficulty: number;
  total: number;
  correct: number;
  durationSec: number;
}

export interface WrongRow {
  id: number;
  stem: string;
  answer: number;
  userAnswer: number;
  wrongCount: number;
  mastered: number;
}

export class RdbHelper {
  private static instance: RdbHelper | null = null;
  private store: relationalStore.RdbStore | null = null;
  private initTask: Promise<void> | null = null;

  static getInstance(): RdbHelper {
    if (RdbHelper.instance === null) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.store !== null) {
      return Promise.resolve();
    }
    if (this.initTask !== null) {
      return this.initTask;
    }
    this.initTask = this.doInit(context);
    return this.initTask;
  }

  async ready(): Promise<void> {
    if (this.initTask !== null) {
      return this.initTask;
    }
    return Promise.resolve();
  }

  private async doInit(context: common.Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.store = await relationalStore.getRdbStore(context, config);
      if (this.store !== null) {
        await this.store.executeSql(SQL_CREATE_RECORD);
        await this.store.executeSql(SQL_CREATE_WRONG);
        await this.store.executeSql(SQL_CREATE_ACHIEVEMENT);
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] init failed, code=${e.code}, msg=${e.message}`);
    }
  }

  async insertRecord(date: string, mode: string, difficulty: number,
    total: number, correct: number, durationSec: number): Promise<void> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return;
    }
    try {
      const bucket: relationalStore.ValuesBucket = {
        'date': date,
        'mode': mode,
        'difficulty': difficulty,
        'total': total,
        'correct': correct,
        'duration_sec': durationSec,
        'created_at': Date.now()
      };
      await s.insert(TABLE_RECORD, bucket);
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] insertRecord failed, code=${e.code}`);
    }
  }

  async queryRecordRows(): Promise<RecordRow[]> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return [];
    }
    const rows: RecordRow[] = [];
    try {
      const rs: relationalStore.ResultSet =
        await s.querySql('SELECT date, mode, difficulty, total, correct, duration_sec FROM practice_record ORDER BY created_at ASC');
      while (rs.goToNextRow()) {
        const row: RecordRow = {
          date: rs.getString(rs.getColumnIndex('date')),
          mode: rs.getString(rs.getColumnIndex('mode')),
          difficulty: rs.getLong(rs.getColumnIndex('difficulty')),
          total: rs.getLong(rs.getColumnIndex('total')),
          correct: rs.getLong(rs.getColumnIndex('correct')),
          durationSec: rs.getLong(rs.getColumnIndex('duration_sec'))
        };
        rows.push(row);
      }
      rs.close();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] queryRecordRows failed, code=${e.code}`);
    }
    return rows;
  }

  async insertWrongQuestions(items: WrongItem[]): Promise<void> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null || items.length === 0) {
      return;
    }
    try {
      for (const item of items) {
        const pred: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_WRONG);
        pred.equalTo('stem', item.stem);
        const rs: relationalStore.ResultSet = await s.query(pred, ['id', 'wrong_count']);
        if (rs.goToNextRow()) {
          const oldCount: number = rs.getLong(rs.getColumnIndex('wrong_count'));
          rs.close();
          const predUp: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_WRONG);
          predUp.equalTo('stem', item.stem);
          const bucket: relationalStore.ValuesBucket = {
            'user_answer': item.userAnswer,
            'wrong_count': oldCount + 1,
            'mastered': 0
          };
          await s.update(bucket, predUp);
        } else {
          rs.close();
          const bucket: relationalStore.ValuesBucket = {
            'stem': item.stem,
            'answer': item.answer,
            'user_answer': item.userAnswer,
            'wrong_count': 1,
            'mastered': 0,
            'created_at': Date.now()
          };
          await s.insert(TABLE_WRONG, bucket);
        }
      }
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] insertWrongQuestions failed, code=${e.code}`);
    }
  }

  async queryWrongQuestions(): Promise<WrongRow[]> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return [];
    }
    const rows: WrongRow[] = [];
    try {
      const rs: relationalStore.ResultSet = await s.querySql(
        'SELECT id, stem, answer, user_answer, wrong_count, mastered FROM wrong_question ORDER BY wrong_count DESC, id DESC');
      while (rs.goToNextRow()) {
        const row: WrongRow = {
          id: rs.getLong(rs.getColumnIndex('id')),
          stem: rs.getString(rs.getColumnIndex('stem')),
          answer: rs.getLong(rs.getColumnIndex('answer')),
          userAnswer: rs.getLong(rs.getColumnIndex('user_answer')),
          wrongCount: rs.getLong(rs.getColumnIndex('wrong_count')),
          mastered: rs.getLong(rs.getColumnIndex('mastered'))
        };
        rows.push(row);
      }
      rs.close();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] queryWrongQuestions failed, code=${e.code}`);
    }
    return rows;
  }

  async markMastered(id: number): Promise<void> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return;
    }
    try {
      const pred: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_WRONG);
      pred.equalTo('id', id);
      const bucket: relationalStore.ValuesBucket = { 'mastered': 1 };
      await s.update(bucket, pred);
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] markMastered failed, code=${e.code}`);
    }
  }

  async clearWrongBook(): Promise<void> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return;
    }
    try {
      await s.executeSql('DELETE FROM wrong_question');
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] clearWrongBook failed, code=${e.code}`);
    }
  }

  async unlockAchievement(key: string): Promise<boolean> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return false;
    }
    try {
      const pred: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_ACHIEVEMENT);
      pred.equalTo('key', key);
      const rs: relationalStore.ResultSet = await s.query(pred, ['id']);
      const exists: boolean = rs.goToNextRow();
      rs.close();
      if (exists) {
        return false;
      }
      const bucket: relationalStore.ValuesBucket = { 'key': key, 'unlocked_at': Date.now() };
      await s.insert(TABLE_ACHIEVEMENT, bucket);
      return true;
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] unlockAchievement failed, code=${e.code}`);
      return false;
    }
  }

  async queryAchievements(): Promise<string[]> {
    const s: relationalStore.RdbStore | null = this.store;
    if (s === null) {
      return [];
    }
    const keys: string[] = [];
    try {
      const rs: relationalStore.ResultSet = await s.querySql('SELECT key FROM achievement ORDER BY unlocked_at ASC');
      while (rs.goToNextRow()) {
        keys.push(rs.getString(rs.getColumnIndex('key')));
      }
      rs.close();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[RdbHelper] queryAchievements failed, code=${e.code}`);
    }
    return keys;
  }
}
