import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { CheckIn, Goal, GoalDetail, GoalFormData, GoalStatistics, KeyResult, KRFormData, KRType } from './GoalModel';
import { DateUtils } from '../utils/DateUtils';

const DB_NAME: string = 'harmony_goal.db';
const GOALS_TABLE: string = 'goals';
const KRS_TABLE: string = 'key_results';
const CHECKINS_TABLE: string = 'checkins';

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper();
  private store?: relationalStore.RdbStore;

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return;
    }
    let config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables();
  }

  private async createTables(): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${GOALS_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      period TEXT NOT NULL,
      color TEXT NOT NULL,
      status TEXT NOT NULL,
      deadline TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${KRS_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      kr_type TEXT NOT NULL,
      target_value REAL NOT NULL,
      current_value REAL NOT NULL,
      unit TEXT,
      weight REAL NOT NULL,
      created_at INTEGER NOT NULL
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${CHECKINS_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      note TEXT NOT NULL,
      progress REAL NOT NULL,
      date TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )`);
  }

  private requireStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database is not initialized');
    }
    return this.store;
  }

  private rowToGoalSet(row: relationalStore.ResultSet, progress: number, krCount: number, checkInCount: number): Goal {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      title: row.getString(row.getColumnIndex('title')),
      description: row.getString(row.getColumnIndex('description')),
      period: row.getString(row.getColumnIndex('period')) as any,
      color: row.getString(row.getColumnIndex('color')),
      status: row.getString(row.getColumnIndex('status')) as any,
      deadline: row.getString(row.getColumnIndex('deadline')),
      createdAt: row.getLong(row.getColumnIndex('created_at')),
      updatedAt: row.getLong(row.getColumnIndex('updated_at')),
      progress: progress,
      keyResultCount: krCount,
      checkInCount: checkInCount
    };
  }

  private rowToKr(row: relationalStore.ResultSet): KeyResult {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      goalId: row.getLong(row.getColumnIndex('goal_id')),
      title: row.getString(row.getColumnIndex('title')),
      krType: row.getString(row.getColumnIndex('kr_type')) as KRType,
      targetValue: Number(row.getDouble(row.getColumnIndex('target_value'))),
      currentValue: Number(row.getDouble(row.getColumnIndex('current_value'))),
      unit: row.getString(row.getColumnIndex('unit')),
      weight: Number(row.getDouble(row.getColumnIndex('weight'))),
      createdAt: row.getLong(row.getColumnIndex('created_at'))
    };
  }

  private rowToCheckIn(row: relationalStore.ResultSet): CheckIn {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      goalId: row.getLong(row.getColumnIndex('goal_id')),
      note: row.getString(row.getColumnIndex('note')),
      progress: Number(row.getDouble(row.getColumnIndex('progress'))),
      date: row.getString(row.getColumnIndex('date')),
      createdAt: row.getLong(row.getColumnIndex('created_at'))
    };
  }

  private async queryKeyResults(goalId: number): Promise<KeyResult[]> {
    let store: relationalStore.RdbStore = this.requireStore();
    let result: relationalStore.ResultSet = await store.querySql(`SELECT * FROM ${KRS_TABLE} WHERE goal_id = ? ORDER BY created_at ASC`, [goalId]);
    let list: KeyResult[] = [];
    while (result.goToNextRow()) {
      list.push(this.rowToKr(result));
    }
    result.close();
    return list;
  }

  private async queryCheckIns(goalId: number): Promise<CheckIn[]> {
    let store: relationalStore.RdbStore = this.requireStore();
    let result: relationalStore.ResultSet = await store.querySql(`SELECT * FROM ${CHECKINS_TABLE} WHERE goal_id = ? ORDER BY date DESC, created_at DESC`, [goalId]);
    let list: CheckIn[] = [];
    while (result.goToNextRow()) {
      list.push(this.rowToCheckIn(result));
    }
    result.close();
    return list;
  }

  private computeProgress(keyResults: KeyResult[]): number {
    if (keyResults.length === 0) {
      return 0;
    }
    let totalWeight: number = 0;
    let weightedProgress: number = 0;
    keyResults.forEach((item: KeyResult) => {
      let weight: number = item.weight > 0 ? item.weight : 1;
      totalWeight += weight;
      let ratio: number = 0;
      if (item.krType === 'boolean') {
        ratio = item.currentValue >= 1 ? 1 : 0;
      } else if (item.targetValue > 0) {
        ratio = Math.min(item.currentValue / item.targetValue, 1);
      }
      weightedProgress += ratio * weight;
    });
    if (totalWeight <= 0) {
      return 0;
    }
    return Number(((weightedProgress / totalWeight) * 100).toFixed(1));
  }

  private async touchGoal(goalId: number): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(GOALS_TABLE);
    predicates.equalTo('id', goalId);
    let values: relationalStore.ValuesBucket = {
      updated_at: DateUtils.now()
    };
    await store.update(values, predicates);
  }

  async createGoal(data: GoalFormData): Promise<number> {
    let store: relationalStore.RdbStore = this.requireStore();
    let now: number = DateUtils.now();
    let values: relationalStore.ValuesBucket = {
      title: data.title,
      description: data.description,
      period: data.period,
      color: data.color,
      status: data.status,
      deadline: data.deadline,
      created_at: now,
      updated_at: now
    };
    return await store.insert(GOALS_TABLE, values);
  }

  async updateGoal(goalId: number, data: GoalFormData): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(GOALS_TABLE);
    predicates.equalTo('id', goalId);
    let values: relationalStore.ValuesBucket = {
      title: data.title,
      description: data.description,
      period: data.period,
      color: data.color,
      status: data.status,
      deadline: data.deadline,
      updated_at: DateUtils.now()
    };
    await store.update(values, predicates);
  }

  async deleteGoal(goalId: number): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let krPredicates = new relationalStore.RdbPredicates(KRS_TABLE);
    krPredicates.equalTo('goal_id', goalId);
    await store.delete(krPredicates);
    let checkInPredicates = new relationalStore.RdbPredicates(CHECKINS_TABLE);
    checkInPredicates.equalTo('goal_id', goalId);
    await store.delete(checkInPredicates);
    let goalPredicates = new relationalStore.RdbPredicates(GOALS_TABLE);
    goalPredicates.equalTo('id', goalId);
    await store.delete(goalPredicates);
  }

  async listGoals(): Promise<Goal[]> {
    let store: relationalStore.RdbStore = this.requireStore();
    let result: relationalStore.ResultSet = await store.querySql(`SELECT * FROM ${GOALS_TABLE} ORDER BY updated_at DESC, created_at DESC`);
    let goals: Goal[] = [];
    while (result.goToNextRow()) {
      let goalId: number = result.getLong(result.getColumnIndex('id'));
      let keyResults: KeyResult[] = await this.queryKeyResults(goalId);
      let checkIns: CheckIn[] = await this.queryCheckIns(goalId);
      goals.push(this.rowToGoalSet(result, this.computeProgress(keyResults), keyResults.length, checkIns.length));
    }
    result.close();
    return goals;
  }

  async getGoal(goalId: number): Promise<Goal | null> {
    let store: relationalStore.RdbStore = this.requireStore();
    let result: relationalStore.ResultSet = await store.querySql(`SELECT * FROM ${GOALS_TABLE} WHERE id = ? LIMIT 1`, [goalId]);
    let goal: Goal | null = null;
    if (result.goToFirstRow()) {
      let keyResults: KeyResult[] = await this.queryKeyResults(goalId);
      let checkIns: CheckIn[] = await this.queryCheckIns(goalId);
      goal = this.rowToGoalSet(result, this.computeProgress(keyResults), keyResults.length, checkIns.length);
    }
    result.close();
    return goal;
  }

  async getGoalDetail(goalId: number): Promise<GoalDetail | null> {
    let goal: Goal | null = await this.getGoal(goalId);
    if (!goal) {
      return null;
    }
    let keyResults: KeyResult[] = await this.queryKeyResults(goalId);
    let checkIns: CheckIn[] = await this.queryCheckIns(goalId);
    goal.progress = this.computeProgress(keyResults);
    goal.keyResultCount = keyResults.length;
    goal.checkInCount = checkIns.length;
    return {
      goal: goal,
      keyResults: keyResults,
      checkIns: checkIns
    };
  }

  async createKeyResult(data: KRFormData): Promise<number> {
    let store: relationalStore.RdbStore = this.requireStore();
    let values: relationalStore.ValuesBucket = {
      goal_id: data.goalId,
      title: data.title,
      kr_type: data.krType,
      target_value: data.krType === 'boolean' ? 1 : data.targetValue,
      current_value: data.currentValue,
      unit: data.unit,
      weight: data.weight,
      created_at: DateUtils.now()
    };
    let id: number = await store.insert(KRS_TABLE, values);
    await this.touchGoal(data.goalId);
    return id;
  }

  async updateKeyResult(krId: number, data: KRFormData): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(KRS_TABLE);
    predicates.equalTo('id', krId);
    let values: relationalStore.ValuesBucket = {
      title: data.title,
      kr_type: data.krType,
      target_value: data.krType === 'boolean' ? 1 : data.targetValue,
      current_value: data.currentValue,
      unit: data.unit,
      weight: data.weight
    };
    await store.update(values, predicates);
    await this.touchGoal(data.goalId);
  }

  async updateKrProgress(krId: number, goalId: number, currentValue: number): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(KRS_TABLE);
    predicates.equalTo('id', krId);
    let values: relationalStore.ValuesBucket = {
      current_value: currentValue
    };
    await store.update(values, predicates);
    await this.touchGoal(goalId);
  }

  async deleteKeyResult(goalId: number, krId: number): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(KRS_TABLE);
    predicates.equalTo('id', krId);
    await store.delete(predicates);
    await this.touchGoal(goalId);
  }

  async createCheckIn(goalId: number, note: string, progress: number, date: string): Promise<number> {
    let store: relationalStore.RdbStore = this.requireStore();
    let values: relationalStore.ValuesBucket = {
      goal_id: goalId,
      note: note,
      progress: progress,
      date: date,
      created_at: DateUtils.now()
    };
    let id: number = await store.insert(CHECKINS_TABLE, values);
    await this.touchGoal(goalId);
    return id;
  }

  async deleteCheckIn(goalId: number, checkInId: number): Promise<void> {
    let store: relationalStore.RdbStore = this.requireStore();
    let predicates = new relationalStore.RdbPredicates(CHECKINS_TABLE);
    predicates.equalTo('id', checkInId);
    await store.delete(predicates);
    await this.touchGoal(goalId);
  }

  async listCheckIns(goalId: number): Promise<CheckIn[]> {
    return await this.queryCheckIns(goalId);
  }

  async getStatistics(): Promise<GoalStatistics> {
    let goals: Goal[] = await this.listGoals();
    let totalGoals: number = goals.length;
    let activeGoals: number = goals.filter((goal: Goal) => goal.status === 'in_progress').length;
    let completedGoals: number = goals.filter((goal: Goal) => goal.status === 'completed').length;
    let pausedGoals: number = goals.filter((goal: Goal) => goal.status === 'paused').length;
    let averageProgress: number = totalGoals > 0
      ? Number((goals.reduce((sum: number, goal: Goal) => sum + goal.progress, 0) / totalGoals).toFixed(1))
      : 0;

    let totalKrCompletion: number = 0;
    let krCount: number = 0;
    for (let index = 0; index < goals.length; index++) {
      let keyResults: KeyResult[] = await this.queryKeyResults(goals[index].id);
      keyResults.forEach((item: KeyResult) => {
        let progress: number = item.krType === 'boolean'
          ? (item.currentValue >= 1 ? 100 : 0)
          : (item.targetValue > 0 ? Math.min(item.currentValue / item.targetValue, 1) * 100 : 0);
        totalKrCompletion += progress;
        krCount += 1;
      });
    }

    let checkInTotal: number = 0;
    for (let index = 0; index < goals.length; index++) {
      let checkIns: CheckIn[] = await this.queryCheckIns(goals[index].id);
      checkInTotal += checkIns.length;
    }

    return {
      totalGoals: totalGoals,
      activeGoals: activeGoals,
      completedGoals: completedGoals,
      pausedGoals: pausedGoals,
      averageProgress: averageProgress,
      averageKrCompletion: krCount > 0 ? Number((totalKrCompletion / krCount).toFixed(1)) : 0,
      completionRate: totalGoals > 0 ? Number(((completedGoals / totalGoals) * 100).toFixed(1)) : 0,
      totalCheckIns: checkInTotal
    };
  }
}
