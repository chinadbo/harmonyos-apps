import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { dayDiff } from '../utils/DateUtil';

const PREF_NAME: string = 'harmonymath_prefs';

export class PreferencesUtil {
  private static instance: PreferencesUtil | null = null;
  private store: preferences.Preferences | null = null;
  private initTask: Promise<void> | null = null;

  static getInstance(): PreferencesUtil {
    if (PreferencesUtil.instance === null) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  async init(context: common.Context): Promise<void> {
    if (this.store !== null) {
      return Promise.resolve();
    }
    if (this.initTask !== null) {
      return this.initTask;
    }
    this.initTask = this.doInit(context);
    return this.initTask;
  }

  async ready(): Promise<void> {
    if (this.initTask !== null) {
      return this.initTask;
    }
    return Promise.resolve();
  }

  private async doInit(context: common.Context): Promise<void> {
    try {
      this.store = await preferences.getPreferences(context, PREF_NAME);
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[PreferencesUtil] init failed, code=${e.code}, msg=${e.message}`);
    }
  }

  private async getNumber(key: string, def: number): Promise<number> {
    if (this.store === null) {
      return def;
    }
    const v: preferences.ValueType = await this.store.get(key, def);
    if (typeof v === 'number') {
      return v;
    }
    return def;
  }

  private async getBool(key: string, def: boolean): Promise<boolean> {
    if (this.store === null) {
      return def;
    }
    const v: preferences.ValueType = await this.store.get(key, def);
    if (typeof v === 'boolean') {
      return v;
    }
    return def;
  }

  private async getString(key: string, def: string): Promise<string> {
    if (this.store === null) {
      return def;
    }
    const v: preferences.ValueType = await this.store.get(key, def);
    if (typeof v === 'string') {
      return v;
    }
    return def;
  }

  private async putValue(key: string, value: preferences.ValueType): Promise<void> {
    if (this.store === null) {
      return;
    }
    try {
      await this.store.put(key, value);
      await this.store.flush();
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`[PreferencesUtil] put ${key} failed, code=${e.code}`);
    }
  }

  async getStreakDays(): Promise<number> {
    return this.getNumber('streak_days', 0);
  }

  async setStreakDays(value: number): Promise<void> {
    await this.putValue('streak_days', value);
  }

  async getLastPracticeDate(): Promise<string> {
    return this.getString('last_practice_date', '');
  }

  async getSoundOn(): Promise<boolean> {
    return this.getBool('sound_on', true);
  }

  async setSoundOn(value: boolean): Promise<void> {
    await this.putValue('sound_on', value);
  }

  async getVibrateOn(): Promise<boolean> {
    return this.getBool('vibrate_on', true);
  }

  async setVibrateOn(value: boolean): Promise<void> {
    await this.putValue('vibrate_on', value);
  }

  async getDailyGoal(): Promise<number> {
    return this.getNumber('daily_goal', 20);
  }

  async setDailyGoal(value: number): Promise<void> {
    await this.putValue('daily_goal', value);
  }

  async updateStreak(today: string): Promise<number> {
    const last: string = await this.getLastPracticeDate();
    let streak: number = await this.getStreakDays();
    if (last === today) {
      return streak;
    }
    if (last !== '' && dayDiff(last, today) === 1) {
      streak += 1;
    } else {
      streak = 1;
    }
    await this.putValue('streak_days', streak);
    await this.putValue('last_practice_date', today);
    return streak;
  }
}
