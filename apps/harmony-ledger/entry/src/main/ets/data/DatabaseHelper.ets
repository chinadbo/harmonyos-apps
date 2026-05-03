import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Budget, Category, Transaction, WidgetSummary } from './DataModels';
import { DateUtils } from '../utils/DateUtils';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmonyledger.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const DEFAULT_CATEGORIES: Category[] = [
  { id: 1, name: '餐饮', icon: '🍜', color: '#FF7043', type: 'expense', isSystem: true, sortOrder: 1 },
  { id: 2, name: '交通', icon: '🚌', color: '#42A5F5', type: 'expense', isSystem: true, sortOrder: 2 },
  { id: 3, name: '购物', icon: '🛍️', color: '#AB47BC', type: 'expense', isSystem: true, sortOrder: 3 },
  { id: 4, name: '住房', icon: '🏠', color: '#26A69A', type: 'expense', isSystem: true, sortOrder: 4 },
  { id: 5, name: '娱乐', icon: '🎮', color: '#EC407A', type: 'expense', isSystem: true, sortOrder: 5 },
  { id: 6, name: '医疗', icon: '💊', color: '#66BB6A', type: 'expense', isSystem: true, sortOrder: 6 },
  { id: 7, name: '工资', icon: '💼', color: '#5C6BC0', type: 'income', isSystem: true, sortOrder: 7 },
  { id: 8, name: '奖金', icon: '🎁', color: '#FFA726', type: 'income', isSystem: true, sortOrder: 8 }
];

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper();
  private store?: relationalStore.RdbStore;
  private context?: common.Context;
  private initPromise?: Promise<void>;
  private initialized: boolean = false;

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance;
  }

  setContext(context: common.Context): void {
    this.context = context;
  }

  requireContext(): common.Context {
    if (!this.context) {
      throw new Error('Database context is not initialized');
    }
    return this.context;
  }

  async init(context: common.Context): Promise<void> {
    this.context = context;
    if (this.initialized) {
      return;
    }
    if (!this.initPromise) {
      this.initPromise = (async () => {
        const store: relationalStore.RdbStore = await this.ensureStore();
        await this.prepareTables(store);
        await this.prepareDefaultData(store);
        const currency = await this.getSettingFromStore(store, 'currency');
        AppStorage.setOrCreate('currency', currency ?? '¥');
        this.initialized = true;
      })();
    }
    await this.initPromise;
  }

  private async ensureStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    if (!this.context) {
      throw new Error('Database context is not initialized');
    }
    this.store = await relationalStore.getRdbStore(this.context, STORE_CONFIG);
    return this.store;
  }

  async getStore(): Promise<relationalStore.RdbStore> {
    if (this.initPromise) {
      await this.initPromise;
    }
    return await this.ensureStore();
  }

  private async prepareTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(`CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      categoryId INTEGER NOT NULL,
      note TEXT NOT NULL,
      date TEXT NOT NULL,
      createdAt INTEGER NOT NULL
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      type TEXT NOT NULL,
      isSystem INTEGER NOT NULL,
      sortOrder INTEGER NOT NULL
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      categoryId INTEGER NOT NULL,
      month TEXT NOT NULL,
      amount REAL NOT NULL
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )`);
  }

  private async prepareDefaultData(store: relationalStore.RdbStore): Promise<void> {
    const categoryRows: Category[] = await this.queryCategories(store);
    if (categoryRows.length === 0) {
      for (const category of DEFAULT_CATEGORIES) {
        await store.insert('categories', {
          id: category.id,
          name: category.name,
          icon: category.icon,
          color: category.color,
          type: category.type,
          isSystem: category.isSystem ? 1 : 0,
          sortOrder: category.sortOrder
        });
      }
    }
    const currency: string | null = await this.getSettingFromStore(store, 'currency');
    if (currency === null) {
      await store.insert('settings', {
        key: 'currency',
        value: '¥'
      });
    }
  }

  private async getSettingFromStore(store: relationalStore.RdbStore, key: string): Promise<string | null> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('settings');
    predicates.equalTo('key', key);
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['key', 'value']);
    let value: string | null = null;
    if (resultSet.goToFirstRow()) {
      value = resultSet.getString(resultSet.getColumnIndex('value'));
    }
    resultSet.close();
    return value;
  }

  private async queryCategories(store: relationalStore.RdbStore): Promise<Category[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('categories');
    predicates.orderByAsc('sortOrder');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id', 'name', 'icon', 'color', 'type', 'isSystem', 'sortOrder']);
    const categories: Category[] = [];
    while (resultSet.goToNextRow()) {
      categories.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        type: resultSet.getString(resultSet.getColumnIndex('type')) as 'income' | 'expense' | 'both',
        isSystem: resultSet.getLong(resultSet.getColumnIndex('isSystem')) === 1,
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sortOrder'))
      });
    }
    resultSet.close();
    return categories;
  }

  async getSetting(key: string): Promise<string | null> {
    const store: relationalStore.RdbStore = await this.getStore();
    return await this.getSettingFromStore(store, key);
  }

  async setSetting(key: string, value: string): Promise<void> {
    const store: relationalStore.RdbStore = await this.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('settings');
    predicates.equalTo('key', key);
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['key']);
    const exists: boolean = resultSet.goToFirstRow();
    resultSet.close();
    if (exists) {
      const updatePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('settings');
      updatePredicates.equalTo('key', key);
      await store.update({ value }, updatePredicates);
    } else {
      await store.insert('settings', { key, value });
    }
    if (key === 'currency') {
      AppStorage.setOrCreate('currency', value);
    }
  }

  async getCurrency(): Promise<string> {
    return (await this.getSetting('currency')) ?? '¥';
  }

  async setCurrency(currency: string): Promise<void> {
    await this.setSetting('currency', currency);
  }

  async getWidgetSummary(): Promise<WidgetSummary> {
    const store: relationalStore.RdbStore = await this.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('transactions');
    predicates.orderByDesc('date');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id', 'type', 'amount', 'categoryId', 'note', 'date', 'createdAt']);
    const month: string = DateUtils.currentMonthKey();
    const today: string = DateUtils.currentDateString();
    let income: number = 0;
    let expense: number = 0;
    let todayExpense: number = 0;
    while (resultSet.goToNextRow()) {
      const type: 'income' | 'expense' = resultSet.getString(resultSet.getColumnIndex('type')) as 'income' | 'expense';
      const amount: number = resultSet.getDouble(resultSet.getColumnIndex('amount'));
      const date: string = resultSet.getString(resultSet.getColumnIndex('date'));
      if (DateUtils.isSameMonth(date, month)) {
        if (type === 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }
      if (date === today && type === 'expense') {
        todayExpense += amount;
      }
    }
    resultSet.close();
    return {
      monthlyBalance: income - expense,
      todayExpense,
      currency: await this.getCurrency()
    };
  }

  async listAllTransactions(): Promise<Transaction[]> {
    const store: relationalStore.RdbStore = await this.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('transactions');
    predicates.orderByDesc('date');
    predicates.orderByDesc('id');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id', 'type', 'amount', 'categoryId', 'note', 'date', 'createdAt']);
    const items: Transaction[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        type: resultSet.getString(resultSet.getColumnIndex('type')) as 'income' | 'expense',
        amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
        categoryId: resultSet.getLong(resultSet.getColumnIndex('categoryId')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
      });
    }
    resultSet.close();
    return items;
  }

  async listAllBudgets(): Promise<Budget[]> {
    const store: relationalStore.RdbStore = await this.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('budgets');
    predicates.orderByAsc('categoryId');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id', 'categoryId', 'month', 'amount']);
    const items: Budget[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        categoryId: resultSet.getLong(resultSet.getColumnIndex('categoryId')),
        month: resultSet.getString(resultSet.getColumnIndex('month')),
        amount: resultSet.getDouble(resultSet.getColumnIndex('amount'))
      });
    }
    resultSet.close();
    return items;
  }
}
