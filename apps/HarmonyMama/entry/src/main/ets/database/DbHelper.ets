import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { CheckupItem } from '../model/CheckupItem';
import { WeightRecord } from '../model/WeightRecord';
import { KickSession } from '../model/KickSession';
import { addDays } from '../utils/PregnancyCalc';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmonymama.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_CHECKUP: string =
  'CREATE TABLE IF NOT EXISTS checkup (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, due_date TEXT, done INTEGER, note TEXT)';
const SQL_CREATE_WEIGHT: string =
  'CREATE TABLE IF NOT EXISTS weight (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, weight REAL, week INTEGER)';
const SQL_CREATE_KICK: string =
  'CREATE TABLE IF NOT EXISTS kick_session (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, start_time TEXT, count INTEGER, duration_min INTEGER)';

const ROUTINE_NOTE: string = '常规产检：血压、体重、宫高、腹围、胎心监测';

export interface CheckupTemplate {
  name: string;
  week: number;
  note: string;
}

export const CHECKUP_TEMPLATES: CheckupTemplate[] = [
  { name: '建档建册', week: 8, note: '孕6-8周：建立母子健康档案，完成首次全面产检' },
  { name: 'NT检查', week: 12, note: '孕11-13周：颈项透明层超声，筛查染色体异常风险' },
  { name: '唐氏筛查', week: 16, note: '孕15-20周：唐筛或无创DNA，筛查唐氏综合征' },
  { name: '大排畸超声', week: 22, note: '孕20-24周：胎儿系统超声，排查结构畸形' },
  { name: '糖耐量试验', week: 26, note: '孕24-28周：口服葡萄糖耐量试验，筛查妊娠期糖尿病' },
  { name: '28周常规产检', week: 28, note: ROUTINE_NOTE },
  { name: '30周常规产检', week: 30, note: ROUTINE_NOTE },
  { name: '32周常规产检', week: 32, note: ROUTINE_NOTE },
  { name: '34周常规产检', week: 34, note: ROUTINE_NOTE },
  { name: '36周常规产检', week: 36, note: '常规产检：36周起每周一次，重点监测胎心与胎位' },
  { name: '38周常规产检', week: 38, note: ROUTINE_NOTE },
  { name: '39-40周常规产检', week: 39, note: '临近预产期：每周产检，评估胎位、胎心与分娩方式' }
];

export class DbHelper {
  private static instance: DbHelper | null = null;
  private store: relationalStore.RdbStore | null = null;
  private initialized: boolean = false;

  private constructor() {
  }

  static getInstance(): DbHelper {
    if (DbHelper.instance === null) {
      DbHelper.instance = new DbHelper();
    }
    return DbHelper.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.initialized) {
      return;
    }
    const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await store.executeSql(SQL_CREATE_CHECKUP);
    await store.executeSql(SQL_CREATE_WEIGHT);
    await store.executeSql(SQL_CREATE_KICK);
    this.store = store;
    this.initialized = true;
  }

  private getStore(): relationalStore.RdbStore {
    if (this.store === null) {
      throw new Error('DbHelper 尚未初始化，请先调用 init(context)');
    }
    return this.store;
  }

  private readCheckups(resultSet: relationalStore.ResultSet): CheckupItem[] {
    const list: CheckupItem[] = [];
    const idIndex: number = resultSet.getColumnIndex('id');
    const nameIndex: number = resultSet.getColumnIndex('name');
    const dueIndex: number = resultSet.getColumnIndex('due_date');
    const doneIndex: number = resultSet.getColumnIndex('done');
    const noteIndex: number = resultSet.getColumnIndex('note');
    while (resultSet.goToNextRow()) {
      const item: CheckupItem = new CheckupItem();
      item.id = resultSet.getLong(idIndex);
      item.name = resultSet.getString(nameIndex);
      item.dueDate = resultSet.getString(dueIndex);
      item.done = resultSet.getLong(doneIndex) === 1;
      item.note = resultSet.getString(noteIndex);
      list.push(item);
    }
    return list;
  }

  private readWeights(resultSet: relationalStore.ResultSet): WeightRecord[] {
    const list: WeightRecord[] = [];
    const idIndex: number = resultSet.getColumnIndex('id');
    const dateIndex: number = resultSet.getColumnIndex('date');
    const weightIndex: number = resultSet.getColumnIndex('weight');
    const weekIndex: number = resultSet.getColumnIndex('week');
    while (resultSet.goToNextRow()) {
      const record: WeightRecord = new WeightRecord();
      record.id = resultSet.getLong(idIndex);
      record.date = resultSet.getString(dateIndex);
      record.weight = resultSet.getDouble(weightIndex);
      record.week = resultSet.getLong(weekIndex);
      list.push(record);
    }
    return list;
  }

  private readKickSessions(resultSet: relationalStore.ResultSet): KickSession[] {
    const list: KickSession[] = [];
    const idIndex: number = resultSet.getColumnIndex('id');
    const dateIndex: number = resultSet.getColumnIndex('date');
    const startIndex: number = resultSet.getColumnIndex('start_time');
    const countIndex: number = resultSet.getColumnIndex('count');
    const durationIndex: number = resultSet.getColumnIndex('duration_min');
    while (resultSet.goToNextRow()) {
      const session: KickSession = new KickSession();
      session.id = resultSet.getLong(idIndex);
      session.date = resultSet.getString(dateIndex);
      session.startTime = resultSet.getString(startIndex);
      session.count = resultSet.getLong(countIndex);
      session.durationMin = resultSet.getLong(durationIndex);
      list.push(session);
    }
    return list;
  }

  async insertCheckup(item: CheckupItem): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'name': item.name,
      'due_date': item.dueDate,
      'done': item.done ? 1 : 0,
      'note': item.note
    };
    return await this.getStore().insert('checkup', values);
  }

  async updateCheckup(item: CheckupItem): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'name': item.name,
      'due_date': item.dueDate,
      'done': item.done ? 1 : 0,
      'note': item.note
    };
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('checkup');
    predicates.equalTo('id', item.id);
    return await this.getStore().update(values, predicates);
  }

  async setCheckupDone(id: number, done: boolean): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'done': done ? 1 : 0
    };
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('checkup');
    predicates.equalTo('id', id);
    return await this.getStore().update(values, predicates);
  }

  async deleteCheckup(id: number): Promise<number> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('checkup');
    predicates.equalTo('id', id);
    return await this.getStore().delete(predicates);
  }

  async queryCheckups(): Promise<CheckupItem[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('checkup');
    predicates.orderByAsc('due_date');
    const columns: string[] = ['id', 'name', 'due_date', 'done', 'note'];
    const resultSet: relationalStore.ResultSet = await this.getStore().query(predicates, columns);
    const list: CheckupItem[] = this.readCheckups(resultSet);
    resultSet.close();
    return list;
  }

  async queryCheckupsByDone(done: boolean): Promise<CheckupItem[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('checkup');
    predicates.equalTo('done', done ? 1 : 0);
    predicates.orderByAsc('due_date');
    const columns: string[] = ['id', 'name', 'due_date', 'done', 'note'];
    const resultSet: relationalStore.ResultSet = await this.getStore().query(predicates, columns);
    const list: CheckupItem[] = this.readCheckups(resultSet);
    resultSet.close();
    return list;
  }

  async insertWeight(record: WeightRecord): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'date': record.date,
      'weight': record.weight,
      'week': record.week
    };
    return await this.getStore().insert('weight', values);
  }

  async updateWeight(record: WeightRecord): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'date': record.date,
      'weight': record.weight,
      'week': record.week
    };
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('weight');
    predicates.equalTo('id', record.id);
    return await this.getStore().update(values, predicates);
  }

  async deleteWeight(id: number): Promise<number> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('weight');
    predicates.equalTo('id', id);
    return await this.getStore().delete(predicates);
  }

  async queryWeights(): Promise<WeightRecord[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('weight');
    predicates.orderByAsc('date');
    const columns: string[] = ['id', 'date', 'weight', 'week'];
    const resultSet: relationalStore.ResultSet = await this.getStore().query(predicates, columns);
    const list: WeightRecord[] = this.readWeights(resultSet);
    resultSet.close();
    return list;
  }

  async insertKickSession(session: KickSession): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'date': session.date,
      'start_time': session.startTime,
      'count': session.count,
      'duration_min': session.durationMin
    };
    return await this.getStore().insert('kick_session', values);
  }

  async updateKickSession(session: KickSession): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      'date': session.date,
      'start_time': session.startTime,
      'count': session.count,
      'duration_min': session.durationMin
    };
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('kick_session');
    predicates.equalTo('id', session.id);
    return await this.getStore().update(values, predicates);
  }

  async deleteKickSession(id: number): Promise<number> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('kick_session');
    predicates.equalTo('id', id);
    return await this.getStore().delete(predicates);
  }

  async queryKickSessions(): Promise<KickSession[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('kick_session');
    predicates.orderByDesc('date');
    const columns: string[] = ['id', 'date', 'start_time', 'count', 'duration_min'];
    const resultSet: relationalStore.ResultSet = await this.getStore().query(predicates, columns);
    const list: KickSession[] = this.readKickSessions(resultSet);
    resultSet.close();
    return list;
  }

  async queryKickSessionsByDate(date: string): Promise<KickSession[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('kick_session');
    predicates.equalTo('date', date);
    predicates.orderByAsc('start_time');
    const columns: string[] = ['id', 'date', 'start_time', 'count', 'duration_min'];
    const resultSet: relationalStore.ResultSet = await this.getStore().query(predicates, columns);
    const list: KickSession[] = this.readKickSessions(resultSet);
    resultSet.close();
    return list;
  }

  async importCheckupTemplate(dueDate: string): Promise<number> {
    const existing: CheckupItem[] = await this.queryCheckups();
    const existingNames: string[] = [];
    for (let i = 0; i < existing.length; i++) {
      existingNames.push(existing[i].name);
    }
    const buckets: relationalStore.ValuesBucket[] = [];
    for (let i = 0; i < CHECKUP_TEMPLATES.length; i++) {
      const template: CheckupTemplate = CHECKUP_TEMPLATES[i];
      if (existingNames.indexOf(template.name) >= 0) {
        continue;
      }
      const checkupDate: string = addDays(dueDate, -(40 - template.week) * 7);
      const bucket: relationalStore.ValuesBucket = {
        'name': template.name,
        'due_date': checkupDate,
        'done': 0,
        'note': template.note
      };
      buckets.push(bucket);
    }
    if (buckets.length === 0) {
      return 0;
    }
    return await this.getStore().batchInsert('checkup', buckets);
  }
}
