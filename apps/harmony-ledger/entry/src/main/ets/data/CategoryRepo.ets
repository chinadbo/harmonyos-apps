import relationalStore from '@ohos.data.relationalStore';
import { Category, CategoryType } from './DataModels';
import { DatabaseHelper } from './DatabaseHelper';

export class CategoryRepo {
  private static instance: CategoryRepo = new CategoryRepo();
  private db: DatabaseHelper = DatabaseHelper.getInstance();

  static getInstance(): CategoryRepo {
    return CategoryRepo.instance;
  }

  async listAll(): Promise<Category[]> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('categories');
    predicates.orderByAsc('sortOrder');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['id', 'name', 'icon', 'color', 'type', 'isSystem', 'sortOrder']);
    const items: Category[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        type: resultSet.getString(resultSet.getColumnIndex('type')) as CategoryType,
        isSystem: resultSet.getLong(resultSet.getColumnIndex('isSystem')) === 1,
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sortOrder'))
      });
    }
    resultSet.close();
    return items;
  }

  async listForType(type: 'income' | 'expense'): Promise<Category[]> {
    const items: Category[] = await this.listAll();
    return items.filter((item: Category) => item.type === 'both' || item.type === type);
  }

  async getById(id: number): Promise<Category | null> {
    const items: Category[] = await this.listAll();
    const target: Category | undefined = items.find((item: Category) => item.id === id);
    return target ?? null;
  }

  async create(payload: Omit<Category, 'id' | 'isSystem'>): Promise<number> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const existing: Category[] = await this.listAll();
    const nextId: number = existing.length > 0 ? Math.max(...existing.map((item: Category) => item.id)) + 1 : 1;
    await store.insert('categories', {
      id: nextId,
      name: payload.name,
      icon: payload.icon,
      color: payload.color,
      type: payload.type,
      isSystem: 0,
      sortOrder: payload.sortOrder
    });
    return nextId;
  }

  async update(category: Category): Promise<void> {
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', category.id);
    await store.update({
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
      isSystem: category.isSystem ? 1 : 0,
      sortOrder: category.sortOrder
    }, predicates);
  }

  async delete(id: number): Promise<void> {
    const category: Category | null = await this.getById(id);
    if (category?.isSystem) {
      return;
    }
    const store: relationalStore.RdbStore = await this.db.getStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async getMap(): Promise<Record<number, Category>> {
    const map: Record<number, Category> = {};
    const items: Category[] = await this.listAll();
    items.forEach((item: Category) => {
      map[item.id] = item;
    });
    return map;
  }
}
