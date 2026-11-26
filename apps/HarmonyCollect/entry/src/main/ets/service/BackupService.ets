/**
 * BackupService.ets — 数据导出与清空
 * 导出至沙箱 filesDir/export/collect_<时间戳>.json
 */
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { ItemDao, WishDao, CategoryDao } from '../model/Db';
import { CollectItem } from '../model/CollectItem';
import { WishItem } from '../model/WishItem';
import { Category } from '../model/Category';
import { Exporter } from '../common/Exporter';
import { Logger } from '../common/Logger';
import { Format } from '../common/Format';

const TAG: string = 'BackupService';

export interface ExportResult {
  ok: boolean;
  path: string;
  message: string;
}

export class BackupService {
  /** 导出全部数据为 JSON 文件，返回文件路径 */
  static async exportJson(context: common.UIAbilityContext): Promise<ExportResult> {
    try {
      const items: CollectItem[] = await ItemDao.queryAll();
      const wishes: WishItem[] = await WishDao.queryAll();
      const categories: Category[] = await CategoryDao.queryAll();
      const content: string = Exporter.build(items, wishes, categories);
      const dir: string = BackupService.ensureExportDir(context);
      const stamp: string = BackupService.timestamp(new Date());
      const filePath: string = dir + '/collect_' + stamp + '.json';
      const file: fs.File = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      try {
        fs.writeSync(file.fd, content);
      } finally {
        fs.closeSync(file);
      }
      Logger.info(TAG, 'exported to ' + filePath);
      const ok: ExportResult = { ok: true, path: filePath, message: '导出成功' };
      return ok;
    } catch (err) {
      Logger.error(TAG, 'export failed: ' + JSON.stringify(err));
      const fail: ExportResult = { ok: false, path: '', message: '导出失败' };
      return fail;
    }
  }

  /** 清空藏品与心愿（保留品类） */
  static async clearData(): Promise<boolean> {
    try {
      await ItemDao.clear();
      await WishDao.clear();
      Logger.info(TAG, 'all data cleared');
      return true;
    } catch (err) {
      Logger.error(TAG, 'clear failed: ' + JSON.stringify(err));
      return false;
    }
  }

  private static ensureExportDir(context: common.UIAbilityContext): string {
    const dir: string = context.filesDir + '/export';
    if (!fs.accessSync(dir)) {
      fs.mkdirSync(dir);
    }
    return dir;
  }

  private static timestamp(d: Date): string {
    const datePart: string = Format.dateToStr(d).replace(/-/g, '');
    const h: string = Format.pad2(d.getHours());
    const m: string = Format.pad2(d.getMinutes());
    const s: string = Format.pad2(d.getSeconds());
    return datePart + '_' + h + m + s;
  }
}
