/**
 * WishService.ets — 心愿单业务逻辑
 * “已入手”：写入 items 生成藏品，并将心愿 status 置 1（保留记录）。
 */
import { WishItem } from '../model/WishItem';
import { CollectItem } from '../model/CollectItem';
import { WishDao, ItemDao, Db } from '../model/Db';
import { Format } from '../common/Format';
import { Logger } from '../common/Logger';
import { WISH_WANTED } from '../common/Constants';

const TAG: string = 'WishService';

export interface WishSaveResult {
  ok: boolean;
  id: number;
  message: string;
}

export interface AcquireResult {
  ok: boolean;
  itemId: number;
  message: string;
}

export class WishService {
  /** 查询心愿：includeAcquired 为 true 时包含已入手 */
  static async list(includeAcquired: boolean): Promise<WishItem[]> {
    try {
      if (includeAcquired) {
        return await WishDao.queryAll();
      }
      return await WishDao.queryByStatus(WISH_WANTED);
    } catch (err) {
      Logger.error(TAG, 'list failed: ' + JSON.stringify(err));
      return [];
    }
  }

  static async detail(id: number): Promise<WishItem | null> {
    try {
      return await WishDao.getById(id);
    } catch (err) {
      Logger.error(TAG, 'detail failed: ' + JSON.stringify(err));
      return null;
    }
  }

  static validate(wish: WishItem): string {
    if (wish.name.trim().length === 0) {
      return '请填写心愿名称';
    }
    if (wish.targetPrice < 0) {
      return '目标价格不能为负数';
    }
    if (wish.priority < 1 || wish.priority > 3) {
      return '优先级需在 1-3 之间';
    }
    return '';
  }

  static async save(wish: WishItem): Promise<WishSaveResult> {
    const error = WishService.validate(wish);
    if (error.length > 0) {
      const fail: WishSaveResult = { ok: false, id: 0, message: error };
      return fail;
    }
    wish.name = wish.name.trim();
    try {
      let id: number = wish.id;
      if (wish.id > 0) {
        await WishDao.update(wish);
      } else {
        id = await WishDao.insert(wish);
      }
      const ok: WishSaveResult = { ok: true, id: id, message: '已保存' };
      return ok;
    } catch (err) {
      Logger.error(TAG, 'save failed: ' + JSON.stringify(err));
      const fail: WishSaveResult = { ok: false, id: 0, message: '保存失败，请重试' };
      return fail;
    }
  }

  static async remove(id: number): Promise<boolean> {
    try {
      const rows: number = await WishDao.remove(id);
      return rows > 0;
    } catch (err) {
      Logger.error(TAG, 'remove failed: ' + JSON.stringify(err));
      return false;
    }
  }

  /** 已入手：心愿 → 藏品，并标记心愿状态 */
  static async acquire(wish: WishItem): Promise<AcquireResult> {
    if (wish.id <= 0) {
      const fail: AcquireResult = { ok: false, itemId: 0, message: '请先保存心愿' };
      return fail;
    }
    const store = Db.getStore();
    let itemId: number = 0;
    try {
      store.beginTransaction();
      const item = new CollectItem();
      item.name = wish.name;
      item.category = wish.category;
      item.condition = '全新';
      item.acquireDate = Format.todayStr();
      item.acquirePrice = wish.targetPrice;
      item.estValue = wish.targetPrice;
      item.remark = wish.remark;
      item.createdAt = Date.now();
      itemId = await ItemDao.insert(item);
      await WishDao.markAcquired(wish.id);
      store.commit();
      Logger.info(TAG, 'acquire wish=' + wish.id + ' item=' + itemId);
      const ok: AcquireResult = { ok: true, itemId: itemId, message: '已加入藏品库' };
      return ok;
    } catch (err) {
      try {
        store.rollBack();
      } catch (rbErr) {
        Logger.error(TAG, 'acquire rollback failed: ' + JSON.stringify(rbErr));
      }
      Logger.error(TAG, 'acquire failed: ' + JSON.stringify(err));
      const fail: AcquireResult = { ok: false, itemId: 0, message: '操作失败，请重试' };
      return fail;
    }
  }

  static newWish(): WishItem {
    const wish = new WishItem();
    wish.priority = 2;
    wish.status = WISH_WANTED;
    wish.createdAt = Date.now();
    return wish;
  }
}
