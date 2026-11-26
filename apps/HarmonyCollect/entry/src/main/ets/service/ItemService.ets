/**
 * ItemService.ets — 藏品业务逻辑（校验、保存、删除、图片清理）
 */
import { CollectItem } from '../model/CollectItem';
import { ItemDao } from '../model/Db';
import { ItemFilter, defaultFilter } from '../common/Constants';
import { ImageStore } from '../common/ImageStore';
import { Format } from '../common/Format';
import { Logger } from '../common/Logger';

const TAG: string = 'ItemService';

export interface SaveResult {
  ok: boolean;
  id: number;
  message: string;
}

export class ItemService {
  /** 按筛选条件查询 */
  static async list(filter: ItemFilter): Promise<CollectItem[]> {
    try {
      return await ItemDao.query(filter);
    } catch (err) {
      Logger.error(TAG, 'list failed: ' + JSON.stringify(err));
      return [];
    }
  }

  static async all(): Promise<CollectItem[]> {
    try {
      return await ItemDao.queryAll();
    } catch (err) {
      Logger.error(TAG, 'all failed: ' + JSON.stringify(err));
      return [];
    }
  }

  static async detail(id: number): Promise<CollectItem | null> {
    try {
      return await ItemDao.getById(id);
    } catch (err) {
      Logger.error(TAG, 'detail failed: ' + JSON.stringify(err));
      return null;
    }
  }

  /** 校验表单，返回错误信息（空串表示通过） */
  static validate(item: CollectItem): string {
    if (item.name.trim().length === 0) {
      return '请填写藏品名称';
    }
    if (item.name.trim().length > 40) {
      return '名称不能超过 40 个字';
    }
    if (item.acquirePrice < 0) {
      return '入手价格不能为负数';
    }
    if (item.estValue < 0) {
      return '估值不能为负数';
    }
    return '';
  }

  /** 保存（新增或更新） */
  static async save(item: CollectItem): Promise<SaveResult> {
    const error = ItemService.validate(item);
    if (error.length > 0) {
      const fail: SaveResult = { ok: false, id: 0, message: error };
      return fail;
    }
    item.name = item.name.trim();
    if (item.acquireDate.length === 0) {
      item.acquireDate = Format.todayStr();
    }
    try {
      let id: number = item.id;
      if (item.id > 0) {
        await ItemDao.update(item);
      } else {
        id = await ItemDao.insert(item);
      }
      const ok: SaveResult = { ok: true, id: id, message: '已保存' };
      return ok;
    } catch (err) {
      Logger.error(TAG, 'save failed: ' + JSON.stringify(err));
      const fail: SaveResult = { ok: false, id: 0, message: '保存失败，请重试' };
      return fail;
    }
  }

  /** 删除藏品并清理沙箱图片 */
  static async remove(id: number): Promise<boolean> {
    try {
      const item: CollectItem | null = await ItemDao.getById(id);
      const rows: number = await ItemDao.remove(id);
      if (item !== null && item.imageUri.length > 0) {
        ImageStore.deleteFile(item.imageUri);
      }
      return rows > 0;
    } catch (err) {
      Logger.error(TAG, 'remove failed: ' + JSON.stringify(err));
      return false;
    }
  }

  /** 默认新藏品 */
  static newItem(): CollectItem {
    const item = new CollectItem();
    item.condition = '全新';
    item.acquireDate = Format.todayStr();
    item.createdAt = Date.now();
    return item;
  }

  static defaultFilter(): ItemFilter {
    return defaultFilter();
  }
}
