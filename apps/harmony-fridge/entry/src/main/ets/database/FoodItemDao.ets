import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { FoodItem, CategoryStat } from '../model/FoodItem';
import { Constants } from '../common/Constants';
import { DateUtils } from '../common/DateUtils';

export class FoodItemDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async save(item: FoodItem): Promise<number> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      category: item.category,
      expiryDate: item.expiryDate,
      storageArea: item.storageArea,
      note: item.note,
      createdAt: item.createdAt,
      updatedAt: Date.now()
    };
    if (item.id > 0) {
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.FOOD_TABLE);
      predicates.equalTo('id', item.id);
      await store.update(values, predicates);
      return item.id;
    }
    return store.insert(Constants.FOOD_TABLE, values);
  }

  async deleteById(id: number): Promise<void> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.FOOD_TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async getAll(): Promise<FoodItem[]> {
    const store: relationalStore.RdbStore = await this.helper.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(Constants.FOOD_TABLE);
    predicates.orderByAsc('expiryDate');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, [
      'id',
      'name',
      'quantity',
      'unit',
      'category',
      'expiryDate',
      'storageArea',
      'note',
      'createdAt',
      'updatedAt'
    ]);
    const items: FoodItem[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        items.push(this.mapRow(resultSet));
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return items;
  }

  async getExpiringItems(days: number = Constants.WARNING_DAYS): Promise<FoodItem[]> {
    const items: FoodItem[] = await this.getAll();
    return items.filter((item: FoodItem) => {
      const remaining: number = DateUtils.daysUntil(item.expiryDate);
      return remaining <= days;
    });
  }

  async getCategoryStats(): Promise<CategoryStat[]> {
    const items: FoodItem[] = await this.getAll();
    const statsMap: Map<string, number> = new Map<string, number>();
    Constants.CATEGORIES.forEach((category: string) => {
      statsMap.set(category, 0);
    });
    items.forEach((item: FoodItem) => {
      const current: number = statsMap.get(item.category) ?? 0;
      statsMap.set(item.category, current + 1);
    });
    const stats: CategoryStat[] = [];
    statsMap.forEach((count: number, category: string) => {
      stats.push(new CategoryStat(category, count));
    });
    return stats;
  }

  private mapRow(resultSet: relationalStore.ResultSet): FoodItem {
    const item: FoodItem = new FoodItem();
    item.id = resultSet.getLong(resultSet.getColumnIndex('id'));
    item.name = resultSet.getString(resultSet.getColumnIndex('name'));
    item.quantity = resultSet.getDouble(resultSet.getColumnIndex('quantity'));
    item.unit = resultSet.getString(resultSet.getColumnIndex('unit'));
    item.category = resultSet.getString(resultSet.getColumnIndex('category'));
    item.expiryDate = resultSet.getString(resultSet.getColumnIndex('expiryDate'));
    item.storageArea = resultSet.getString(resultSet.getColumnIndex('storageArea'));
    item.note = resultSet.getString(resultSet.getColumnIndex('note'));
    item.createdAt = resultSet.getLong(resultSet.getColumnIndex('createdAt'));
    item.updatedAt = resultSet.getLong(resultSet.getColumnIndex('updatedAt'));
    return item;
  }
}
