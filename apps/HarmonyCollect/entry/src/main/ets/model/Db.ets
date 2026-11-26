/**
 * Db.ets — relationalStore 初始化与三表 DAO
 * items / wishlist / categories
 * 所有 SQL 均使用参数化 ValuesBucket / RdbPredicates，避免拼接注入。
 */
import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { CollectItem } from './CollectItem';
import { WishItem } from './WishItem';
import { Category } from './Category';
import { Logger } from '../common/Logger';
import {
  CategorySeed,
  DEFAULT_CATEGORIES,
  ItemFilter,
  SORT_NAME,
  SORT_DATE,
  SORT_VALUE,
  WISH_WANTED,
  WISH_ACQUIRED
} from '../common/Constants';

const TAG: string = 'Db';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_collect.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_ITEMS: string = 'CREATE TABLE IF NOT EXISTS items (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
  'name TEXT NOT NULL, ' +
  'category TEXT NOT NULL DEFAULT \'other\', ' +
  'condition TEXT NOT NULL DEFAULT \'全新\', ' +
  'acquireDate TEXT NOT NULL DEFAULT \'\', ' +
  'acquirePrice REAL NOT NULL DEFAULT 0, ' +
  'estValue REAL NOT NULL DEFAULT 0, ' +
  'serial TEXT NOT NULL DEFAULT \'\', ' +
  'tags TEXT NOT NULL DEFAULT \'\', ' +
  'imageUri TEXT NOT NULL DEFAULT \'\', ' +
  'remark TEXT NOT NULL DEFAULT \'\', ' +
  'createdAt INTEGER NOT NULL DEFAULT 0)';

const SQL_WISHLIST: string = 'CREATE TABLE IF NOT EXISTS wishlist (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
  'name TEXT NOT NULL, ' +
  'category TEXT NOT NULL DEFAULT \'other\', ' +
  'targetPrice REAL NOT NULL DEFAULT 0, ' +
  'priority INTEGER NOT NULL DEFAULT 2, ' +
  'remark TEXT NOT NULL DEFAULT \'\', ' +
  'createdAt INTEGER NOT NULL DEFAULT 0, ' +
  'status INTEGER NOT NULL DEFAULT 0)';

const SQL_CATEGORIES: string = 'CREATE TABLE IF NOT EXISTS categories (' +
  'categoryKey TEXT PRIMARY KEY, ' +
  'name TEXT NOT NULL, ' +
  'icon TEXT NOT NULL DEFAULT \'◈\', ' +
  'sortOrder INTEGER NOT NULL DEFAULT 0, ' +
  'custom INTEGER NOT NULL DEFAULT 0)';

const ITEM_COLUMNS: string[] = [
  'id', 'name', 'category', 'condition', 'acquireDate', 'acquirePrice',
  'estValue', 'serial', 'tags', 'imageUri', 'remark', 'createdAt'
];

const WISH_COLUMNS: string[] = [
  'id', 'name', 'category', 'targetPrice', 'priority', 'remark', 'createdAt', 'status'
];

const CATEGORY_COLUMNS: string[] = ['categoryKey', 'name', 'icon', 'sortOrder', 'custom'];

/** 安全读取字符串列（NULL 回退默认值） */
function readString(rs: relationalStore.ResultSet, column: string, def: string): string {
  const idx = rs.getColumnIndex(column);
  if (idx < 0 || rs.isColumnNull(idx)) {
    return def;
  }
  return rs.getString(idx);
}

/** 安全读取数值列 */
function readNumber(rs: relationalStore.ResultSet, column: string, def: number): number {
  const idx = rs.getColumnIndex(column);
  if (idx < 0 || rs.isColumnNull(idx)) {
    return def;
  }
  return rs.getDouble(idx);
}

function readInt(rs: relationalStore.ResultSet, column: string, def: number): number {
  const idx = rs.getColumnIndex(column);
  if (idx < 0 || rs.isColumnNull(idx)) {
    return def;
  }
  return rs.getLong(idx);
}

function mapItem(rs: relationalStore.ResultSet): CollectItem {
  const item = new CollectItem();
  item.id = readInt(rs, 'id', 0);
  item.name = readString(rs, 'name', '');
  item.category = readString(rs, 'category', 'other');
  item.condition = readString(rs, 'condition', '全新');
  item.acquireDate = readString(rs, 'acquireDate', '');
  item.acquirePrice = readNumber(rs, 'acquirePrice', 0);
  item.estValue = readNumber(rs, 'estValue', 0);
  item.serial = readString(rs, 'serial', '');
  item.tags = readString(rs, 'tags', '');
  item.imageUri = readString(rs, 'imageUri', '');
  item.remark = readString(rs, 'remark', '');
  item.createdAt = readInt(rs, 'createdAt', 0);
  return item;
}

function mapWish(rs: relationalStore.ResultSet): WishItem {
  const wish = new WishItem();
  wish.id = readInt(rs, 'id', 0);
  wish.name = readString(rs, 'name', '');
  wish.category = readString(rs, 'category', 'other');
  wish.targetPrice = readNumber(rs, 'targetPrice', 0);
  wish.priority = readInt(rs, 'priority', 2);
  wish.remark = readString(rs, 'remark', '');
  wish.createdAt = readInt(rs, 'createdAt', 0);
  wish.status = readInt(rs, 'status', WISH_WANTED);
  return wish;
}

function mapCategory(rs: relationalStore.ResultSet): Category {
  const c = new Category();
  c.key = readString(rs, 'categoryKey', '');
  c.name = readString(rs, 'name', '');
  c.icon = readString(rs, 'icon', '◈');
  c.sortOrder = readInt(rs, 'sortOrder', 0);
  c.custom = readInt(rs, 'custom', 0) === 1;
  return c;
}

/** 数据库门面 */
export class Db {
  private static store: relationalStore.RdbStore | null = null;
  private static ready: boolean = false;

  static async init(context: common.Context): Promise<void> {
    if (Db.ready && Db.store !== null) {
      return;
    }
    try {
      const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      Db.store = store;
      await store.executeSql(SQL_ITEMS);
      await store.executeSql(SQL_WISHLIST);
      await store.executeSql(SQL_CATEGORIES);
      Db.ready = true;
      await CategoryDao.seedDefaults();
      Logger.info(TAG, 'database ready');
    } catch (err) {
      Logger.error(TAG, 'init failed: ' + JSON.stringify(err));
      Db.ready = false;
      throw err as Error;
    }
  }

  static getStore(): relationalStore.RdbStore {
    if (Db.store === null) {
      throw new Error('Db not initialized');
    }
    return Db.store;
  }

  static isReady(): boolean {
    return Db.ready;
  }

  /** 等待数据库就绪（用于 UI 首帧可能早于异步初始化完成的情况） */
  static async waitReady(timeoutMs: number): Promise<boolean> {
    if (Db.ready) {
      return true;
    }
    const step: number = 100;
    let waited: number = 0;
    while (waited < timeoutMs) {
      await new Promise<void>((resolve: (value: void) => void) => {
        setTimeout(() => {
          resolve();
        }, step);
      });
      waited += step;
      if (Db.ready) {
        return true;
      }
    }
    return Db.ready;
  }
}

/** 藏品 DAO */
export class ItemDao {
  static buildBucket(item: CollectItem): relationalStore.ValuesBucket {
    const bucket: relationalStore.ValuesBucket = {
      'name': item.name,
      'category': item.category,
      'condition': item.condition,
      'acquireDate': item.acquireDate,
      'acquirePrice': item.acquirePrice,
      'estValue': item.estValue,
      'serial': item.serial,
      'tags': item.tags,
      'imageUri': item.imageUri,
      'remark': item.remark,
      'createdAt': item.createdAt
    };
    return bucket;
  }

  static async insert(item: CollectItem): Promise<number> {
    if (item.createdAt <= 0) {
      item.createdAt = Date.now();
    }
    const rowId: number = await Db.getStore().insert('items', ItemDao.buildBucket(item));
    item.id = rowId;
    Logger.info(TAG, 'insert item id=' + rowId);
    return rowId;
  }

  static async update(item: CollectItem): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('items');
    predicates.equalTo('id', item.id);
    const rows: number = await Db.getStore().update(ItemDao.buildBucket(item), predicates);
    Logger.info(TAG, 'update item id=' + item.id + ' rows=' + rows);
    return rows;
  }

  static async remove(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('items');
    predicates.equalTo('id', id);
    const rows: number = await Db.getStore().delete(predicates);
    Logger.info(TAG, 'delete item id=' + id + ' rows=' + rows);
    return rows;
  }

  static async clear(): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('items');
    return await Db.getStore().delete(predicates);
  }

  static async getById(id: number): Promise<CollectItem | null> {
    const predicates = new relationalStore.RdbPredicates('items');
    predicates.equalTo('id', id);
    const rs = await Db.getStore().query(predicates, ITEM_COLUMNS);
    let result: CollectItem | null = null;
    try {
      if (rs.goToNextRow()) {
        result = mapItem(rs);
      }
    } finally {
      rs.close();
    }
    return result;
  }

  static async queryAll(): Promise<CollectItem[]> {
    const predicates = new relationalStore.RdbPredicates('items');
    predicates.orderByDesc('createdAt');
    return await ItemDao.queryWith(predicates);
  }

  static async query(filter: ItemFilter): Promise<CollectItem[]> {
    const predicates = new relationalStore.RdbPredicates('items');
    let hasCondition: boolean = false;

    if (filter.keyword.length > 0) {
      const like = '%' + filter.keyword + '%';
      predicates.beginWrap();
      predicates.like('name', like);
      predicates.or();
      predicates.like('tags', like);
      predicates.or();
      predicates.like('serial', like);
      predicates.or();
      predicates.like('remark', like);
      predicates.endWrap();
      hasCondition = true;
    }

    if (filter.categories.length > 0) {
      if (hasCondition) {
        predicates.and();
      }
      predicates.in('category', filter.categories);
      hasCondition = true;
    }

    if (filter.conditions.length > 0) {
      if (hasCondition) {
        predicates.and();
      }
      predicates.in('condition', filter.conditions);
      hasCondition = true;
    }

    if (filter.minValue > 0) {
      if (hasCondition) {
        predicates.and();
      }
      predicates.greaterThanOrEqualTo('estValue', filter.minValue);
      hasCondition = true;
    }

    if (filter.maxValue > 0) {
      if (hasCondition) {
        predicates.and();
      }
      predicates.lessThanOrEqualTo('estValue', filter.maxValue);
      hasCondition = true;
    }

    // 排序键 → 真实列名映射，避免把常量键当成列名（如 'created' → 'createdAt'）
    let sortColumn: string = 'createdAt';
    if (filter.sort === SORT_DATE) {
      sortColumn = 'acquireDate';
    } else if (filter.sort === SORT_VALUE) {
      sortColumn = 'estValue';
    } else if (filter.sort === SORT_NAME) {
      sortColumn = 'name';
    }
    if (sortColumn === 'name') {
      predicates.orderByAsc('name');
    } else {
      predicates.orderByDesc(sortColumn);
    }
    predicates.orderByDesc('id');
    return await ItemDao.queryWith(predicates);
  }

  static async queryWith(predicates: relationalStore.RdbPredicates): Promise<CollectItem[]> {
    const rs = await Db.getStore().query(predicates, ITEM_COLUMNS);
    const list: CollectItem[] = [];
    try {
      while (rs.goToNextRow()) {
        list.push(mapItem(rs));
      }
    } finally {
      rs.close();
    }
    return list;
  }

  static async count(): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('items');
    const rs = await Db.getStore().query(predicates, ['id']);
    const total: number = rs.rowCount;
    rs.close();
    return total < 0 ? 0 : total;
  }
}

/** 心愿单 DAO */
export class WishDao {
  static buildBucket(wish: WishItem): relationalStore.ValuesBucket {
    const bucket: relationalStore.ValuesBucket = {
      'name': wish.name,
      'category': wish.category,
      'targetPrice': wish.targetPrice,
      'priority': wish.priority,
      'remark': wish.remark,
      'createdAt': wish.createdAt,
      'status': wish.status
    };
    return bucket;
  }

  static async insert(wish: WishItem): Promise<number> {
    if (wish.createdAt <= 0) {
      wish.createdAt = Date.now();
    }
    const rowId: number = await Db.getStore().insert('wishlist', WishDao.buildBucket(wish));
    wish.id = rowId;
    Logger.info(TAG, 'insert wish id=' + rowId);
    return rowId;
  }

  static async update(wish: WishItem): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.equalTo('id', wish.id);
    return await Db.getStore().update(WishDao.buildBucket(wish), predicates);
  }

  static async remove(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.equalTo('id', id);
    return await Db.getStore().delete(predicates);
  }

  static async clear(): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    return await Db.getStore().delete(predicates);
  }

  static async markAcquired(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.equalTo('id', id);
    const bucket: relationalStore.ValuesBucket = { 'status': WISH_ACQUIRED };
    return await Db.getStore().update(bucket, predicates);
  }

  static async getById(id: number): Promise<WishItem | null> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.equalTo('id', id);
    const rs = await Db.getStore().query(predicates, WISH_COLUMNS);
    let result: WishItem | null = null;
    try {
      if (rs.goToNextRow()) {
        result = mapWish(rs);
      }
    } finally {
      rs.close();
    }
    return result;
  }

  static async queryAll(): Promise<WishItem[]> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.orderByAsc('status');
    predicates.orderByDesc('priority');
    predicates.orderByDesc('createdAt');
    return await WishDao.queryWith(predicates);
  }

  static async queryByStatus(status: number): Promise<WishItem[]> {
    const predicates = new relationalStore.RdbPredicates('wishlist');
    predicates.equalTo('status', status);
    predicates.orderByDesc('priority');
    predicates.orderByDesc('createdAt');
    return await WishDao.queryWith(predicates);
  }

  static async queryWith(predicates: relationalStore.RdbPredicates): Promise<WishItem[]> {
    const rs = await Db.getStore().query(predicates, WISH_COLUMNS);
    const list: WishItem[] = [];
    try {
      while (rs.goToNextRow()) {
        list.push(mapWish(rs));
      }
    } finally {
      rs.close();
    }
    return list;
  }
}

/** 品类 DAO */
export class CategoryDao {
  static async seedDefaults(): Promise<void> {
    const existing: Category[] = await CategoryDao.queryAll();
    if (existing.length > 0) {
      return;
    }
    for (let i = 0; i < DEFAULT_CATEGORIES.length; i++) {
      const seed: CategorySeed = DEFAULT_CATEGORIES[i];
      const c = new Category();
      c.key = seed.key;
      c.name = seed.name;
      c.icon = seed.icon;
      c.sortOrder = i;
      c.custom = false;
      await CategoryDao.insert(c);
    }
    Logger.info(TAG, 'seeded default categories');
  }

  static async insert(category: Category): Promise<void> {
    const bucket: relationalStore.ValuesBucket = {
      'categoryKey': category.key,
      'name': category.name,
      'icon': category.icon,
      'sortOrder': category.sortOrder,
      'custom': category.custom ? 1 : 0
    };
    await Db.getStore().insert('categories', bucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
  }

  static async queryAll(): Promise<Category[]> {
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.orderByAsc('sortOrder');
    const rs = await Db.getStore().query(predicates, CATEGORY_COLUMNS);
    const list: Category[] = [];
    try {
      while (rs.goToNextRow()) {
        list.push(mapCategory(rs));
      }
    } finally {
      rs.close();
    }
    return list;
  }

  static async getByKey(key: string): Promise<Category | null> {
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('categoryKey', key);
    const rs = await Db.getStore().query(predicates, CATEGORY_COLUMNS);
    let result: Category | null = null;
    try {
      if (rs.goToNextRow()) {
        result = mapCategory(rs);
      }
    } finally {
      rs.close();
    }
    return result;
  }

  static async removeCustom(key: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('categoryKey', key);
    predicates.and();
    predicates.equalTo('custom', 1);
    return await Db.getStore().delete(predicates);
  }

  static nameOf(categories: Category[], key: string): string {
    for (let i = 0; i < categories.length; i++) {
      if (categories[i].key === key) {
        return categories[i].name;
      }
    }
    return key;
  }

  static iconOf(categories: Category[], key: string): string {
    for (let i = 0; i < categories.length; i++) {
      if (categories[i].key === key) {
        return categories[i].icon;
      }
    }
    return '◈';
  }
}
