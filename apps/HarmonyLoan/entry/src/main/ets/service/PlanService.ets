import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { LoanInput, LoanPlan } from '../model/LoanTypes';

const DB_NAME: string = 'loan.db';
const TABLE_NAME: string = 'plans';
const SQL_CREATE: string = 'CREATE TABLE IF NOT EXISTS plans (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
  'name TEXT NOT NULL, ' +
  'input TEXT NOT NULL, ' +
  'monthly INTEGER NOT NULL, ' +
  'total_interest INTEGER NOT NULL, ' +
  'created_at INTEGER NOT NULL)';

export default class PlanService {
  private static store: relationalStore.RdbStore | null = null;

  static async getStore(context: common.Context): Promise<relationalStore.RdbStore> {
    if (PlanService.store !== null) {
      return PlanService.store;
    }
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    const store = await relationalStore.getRdbStore(context, config);
    await store.executeSql(SQL_CREATE);
    PlanService.store = store;
    return store;
  }

  static async savePlan(context: common.Context, plan: LoanPlan): Promise<number> {
    const store = await PlanService.getStore(context);
    const values: relationalStore.ValuesBucket = {
      'name': plan.name,
      'input': JSON.stringify(plan.input),
      'monthly': plan.monthlyFen,
      'total_interest': plan.totalInterestFen,
      'created_at': plan.createdAt
    };
    return await store.insert(TABLE_NAME, values);
  }

  static async listPlans(context: common.Context): Promise<LoanPlan[]> {
    const plans: LoanPlan[] = [];
    const store = await PlanService.getStore(context);
    const resultSet = await store.querySql(
      'SELECT id, name, input, monthly, total_interest, created_at FROM plans ORDER BY created_at DESC');
    try {
      while (resultSet.goToNextRow()) {
        const id = resultSet.getLong(resultSet.getColumnIndex('id'));
        const name = resultSet.getString(resultSet.getColumnIndex('name'));
        const inputText = resultSet.getString(resultSet.getColumnIndex('input'));
        const monthly = resultSet.getLong(resultSet.getColumnIndex('monthly'));
        const totalInterest = resultSet.getLong(resultSet.getColumnIndex('total_interest'));
        const createdAt = resultSet.getLong(resultSet.getColumnIndex('created_at'));
        let input: LoanInput | null = null;
        try {
          input = JSON.parse(inputText) as LoanInput;
        } catch (e) {
          input = null;
        }
        if (input !== null) {
          plans.push({
            id: id,
            name: name,
            input: input,
            monthlyFen: monthly,
            totalInterestFen: totalInterest,
            createdAt: createdAt
          });
        }
      }
    } finally {
      resultSet.close();
    }
    return plans;
  }

  static async deletePlan(context: common.Context, id: number): Promise<void> {
    const store = await PlanService.getStore(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  static async deletePlans(context: common.Context, ids: number[]): Promise<void> {
    for (let i = 0; i < ids.length; i++) {
      await PlanService.deletePlan(context, ids[i]);
    }
  }
}
