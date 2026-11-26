/**
 * Prefs.ets — 轻量偏好存储（设置项持久化）
 * 与 AppStorage 配合：启动时从 Preferences 读取写入 AppStorage，修改时双向写入。
 */
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { Logger } from './Logger';
import {
  KEY_VIEW_MODE,
  KEY_SORT_MODE,
  KEY_SHOW_ACQUIRED,
  DEFAULT_VIEW_MODE,
  DEFAULT_SORT_MODE,
  DEFAULT_SHOW_ACQUIRED
} from './Constants';

const TAG: string = 'Prefs';
const STORE_NAME: string = 'collect_settings';

export class Prefs {
  private static store: preferences.Preferences | null = null;

  static async init(context: common.Context): Promise<void> {
    try {
      Prefs.store = await preferences.getPreferences(context, STORE_NAME);
      Logger.info(TAG, 'preferences ready');
    } catch (err) {
      Logger.error(TAG, 'init failed: ' + JSON.stringify(err));
    }
  }

  /** 读取设置并写入 AppStorage */
  static async loadIntoSettings(): Promise<void> {
    const viewMode: string = await Prefs.getString(KEY_VIEW_MODE, DEFAULT_VIEW_MODE);
    const sortMode: string = await Prefs.getString(KEY_SORT_MODE, DEFAULT_SORT_MODE);
    const showAcquired: boolean = await Prefs.getBoolean(KEY_SHOW_ACQUIRED, DEFAULT_SHOW_ACQUIRED);
    AppStorage.setOrCreate<string>(KEY_VIEW_MODE, viewMode);
    AppStorage.setOrCreate<string>(KEY_SORT_MODE, sortMode);
    AppStorage.setOrCreate<boolean>(KEY_SHOW_ACQUIRED, showAcquired);
  }

  static async getString(key: string, def: string): Promise<string> {
    if (Prefs.store === null) {
      return def;
    }
    try {
      const value = await Prefs.store.get(key, def);
      return value as string;
    } catch (err) {
      return def;
    }
  }

  static async getBoolean(key: string, def: boolean): Promise<boolean> {
    if (Prefs.store === null) {
      return def;
    }
    try {
      const value = await Prefs.store.get(key, def);
      return value as boolean;
    } catch (err) {
      return def;
    }
  }

  static async getInt(key: string, def: number): Promise<number> {
    if (Prefs.store === null) {
      return def;
    }
    try {
      const value = await Prefs.store.get(key, def);
      return value as number;
    } catch (err) {
      return def;
    }
  }

  static async putString(key: string, value: string): Promise<void> {
    if (Prefs.store === null) {
      return;
    }
    try {
      await Prefs.store.put(key, value);
      await Prefs.store.flush();
    } catch (err) {
      Logger.warn(TAG, 'putString failed: ' + key);
    }
  }

  static async putBoolean(key: string, value: boolean): Promise<void> {
    if (Prefs.store === null) {
      return;
    }
    try {
      await Prefs.store.put(key, value);
      await Prefs.store.flush();
    } catch (err) {
      Logger.warn(TAG, 'putBoolean failed: ' + key);
    }
  }

  static async putInt(key: string, value: number): Promise<void> {
    if (Prefs.store === null) {
      return;
    }
    try {
      await Prefs.store.put(key, value);
      await Prefs.store.flush();
    } catch (err) {
      Logger.warn(TAG, 'putInt failed: ' + key);
    }
  }
}
