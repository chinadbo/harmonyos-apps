import common from '@ohos.app.ability.common';
import dataPreferences from '@ohos.data.preferences';
import hilog from '@ohos.hilog';
import { ThemeKey } from '../model/BookInfo';

const DOMAIN: number = 0x0000;
const TAG: string = 'PreferencesService';
const PREF_NAME: string = 'reader_preferences';

export default class PreferencesService {
  private static preferences: dataPreferences.Preferences | null = null;

  private static async getPreferences(context: common.UIAbilityContext): Promise<dataPreferences.Preferences> {
    if (this.preferences !== null) {
      return this.preferences;
    }
    this.preferences = await dataPreferences.getPreferences(context, PREF_NAME);
    return this.preferences;
  }

  static async initialize(context: common.UIAbilityContext): Promise<void> {
    const preferences = await this.getPreferences(context);
    const theme = await preferences.get('readerTheme', 'light') as string;
    const fontSize = await preferences.get('readerFontSize', 18) as number;
    AppStorage.setOrCreate('readerTheme', theme as ThemeKey);
    AppStorage.setOrCreate('readerFontSize', Number(fontSize));
    hilog.info(DOMAIN, TAG, 'Preferences initialized');
  }

  static async saveTheme(context: common.UIAbilityContext, theme: ThemeKey): Promise<void> {
    const preferences = await this.getPreferences(context);
    await preferences.put('readerTheme', theme);
    await preferences.flush();
    AppStorage.setOrCreate('readerTheme', theme);
  }

  static async saveFontSize(context: common.UIAbilityContext, fontSize: number): Promise<void> {
    const preferences = await this.getPreferences(context);
    await preferences.put('readerFontSize', fontSize);
    await preferences.flush();
    AppStorage.setOrCreate('readerFontSize', fontSize);
  }
}
