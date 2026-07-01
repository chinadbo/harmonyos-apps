import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { DEFAULT_BPM, PREFERENCES_NAME, THEME_KEY } from '../constants/AppConstants';
import type { MetronomeSettings } from '../constants/AppTypes';

export class PreferencesService {
  private static instance: PreferencesService = new PreferencesService();
  private pref: preferences.Preferences | null = null;

  private constructor() {
  }

  static getInstance(): PreferencesService {
    return PreferencesService.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.pref !== null) {
      return;
    }
    this.pref = await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  private ensureDefault(): MetronomeSettings {
    return {
      bpm: DEFAULT_BPM,
      timeSignature: '4/4',
      soundType: 'classic',
      isDarkMode: true
    };
  }

  async getSettings(): Promise<MetronomeSettings> {
    if (this.pref === null) {
      return this.ensureDefault();
    }
    return {
      bpm: Number(await this.pref.get('bpm', DEFAULT_BPM)),
      timeSignature: String(await this.pref.get('timeSignature', '4/4')),
      soundType: String(await this.pref.get('soundType', 'classic')),
      isDarkMode: Boolean(await this.pref.get(THEME_KEY, true))
    };
  }

  async setBpm(bpm: number): Promise<void> {
    if (this.pref === null) {
      return;
    }
    await this.pref.put('bpm', bpm);
    await this.pref.flush();
  }

  async setTimeSignature(value: string): Promise<void> {
    if (this.pref === null) {
      return;
    }
    await this.pref.put('timeSignature', value);
    await this.pref.flush();
  }

  async setSoundType(value: string): Promise<void> {
    if (this.pref === null) {
      return;
    }
    await this.pref.put('soundType', value);
    await this.pref.flush();
  }

  async setDarkMode(value: boolean): Promise<void> {
    if (this.pref === null) {
      return;
    }
    await this.pref.put(THEME_KEY, value);
    await this.pref.flush();
  }
}

export const preferencesService: PreferencesService = PreferencesService.getInstance();
