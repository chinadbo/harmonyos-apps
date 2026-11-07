/**
 * Preferences 封装：theme_mode / alert_enabled / seeded 标记
 * 读取后写入 AppStorage，配合 @StorageLink 全局同步
 */

import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

const PREF_NAME: string = 'harmony_quotes_prefs'

export class Prefs {
  private static store: preferences.Preferences | null = null
  private static loadFailed: boolean = false

  static async load(context: common.Context): Promise<void> {
    try {
      Prefs.store = await preferences.getPreferences(context, PREF_NAME)
      const theme = Prefs.store.getSync('theme_mode', 'red_up') as string
      AppStorage.setOrCreate('themeMode', theme)
      const alert = Prefs.store.getSync('alert_enabled', true) as boolean
      AppStorage.setOrCreate('alertEnabled', alert)
    } catch (e) {
      Prefs.loadFailed = true
      AppStorage.setOrCreate('themeMode', 'red_up')
      AppStorage.setOrCreate('alertEnabled', true)
    }
  }

  static isLoadFailed(): boolean {
    return Prefs.loadFailed
  }

  static getBool(key: string, def: boolean): boolean {
    try {
      if (Prefs.store) {
        return Prefs.store.getSync(key, def) as boolean
      }
    } catch (e) {
    }
    return def
  }

  static setBool(key: string, value: boolean): void {
    try {
      if (Prefs.store) {
        Prefs.store.putSync(key, value)
        Prefs.store.flush()
      }
    } catch (e) {
    }
  }

  static setThemeMode(mode: string): void {
    AppStorage.setOrCreate('themeMode', mode)
    try {
      if (Prefs.store) {
        Prefs.store.putSync('theme_mode', mode)
        Prefs.store.flush()
      }
    } catch (e) {
    }
  }

  static setAlertEnabled(value: boolean): void {
    AppStorage.setOrCreate('alertEnabled', value)
    Prefs.setBool('alert_enabled', value)
  }
}
