import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

export class PreferencesHelper {
  private static instance?: preferences.Preferences;
  private static readonly NAME: string = 'harmony_calc_prefs';

  private static async getPreferences(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    if (this.instance) {
      return this.instance;
    }
    this.instance = await preferences.getPreferences(context, { name: this.NAME });
    return this.instance;
  }

  static async putString(context: common.UIAbilityContext, key: string, value: string): Promise<void> {
    const pref: preferences.Preferences = await this.getPreferences(context);
    await pref.put(key, value);
    await pref.flush();
  }

  static async getString(context: common.UIAbilityContext, key: string, defaultValue: string = ''): Promise<string> {
    const pref: preferences.Preferences = await this.getPreferences(context);
    const value: Object = await pref.get(key, defaultValue);
    return typeof value === 'string' ? value : defaultValue;
  }

  static async putNumber(context: common.UIAbilityContext, key: string, value: number): Promise<void> {
    const pref: preferences.Preferences = await this.getPreferences(context);
    await pref.put(key, value);
    await pref.flush();
  }

  static async getNumber(context: common.UIAbilityContext, key: string, defaultValue: number = 0): Promise<number> {
    const pref: preferences.Preferences = await this.getPreferences(context);
    const value: Object = await pref.get(key, defaultValue);
    return typeof value === 'number' ? value : defaultValue;
  }

  static async putJson(context: common.UIAbilityContext, key: string, value: Object): Promise<void> {
    await this.putString(context, key, JSON.stringify(value));
  }

  static async getJson<T>(context: common.UIAbilityContext, key: string, defaultValue: T): Promise<T> {
    const text: string = await this.getString(context, key, '');
    if (text.length === 0) {
      return defaultValue;
    }
    try {
      return JSON.parse(text) as T;
    } catch (error) {
      return defaultValue;
    }
  }
}
