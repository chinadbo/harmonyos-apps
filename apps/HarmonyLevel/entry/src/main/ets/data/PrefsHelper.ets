import dataPreferences from '@ohos.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import {
  AppSettings,
  CalibOffset,
  DEFAULT_OFFSET,
  DEFAULT_SETTINGS,
  HISTORY_LIMIT,
  MeasureRecord
} from '../model/Measure';

const STORE_NAME: string = 'level_store';
const KEY_HISTORY: string = 'history_list';
const KEY_CALIB: string = 'calib_offset';
const KEY_SETTINGS: string = 'settings';

export class PrefsHelper {
  private static getStore(context: common.Context): Promise<dataPreferences.Preferences> {
    return dataPreferences.getPreferences(context, STORE_NAME);
  }

  static async getHistory(context: common.Context): Promise<MeasureRecord[]> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      const text: string = (await prefs.get(KEY_HISTORY, '[]')).toString();
      return PrefsHelper.parseHistory(text);
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] getHistory failed: ${e.code} ${e.message}`);
      return [];
    }
  }

  static async addRecord(context: common.Context, record: MeasureRecord): Promise<MeasureRecord[]> {
    const list: MeasureRecord[] = await PrefsHelper.getHistory(context);
    list.unshift(record);
    while (list.length > HISTORY_LIMIT) {
      list.pop();
    }
    await PrefsHelper.saveHistory(context, list);
    return list;
  }

  static async deleteRecord(context: common.Context, id: number): Promise<MeasureRecord[]> {
    const list: MeasureRecord[] = await PrefsHelper.getHistory(context);
    const remained: MeasureRecord[] = [];
    for (let i = 0; i < list.length; i++) {
      if (list[i].id !== id) {
        remained.push(list[i]);
      }
    }
    await PrefsHelper.saveHistory(context, remained);
    return remained;
  }

  static async clearHistory(context: common.Context): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      await prefs.delete(KEY_HISTORY);
      await prefs.flush();
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] clearHistory failed: ${e.code} ${e.message}`);
    }
  }

  static async getCalib(context: common.Context): Promise<CalibOffset> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      const text: string = (await prefs.get(KEY_CALIB, '')).toString();
      if (text.length === 0) {
        return { x: DEFAULT_OFFSET.x, y: DEFAULT_OFFSET.y };
      }
      const obj = JSON.parse(text) as Record<string, Object>;
      return {
        x: Number(obj['x']),
        y: Number(obj['y'])
      };
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] getCalib failed: ${e.code} ${e.message}`);
      return { x: DEFAULT_OFFSET.x, y: DEFAULT_OFFSET.y };
    }
  }

  static async saveCalib(context: common.Context, offset: CalibOffset): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      await prefs.put(KEY_CALIB, JSON.stringify(offset));
      await prefs.flush();
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] saveCalib failed: ${e.code} ${e.message}`);
    }
  }

  static async getSettings(context: common.Context): Promise<AppSettings> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      const text: string = (await prefs.get(KEY_SETTINGS, '')).toString();
      if (text.length === 0) {
        return {
          sensitivity: DEFAULT_SETTINGS.sensitivity,
          sound: DEFAULT_SETTINGS.sound,
          keepScreenOn: DEFAULT_SETTINGS.keepScreenOn
        };
      }
      const obj = JSON.parse(text) as Record<string, Object>;
      return {
        sensitivity: Number(obj['sensitivity']),
        sound: Boolean(obj['sound']),
        keepScreenOn: Boolean(obj['keepScreenOn'])
      };
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] getSettings failed: ${e.code} ${e.message}`);
      return {
        sensitivity: DEFAULT_SETTINGS.sensitivity,
        sound: DEFAULT_SETTINGS.sound,
        keepScreenOn: DEFAULT_SETTINGS.keepScreenOn
      };
    }
  }

  static async saveSettings(context: common.Context, settings: AppSettings): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      await prefs.put(KEY_SETTINGS, JSON.stringify(settings));
      await prefs.flush();
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] saveSettings failed: ${e.code} ${e.message}`);
    }
  }

  private static async saveHistory(context: common.Context, list: MeasureRecord[]): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await PrefsHelper.getStore(context);
      await prefs.put(KEY_HISTORY, JSON.stringify(list));
      await prefs.flush();
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyLevel] saveHistory failed: ${e.code} ${e.message}`);
    }
  }

  private static parseHistory(text: string): MeasureRecord[] {
    const list: MeasureRecord[] = [];
    try {
      const parsed = JSON.parse(text) as Record<string, Object>[];
      for (let i = 0; i < parsed.length; i++) {
        const item = parsed[i];
        list.push({
          id: Number(item['id']),
          mode: String(item['mode']),
          angleX: Number(item['angleX']),
          angleY: Number(item['angleY']),
          ts: Number(item['ts'])
        });
      }
    } catch (err) {
      console.error('[HarmonyLevel] parseHistory failed: ' + JSON.stringify(err));
    }
    return list;
  }
}
