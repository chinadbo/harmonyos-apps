import UIAbilityContext from '@ohos.app.ability.UIAbilityContext';
import relationalStore from '@ohos.data.relationalStore';
import { CheckInModel } from '../model/CheckInModel';
import { DatabaseHelper } from './DatabaseHelper';

export class CheckInRepository {
  constructor(private context: UIAbilityContext) {}

  private async store(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context);
  }

  async findAll(): Promise<CheckInModel[]> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('checkin');
    predicates.orderByDesc('checkDate');
    const result = await store.query(predicates);
    const rows: CheckInModel[] = [];
    while (result.goToNextRow()) {
      rows.push(this.mapRow(result));
    }
    result.close();
    return rows;
  }

  async findByHabitId(habitId: number): Promise<CheckInModel[]> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('checkin');
    predicates.equalTo('habitId', habitId).orderByDesc('checkDate');
    const result = await store.query(predicates);
    const rows: CheckInModel[] = [];
    while (result.goToNextRow()) {
      rows.push(this.mapRow(result));
    }
    result.close();
    return rows;
  }

  async findByHabitAndDate(habitId: number, checkDate: string): Promise<CheckInModel | null> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('checkin');
    predicates.equalTo('habitId', habitId).and().equalTo('checkDate', checkDate);
    const result = await store.query(predicates);
    let row: CheckInModel | null = null;
    if (result.goToFirstRow()) {
      row = this.mapRow(result);
    }
    result.close();
    return row;
  }

  async upsert(checkin: CheckInModel): Promise<void> {
    const existing = await this.findByHabitAndDate(checkin.habitId, checkin.checkDate);
    const store = await this.store();
    if (existing) {
      const predicates = new relationalStore.RdbPredicates('checkin');
      predicates.equalTo('id', existing.id);
      await store.update({ note: checkin.note, createdAt: checkin.createdAt }, predicates);
      return;
    }
    await store.insert('checkin', {
      habitId: checkin.habitId,
      checkDate: checkin.checkDate,
      note: checkin.note,
      createdAt: checkin.createdAt
    });
  }

  async deleteByHabitAndDate(habitId: number, checkDate: string): Promise<void> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('checkin');
    predicates.equalTo('habitId', habitId).and().equalTo('checkDate', checkDate);
    await store.delete(predicates);
  }

  async deleteByHabitId(habitId: number): Promise<void> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('checkin');
    predicates.equalTo('habitId', habitId);
    await store.delete(predicates);
  }

  private mapRow(result: relationalStore.ResultSet): CheckInModel {
    return {
      id: result.getLong(result.getColumnIndex('id')),
      habitId: result.getLong(result.getColumnIndex('habitId')),
      checkDate: result.getString(result.getColumnIndex('checkDate')),
      note: result.getString(result.getColumnIndex('note')),
      createdAt: result.getLong(result.getColumnIndex('createdAt'))
    };
  }
}
