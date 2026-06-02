import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Constants } from '../common/Constants';
import { ShoppingEntry } from '../model/ShoppingEntry';
import { FoodItem } from '../model/FoodItem';

export class ShoppingDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async save(entry: ShoppingEntry): Promise<number> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      foodItemId: entry.foodItemId,
      name: entry.name,
      quantityText: entry.quantityText,
      completed: entry.completed,
      createdAt: entry.createdAt
    };
    if (entry.id > 0) {
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.SHOPPING_TABLE);
      predicates.equalTo('id', entry.id);
      await store.update(values, predicates);
      return entry.id;
    }
    return store.insert(Constants.SHOPPING_TABLE, values);
  }

  async createFromFood(item: FoodItem): Promise<number> {
    const quantityText: string = `${item.quantity}${item.unit}`;
    return this.save(ShoppingEntry.create(item.name, quantityText, item.id));
  }

  async toggleCompleted(entry: ShoppingEntry): Promise<void> {
    entry.completed = entry.completed === 1 ? 0 : 1;
    await this.save(entry);
  }

  async deleteById(id: number): Promise<void> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.SHOPPING_TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async getAll(): Promise<ShoppingEntry[]> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.SHOPPING_TABLE);
    predicates.orderByAsc('completed').orderByDesc('createdAt');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, [
      'id',
      'foodItemId',
      'name',
      'quantityText',
      'completed',
      'createdAt'
    ]);
    const entries: ShoppingEntry[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        entries.push(this.mapRow(resultSet));
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return entries;
  }

  private mapRow(resultSet: relationalStore.ResultSet): ShoppingEntry {
    const entry: ShoppingEntry = new ShoppingEntry();
    entry.id = resultSet.getLong(resultSet.getColumnIndex('id'));
    entry.foodItemId = resultSet.getLong(resultSet.getColumnIndex('foodItemId'));
    entry.name = resultSet.getString(resultSet.getColumnIndex('name'));
    entry.quantityText = resultSet.getString(resultSet.getColumnIndex('quantityText'));
    entry.completed = resultSet.getLong(resultSet.getColumnIndex('completed'));
    entry.createdAt = resultSet.getLong(resultSet.getColumnIndex('createdAt'));
    return entry;
  }
}
