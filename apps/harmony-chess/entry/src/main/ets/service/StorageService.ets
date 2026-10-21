import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { GameRecord } from '../model/Types';
import { Logger } from '../common/Logger';

/**
 * 棋谱偏好存储：GameRecord JSON 数组（同步 API，简化调用方）
 */
export class StorageService {
  private static PREF_NAME: string = 'harmony_chess_pref';
  private static KEY_RECORDS: string = 'game_records';
  private static pref: preferences.Preferences | null = null;
  private static ctx: common.UIAbilityContext | null = null;

  static init(ctx: common.UIAbilityContext): void {
    StorageService.ctx = ctx;
    try {
      StorageService.pref = preferences.getPreferencesSync(ctx, { name: StorageService.PREF_NAME });
      Logger.i('StorageService init ok');
    } catch (e) {
      Logger.e('StorageService init failed: ' + JSON.stringify(e));
    }
  }

  private static ensurePref(): preferences.Preferences | null {
    if (StorageService.pref !== null) return StorageService.pref;
    if (StorageService.ctx === null) return null;
    try {
      StorageService.pref = preferences.getPreferencesSync(StorageService.ctx,
        { name: StorageService.PREF_NAME });
      return StorageService.pref;
    } catch (e) {
      Logger.e('ensurePref failed: ' + JSON.stringify(e));
      return null;
    }
  }

  static listRecords(): Array<GameRecord> {
    const pref = StorageService.ensurePref();
    if (pref === null) return [];
    try {
      const raw = pref.getSync(StorageService.KEY_RECORDS, '[]') as string;
      const arr = JSON.parse(raw) as Array<GameRecord>;
      if (!Array.isArray(arr)) return [];
      // 按时间倒序
      arr.sort((a, b) => b.createdAt - a.createdAt);
      return arr;
    } catch (e) {
      Logger.e('listRecords failed: ' + JSON.stringify(e));
      return [];
    }
  }

  static saveRecord(rec: GameRecord): boolean {
    const pref = StorageService.ensurePref();
    if (pref === null) return false;
    try {
      const arr = StorageService.listRecords();
      arr.unshift(rec);
      pref.putSync(StorageService.KEY_RECORDS, JSON.stringify(arr));
      pref.flush();
      Logger.i('saveRecord ok: ' + rec.id);
      return true;
    } catch (e) {
      Logger.e('saveRecord failed: ' + JSON.stringify(e));
      return false;
    }
  }

  static deleteRecord(id: string): boolean {
    const pref = StorageService.ensurePref();
    if (pref === null) return false;
    try {
      const arr = StorageService.listRecords();
      const filtered: Array<GameRecord> = [];
      for (const r of arr) {
        if (r.id !== id) filtered.push(r);
      }
      pref.putSync(StorageService.KEY_RECORDS, JSON.stringify(filtered));
      pref.flush();
      return true;
    } catch (e) {
      Logger.e('deleteRecord failed: ' + JSON.stringify(e));
      return false;
    }
  }

  static getRecord(id: string): GameRecord | null {
    const arr = StorageService.listRecords();
    for (const r of arr) {
      if (r.id === id) return r;
    }
    return null;
  }
}
