import relationalStore from '@ohos.data.relationalStore';
import hilog from '@ohos.hilog';
import { CategoryItem, DEFAULT_CATEGORIES } from './CategoryModel';
import { TaskItem } from './TaskModel';

const TAG: string = 'TaskDatabase';
const DOMAIN: number = 0xFF00;
const DB_NAME: string = 'HarmonyTask.db';
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: DB_NAME,
  securityLevel: relationalStore.SecurityLevel.S1
};

const CREATE_TASKS_TABLE: string = `CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  category_id INTEGER DEFAULT 0,
  priority INTEGER DEFAULT 1,
  status INTEGER DEFAULT 0,
  due_date INTEGER,
  reminder_time INTEGER DEFAULT 15,
  reminder_id INTEGER DEFAULT -1,
  created_at INTEGER,
  updated_at INTEGER,
  completed_at INTEGER
)`;

const CREATE_CATEGORIES_TABLE: string = `CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  color TEXT DEFAULT '#FF6B6B',
  sort_order INTEGER DEFAULT 0,
  created_at INTEGER
)`;

export class TaskDatabase {
  private static instance: TaskDatabase | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {
  }

  static getInstance(): TaskDatabase {
    if (!TaskDatabase.instance) {
      TaskDatabase.instance = new TaskDatabase();
    }
    return TaskDatabase.instance;
  }

  async initialize(context: Context): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(CREATE_TASKS_TABLE);
      await this.rdbStore.executeSql(CREATE_CATEGORIES_TABLE);
      await this.initDefaultCategories();
      hilog.info(DOMAIN, TAG, 'Database initialized successfully');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize database: %{public}s', JSON.stringify(err));
    }
  }

  private async initDefaultCategories(): Promise<void> {
    if (!this.rdbStore) return;
    const predicates = new relationalStore.RdbPredicates('categories');
    const resultSet = await this.rdbStore.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    if (count === 0) {
      const now = Date.now();
      for (const cat of DEFAULT_CATEGORIES) {
        const valuesBucket: relationalStore.ValuesBucket = {
          'name': cat.name,
          'color': cat.color,
          'sort_order': cat.sortOrder,
          'created_at': now
        };
        await this.rdbStore.insert('categories', valuesBucket);
      }
      hilog.info(DOMAIN, TAG, 'Default categories inserted');
    }
  }

  getStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }

  // ====== Task CRUD ======

  async insertTask(task: TaskItem): Promise<number> {
    if (!this.rdbStore) return -1;
    const valuesBucket: relationalStore.ValuesBucket = {
      'title': task.title,
      'description': task.description,
      'category_id': task.categoryId,
      'priority': task.priority,
      'status': task.status,
      'due_date': task.dueDate,
      'reminder_time': task.reminderTime,
      'reminder_id': task.reminderId,
      'created_at': task.createdAt,
      'updated_at': task.updatedAt,
      'completed_at': task.completedAt
    };
    const rowId = await this.rdbStore.insert('tasks', valuesBucket);
    return rowId;
  }

  async updateTask(task: TaskItem): Promise<number> {
    if (!this.rdbStore || !task.id) return -1;
    const valuesBucket: relationalStore.ValuesBucket = {
      'title': task.title,
      'description': task.description,
      'category_id': task.categoryId,
      'priority': task.priority,
      'status': task.status,
      'due_date': task.dueDate,
      'reminder_time': task.reminderTime,
      'reminder_id': task.reminderId,
      'updated_at': Date.now(),
      'completed_at': task.completedAt
    };
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('id', task.id);
    const rows = await this.rdbStore.update(valuesBucket, predicates);
    return rows;
  }

  async deleteTask(taskId: number): Promise<number> {
    if (!this.rdbStore) return -1;
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('id', taskId);
    const rows = await this.rdbStore.delete(predicates);
    return rows;
  }

  async queryAllTasks(): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.orderByDesc('priority').orderByAsc('due_date');
    return await this.queryTasks(predicates);
  }

  async queryTasksByCategory(categoryId: number): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('category_id', categoryId);
    predicates.orderByDesc('priority').orderByAsc('due_date');
    return await this.queryTasks(predicates);
  }

  async queryTasksByStatus(status: number): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('status', status);
    predicates.orderByDesc('priority').orderByAsc('due_date');
    return await this.queryTasks(predicates);
  }

  async queryTodayTasks(): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const endOfDay = startOfDay + 24 * 60 * 60 * 1000 - 1;
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.between('due_date', startOfDay, endOfDay);
    predicates.orderByDesc('priority');
    return await this.queryTasks(predicates);
  }

  async queryPendingTasks(limit: number): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.notEqualTo('status', 2);
    predicates.orderByDesc('priority').orderByAsc('due_date');
    predicates.limitAs(limit);
    return await this.queryTasks(predicates);
  }

  async searchTasks(keyword: string): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.contains('title', keyword);
    predicates.orderByDesc('priority');
    return await this.queryTasks(predicates);
  }

  private async queryTasks(predicates: relationalStore.RdbPredicates): Promise<TaskItem[]> {
    if (!this.rdbStore) return [];
    const columns = ['id', 'title', 'description', 'category_id', 'priority', 'status',
      'due_date', 'reminder_time', 'reminder_id', 'created_at', 'updated_at', 'completed_at'];
    const resultSet = await this.rdbStore.query(predicates, columns);
    const tasks: TaskItem[] = [];
    while (resultSet.goToNextRow()) {
      tasks.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        description: resultSet.getString(resultSet.getColumnIndex('description')),
        categoryId: resultSet.getLong(resultSet.getColumnIndex('category_id')),
        priority: resultSet.getLong(resultSet.getColumnIndex('priority')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
        dueDate: resultSet.getLong(resultSet.getColumnIndex('due_date')),
        reminderTime: resultSet.getLong(resultSet.getColumnIndex('reminder_time')),
        reminderId: resultSet.getLong(resultSet.getColumnIndex('reminder_id')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
        completedAt: resultSet.getLong(resultSet.getColumnIndex('completed_at'))
      });
    }
    resultSet.close();
    return tasks;
  }

  // ====== Category CRUD ======

  async insertCategory(category: CategoryItem): Promise<number> {
    if (!this.rdbStore) return -1;
    const valuesBucket: relationalStore.ValuesBucket = {
      'name': category.name,
      'color': category.color,
      'sort_order': category.sortOrder,
      'created_at': Date.now()
    };
    return await this.rdbStore.insert('categories', valuesBucket);
  }

  async updateCategory(category: CategoryItem): Promise<number> {
    if (!this.rdbStore || !category.id) return -1;
    const valuesBucket: relationalStore.ValuesBucket = {
      'name': category.name,
      'color': category.color,
      'sort_order': category.sortOrder
    };
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', category.id);
    return await this.rdbStore.update(valuesBucket, predicates);
  }

  async deleteCategory(categoryId: number): Promise<number> {
    if (!this.rdbStore) return -1;
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', categoryId);
    return await this.rdbStore.delete(predicates);
  }

  async queryAllCategories(): Promise<CategoryItem[]> {
    if (!this.rdbStore) return [];
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.orderByAsc('sort_order');
    const columns = ['id', 'name', 'color', 'sort_order', 'created_at'];
    const resultSet = await this.rdbStore.query(predicates, columns);
    const categories: CategoryItem[] = [];
    while (resultSet.goToNextRow()) {
      categories.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();
    return categories;
  }

  // ====== Stats ======

  async getCompletedCount(startTime: number, endTime: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('status', 2);
    predicates.between('completed_at', startTime, endTime);
    const resultSet = await this.rdbStore.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    return count;
  }

  async getTotalCount(startTime: number, endTime: number): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.between('created_at', startTime, endTime);
    const resultSet = await this.rdbStore.query(predicates, ['id']);
    const count = resultSet.rowCount;
    resultSet.close();
    return count;
  }

  async getTaskCountByCategory(): Promise<Map<number, number>> {
    if (!this.rdbStore) return new Map();
    const predicates = new relationalStore.RdbPredicates('tasks');
    const resultSet = await this.rdbStore.query(predicates, ['category_id']);
    const map = new Map<number, number>();
    while (resultSet.goToNextRow()) {
      const catId = resultSet.getLong(resultSet.getColumnIndex('category_id'));
      map.set(catId, (map.get(catId) || 0) + 1);
    }
    resultSet.close();
    return map;
  }

  async clearCompletedTasks(): Promise<number> {
    if (!this.rdbStore) return 0;
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('status', 2);
    return await this.rdbStore.delete(predicates);
  }
}
