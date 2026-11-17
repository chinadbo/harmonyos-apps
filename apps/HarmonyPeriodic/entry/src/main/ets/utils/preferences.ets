import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export const PREFERENCES_NAME: string = 'harmony_periodic_settings';
export const KEY_COLOR_SCHEME: string = 'colorScheme';
export const DEFAULT_COLOR_SCHEME: string = 'category';

export class PreferencesHelper {
  private static instance: PreferencesHelper | null = null;
  private store: preferences.Preferences | null = null;

  static getInstance(): PreferencesHelper {
    if (PreferencesHelper.instance === null) {
      PreferencesHelper.instance = new PreferencesHelper();
    }
    return PreferencesHelper.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.store !== null) {
      return;
    }
    this.store = await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  private requireStore(): preferences.Preferences {
    if (this.store === null) {
      throw new Error('PreferencesHelper is not initialized. Call init(context) first.');
    }
    return this.store;
  }

  async getColorScheme(): Promise<string> {
    const store = this.requireStore();
    const value = await store.get(KEY_COLOR_SCHEME, DEFAULT_COLOR_SCHEME);
    return value as string;
  }

  async setColorScheme(scheme: string): Promise<void> {
    const store = this.requireStore();
    await store.put(KEY_COLOR_SCHEME, scheme);
    await store.flush();
  }
}

export const preferencesHelper: PreferencesHelper = PreferencesHelper.getInstance();
