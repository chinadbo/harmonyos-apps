import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { LoanInput } from '../model/LoanTypes';

const STORE_NAME: string = 'loan_prefs';
const KEY_LPR: string = 'lpr_bp';
const KEY_GJJ: string = 'gjj_rate_bp';
const KEY_LAST_INPUT: string = 'last_input';

export default class PrefsService {
  private static store: preferences.Preferences | null = null;

  static async init(context: common.Context): Promise<void> {
    if (PrefsService.store === null) {
      PrefsService.store = await preferences.getPreferences(context, STORE_NAME);
    }
  }

  private static async ensureStore(context: common.Context): Promise<preferences.Preferences> {
    if (PrefsService.store === null) {
      PrefsService.store = await preferences.getPreferences(context, STORE_NAME);
    }
    return PrefsService.store;
  }

  static async getNumber(context: common.Context, key: string, def: number): Promise<number> {
    try {
      const store = await PrefsService.ensureStore(context);
      const value = await store.get(key, def);
      if (typeof value === 'number') {
        return value;
      }
      return def;
    } catch (e) {
      return def;
    }
  }

  static async putNumber(context: common.Context, key: string, value: number): Promise<void> {
    try {
      const store = await PrefsService.ensureStore(context);
      await store.put(key, value);
      await store.flush();
    } catch (e) {
      console.error(`PrefsService putNumber failed: ${JSON.stringify(e)}`);
    }
  }

  static async getString(context: common.Context, key: string, def: string): Promise<string> {
    try {
      const store = await PrefsService.ensureStore(context);
      const value = await store.get(key, def);
      if (typeof value === 'string') {
        return value;
      }
      return def;
    } catch (e) {
      return def;
    }
  }

  static async putString(context: common.Context, key: string, value: string): Promise<void> {
    try {
      const store = await PrefsService.ensureStore(context);
      await store.put(key, value);
      await store.flush();
    } catch (e) {
      console.error(`PrefsService putString failed: ${JSON.stringify(e)}`);
    }
  }

  static async getLprBp(context: common.Context): Promise<number> {
    return PrefsService.getNumber(context, KEY_LPR, 350);
  }

  static async setLprBp(context: common.Context, bp: number): Promise<void> {
    await PrefsService.putNumber(context, KEY_LPR, bp);
  }

  static async getGjjBp(context: common.Context): Promise<number> {
    return PrefsService.getNumber(context, KEY_GJJ, 285);
  }

  static async setGjjBp(context: common.Context, bp: number): Promise<void> {
    await PrefsService.putNumber(context, KEY_GJJ, bp);
  }

  static async saveLastInput(context: common.Context, input: LoanInput): Promise<void> {
    await PrefsService.putString(context, KEY_LAST_INPUT, JSON.stringify(input));
  }

  static async getLastInput(context: common.Context): Promise<LoanInput | null> {
    const text = await PrefsService.getString(context, KEY_LAST_INPUT, '');
    if (text.length === 0) {
      return null;
    }
    try {
      return JSON.parse(text) as LoanInput;
    } catch (e) {
      return null;
    }
  }
}
