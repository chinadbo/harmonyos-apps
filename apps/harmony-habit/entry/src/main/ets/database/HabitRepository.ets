import UIAbilityContext from '@ohos.app.ability.UIAbilityContext';
import relationalStore from '@ohos.data.relationalStore';
import { HabitModel } from '../model/HabitModel';
import { DatabaseHelper } from './DatabaseHelper';

export class HabitRepository {
  constructor(private context: UIAbilityContext) {}

  private async store(): Promise<relationalStore.RdbStore> {
    return DatabaseHelper.getInstance().getStore(this.context);
  }

  async findAll(includeInactive: boolean = true): Promise<HabitModel[]> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('habit');
    if (!includeInactive) {
      predicates.equalTo('isActive', 1);
    }
    predicates.orderByDesc('createdAt');
    const result = await store.query(predicates);
    const habits: HabitModel[] = [];
    while (result.goToNextRow()) {
      habits.push({
        id: result.getLong(result.getColumnIndex('id')),
        name: result.getString(result.getColumnIndex('name')),
        icon: result.getString(result.getColumnIndex('icon')),
        colorIndex: result.getLong(result.getColumnIndex('colorIndex')),
        targetDays: result.getString(result.getColumnIndex('targetDays')),
        reminderTime: result.getString(result.getColumnIndex('reminderTime')),
        reminderId: result.getLong(result.getColumnIndex('reminderId')),
        createdAt: result.getLong(result.getColumnIndex('createdAt')),
        isActive: result.getLong(result.getColumnIndex('isActive'))
      });
    }
    result.close();
    return habits;
  }

  async findById(id: number): Promise<HabitModel | null> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('habit');
    predicates.equalTo('id', id);
    const result = await store.query(predicates);
    let habit: HabitModel | null = null;
    if (result.goToFirstRow()) {
      habit = {
        id: result.getLong(result.getColumnIndex('id')),
        name: result.getString(result.getColumnIndex('name')),
        icon: result.getString(result.getColumnIndex('icon')),
        colorIndex: result.getLong(result.getColumnIndex('colorIndex')),
        targetDays: result.getString(result.getColumnIndex('targetDays')),
        reminderTime: result.getString(result.getColumnIndex('reminderTime')),
        reminderId: result.getLong(result.getColumnIndex('reminderId')),
        createdAt: result.getLong(result.getColumnIndex('createdAt')),
        isActive: result.getLong(result.getColumnIndex('isActive'))
      };
    }
    result.close();
    return habit;
  }

  async insert(habit: HabitModel): Promise<number> {
    const store = await this.store();
    const values: relationalStore.ValuesBucket = {
      name: habit.name,
      icon: habit.icon,
      colorIndex: habit.colorIndex,
      targetDays: habit.targetDays,
      reminderTime: habit.reminderTime,
      reminderId: habit.reminderId,
      createdAt: habit.createdAt,
      isActive: habit.isActive
    };
    return Number(await store.insert('habit', values));
  }

  async update(habit: HabitModel): Promise<void> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('habit');
    predicates.equalTo('id', habit.id);
    const values: relationalStore.ValuesBucket = {
      name: habit.name,
      icon: habit.icon,
      colorIndex: habit.colorIndex,
      targetDays: habit.targetDays,
      reminderTime: habit.reminderTime,
      reminderId: habit.reminderId,
      isActive: habit.isActive
    };
    await store.update(values, predicates);
  }

  async delete(id: number): Promise<void> {
    const store = await this.store();
    const predicates = new relationalStore.RdbPredicates('habit');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }
}
