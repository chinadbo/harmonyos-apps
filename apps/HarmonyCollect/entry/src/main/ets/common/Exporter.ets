/**
 * Exporter.ets — 导出数据序列化（纯本地 JSON，不含图片二进制）
 */
import { CollectItem } from '../model/CollectItem';
import { WishItem } from '../model/WishItem';
import { Category } from '../model/Category';

export interface ExportMeta {
  app: string;
  version: string;
  exportedAt: string;
  itemCount: number;
  wishCount: number;
  note: string;
}

export interface ExportPayload {
  meta: ExportMeta;
  items: CollectItem[];
  wishlist: WishItem[];
  categories: Category[];
}

export class Exporter {
  static build(items: CollectItem[], wishes: WishItem[], categories: Category[]): string {
    const meta: ExportMeta = {
      app: 'HarmonyCollect',
      version: '1.0.0',
      exportedAt: new Date().toISOString(),
      itemCount: items.length,
      wishCount: wishes.length,
      note: '本地导出，图片文件未包含，仅保存沙箱相对路径。'
    };
    const payload: ExportPayload = {
      meta: meta,
      items: items,
      wishlist: wishes,
      categories: categories
    };
    return JSON.stringify(payload, null, 2);
  }
}
