import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { ShoppingList, ShoppingListCategory } from '../model/ShoppingList';
import { ShoppingItem } from '../model/ShoppingItem';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_shop.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

export class ShopDatabase {
  private static instance: ShopDatabase = new ShopDatabase();
  private store?: relationalStore.RdbStore;
  private context?: common.UIAbilityContext;

  private constructor() {
  }

  static getInstance(): ShopDatabase {
    return ShopDatabase.instance;
  }

  async init(context?: common.UIAbilityContext): Promise<void> {
    if (context) {
      this.context = context;
    }

    const store = await this.getStore();
    await store.executeSql('PRAGMA foreign_keys = ON');
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS shopping_lists (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'name TEXT NOT NULL, ' +
        'category TEXT NOT NULL, ' +
        'create_time INTEGER NOT NULL, ' +
        'is_archived INTEGER NOT NULL DEFAULT 0' +
      ')'
    );
    await store.executeSql(
      'CREATE TABLE IF NOT EXISTS shopping_items (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'list_id INTEGER NOT NULL, ' +
        'name TEXT NOT NULL, ' +
        'quantity REAL NOT NULL, ' +
        'unit TEXT NOT NULL, ' +
        'category TEXT NOT NULL, ' +
        'is_completed INTEGER NOT NULL DEFAULT 0, ' +
        'create_time INTEGER NOT NULL, ' +
        'note TEXT, ' +
        'FOREIGN KEY(list_id) REFERENCES shopping_lists(id) ON DELETE CASCADE' +
      ')'
    );
  }

  async createList(list: ShoppingList): Promise<number> {
    const store = await this.getStore();
    const values: relationalStore.ValuesBucket = {
      name: list.name,
      category: list.category,
      create_time: list.createTime,
      is_archived: list.isArchived ? 1 : 0
    };
    return await store.insert('shopping_lists', values);
  }

  async getLists(): Promise<ShoppingList[]> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('shopping_lists');
    predicates.equalTo('is_archived', 0);
    predicates.orderByDesc('create_time');

    const resultSet = await store.query(predicates, ['id', 'name', 'category', 'create_time', 'is_archived']);
    const lists: ShoppingList[] = [];

    if (resultSet.goToFirstRow()) {
      do {
        lists.push(this.toShoppingList(resultSet));
      } while (resultSet.goToNextRow());
    }

    resultSet.close();
    return lists;
  }

  async updateList(list: ShoppingList): Promise<void> {
    const store = await this.getStore();
    const values: relationalStore.ValuesBucket = {
      name: list.name,
      category: list.category,
      create_time: list.createTime,
      is_archived: list.isArchived ? 1 : 0
    };
    const predicates = new relationalStore.RdbPredicates('shopping_lists');
    predicates.equalTo('id', list.id);
    await store.update(values, predicates);
  }

  async deleteList(id: number): Promise<void> {
    const store = await this.getStore();

    const itemPredicates = new relationalStore.RdbPredicates('shopping_items');
    itemPredicates.equalTo('list_id', id);
    await store.delete(itemPredicates);

    const listPredicates = new relationalStore.RdbPredicates('shopping_lists');
    listPredicates.equalTo('id', id);
    await store.delete(listPredicates);
  }

  async createItem(item: ShoppingItem): Promise<number> {
    const store = await this.getStore();
    const values: relationalStore.ValuesBucket = {
      list_id: item.listId,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      category: item.category,
      is_completed: item.isCompleted ? 1 : 0,
      create_time: item.createTime,
      note: item.note
    };
    return await store.insert('shopping_items', values);
  }

  async getItemsByListId(listId: number): Promise<ShoppingItem[]> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('shopping_items');
    predicates.equalTo('list_id', listId);
    predicates.orderByAsc('is_completed');
    predicates.orderByDesc('create_time');

    const resultSet = await store.query(
      predicates,
      ['id', 'list_id', 'name', 'quantity', 'unit', 'category', 'is_completed', 'create_time', 'note']
    );
    const items: ShoppingItem[] = [];

    if (resultSet.goToFirstRow()) {
      do {
        items.push(this.toShoppingItem(resultSet));
      } while (resultSet.goToNextRow());
    }

    resultSet.close();
    return items;
  }

  async updateItem(item: ShoppingItem): Promise<void> {
    const store = await this.getStore();
    const values: relationalStore.ValuesBucket = {
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      category: item.category,
      is_completed: item.isCompleted ? 1 : 0,
      create_time: item.createTime,
      note: item.note
    };
    const predicates = new relationalStore.RdbPredicates('shopping_items');
    predicates.equalTo('id', item.id);
    await store.update(values, predicates);
  }

  async deleteItem(id: number): Promise<void> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('shopping_items');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async toggleItemComplete(id: number, isCompleted?: boolean): Promise<void> {
    const store = await this.getStore();
    let targetValue: boolean = isCompleted ?? false;

    if (isCompleted === undefined) {
      const predicates = new relationalStore.RdbPredicates('shopping_items');
      predicates.equalTo('id', id);
      const resultSet = await store.query(predicates, ['is_completed']);
      if (resultSet.goToFirstRow()) {
        targetValue = resultSet.getLong(resultSet.getColumnIndex('is_completed')) !== 1;
      }
      resultSet.close();
    }

    const values: relationalStore.ValuesBucket = {
      is_completed: targetValue ? 1 : 0
    };
    const updatePredicates = new relationalStore.RdbPredicates('shopping_items');
    updatePredicates.equalTo('id', id);
    await store.update(values, updatePredicates);
  }

  async getCompletedCount(listId: number): Promise<number> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('shopping_items');
    predicates.equalTo('list_id', listId);
    predicates.equalTo('is_completed', 1);
    const resultSet = await store.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    return count;
  }

  async getTotalCount(listId: number): Promise<number> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates('shopping_items');
    predicates.equalTo('list_id', listId);
    const resultSet = await store.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    return count;
  }

  private async getStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }

    if (!this.context) {
      this.context = AppStorage.get<common.UIAbilityContext>('abilityContext');
    }

    if (!this.context) {
      throw new Error('ShopDatabase is not initialized');
    }

    this.store = await relationalStore.getRdbStore(this.context, STORE_CONFIG);
    return this.store;
  }

  private toShoppingList(resultSet: relationalStore.ResultSet): ShoppingList {
    return new ShoppingList(
      resultSet.getLong(resultSet.getColumnIndex('id')),
      resultSet.getString(resultSet.getColumnIndex('name')),
      resultSet.getString(resultSet.getColumnIndex('category')) as ShoppingListCategory,
      resultSet.getLong(resultSet.getColumnIndex('create_time')),
      resultSet.getLong(resultSet.getColumnIndex('is_archived')) === 1
    );
  }

  private toShoppingItem(resultSet: relationalStore.ResultSet): ShoppingItem {
    return new ShoppingItem(
      resultSet.getLong(resultSet.getColumnIndex('id')),
      resultSet.getLong(resultSet.getColumnIndex('list_id')),
      resultSet.getString(resultSet.getColumnIndex('name')),
      resultSet.getDouble(resultSet.getColumnIndex('quantity')),
      resultSet.getString(resultSet.getColumnIndex('unit')),
      resultSet.getString(resultSet.getColumnIndex('category')),
      resultSet.getLong(resultSet.getColumnIndex('is_completed')) === 1,
      resultSet.getLong(resultSet.getColumnIndex('create_time')),
      resultSet.getString(resultSet.getColumnIndex('note'))
    );
  }
}
