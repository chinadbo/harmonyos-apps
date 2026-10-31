import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { BabyProfile, BabyGender } from '../model/Models';

const DOMAIN: number = 0x0102;
const TAG: string = 'BabyProfileStore';
const PREF_NAME: string = 'baby_profile';

const KEY_NAME: string = 'name';
const KEY_BIRTHDAY: string = 'birthday';
const KEY_GENDER: string = 'gender';

/**
 * 宝宝档案存储（Preferences）：name / birthday(毫秒) / gender
 * 档案同时同步到 AppStorage，供各页面 @StorageProp 读取。
 */
export class BabyProfileStore {
  private static instance: BabyProfileStore | null = null;
  private prefs: preferences.Preferences | null = null;
  private initTask: Promise<void> | null = null;

  private constructor() {
  }

  static getInstance(): BabyProfileStore {
    if (BabyProfileStore.instance === null) {
      BabyProfileStore.instance = new BabyProfileStore();
    }
    return BabyProfileStore.instance;
  }

  init(context: common.UIAbilityContext): void {
    if (this.initTask !== null) {
      return;
    }
    this.initTask = preferences.getPreferences(context, { name: PREF_NAME })
      .then((p: preferences.Preferences) => {
        this.prefs = p;
        hilog.info(DOMAIN, TAG, 'preferences ready');
      })
      .catch((e: Object) => {
        hilog.error(DOMAIN, TAG, 'preferences init failed: %{public}s', JSON.stringify(e));
      });
  }

  private async ready(): Promise<preferences.Preferences> {
    if (this.initTask !== null) {
      await this.initTask;
    }
    if (this.prefs === null) {
      throw new Error('preferences is unavailable');
    }
    return this.prefs;
  }

  async getProfile(): Promise<BabyProfile> {
    const prefs = await this.ready();
    const p = new BabyProfile();
    const name = await prefs.get(KEY_NAME, '') as string;
    const birthday = await prefs.get(KEY_BIRTHDAY, 0) as number;
    const gender = await prefs.get(KEY_GENDER, BabyGender.Boy) as string;
    p.name = name;
    p.birthday = birthday;
    p.gender = gender;
    return p;
  }

  async saveProfile(profile: BabyProfile): Promise<void> {
    const prefs = await this.ready();
    await prefs.put(KEY_NAME, profile.name);
    await prefs.put(KEY_BIRTHDAY, profile.birthday);
    await prefs.put(KEY_GENDER, profile.gender);
    await prefs.flush();
  }

  /** 同步档案到 AppStorage（供 @StorageProp 读取） */
  static syncToAppStorage(profile: BabyProfile): void {
    AppStorage.setOrCreate('babyName', profile.name);
    AppStorage.setOrCreate('babyBirthday', profile.birthday);
    AppStorage.setOrCreate('babyGender', profile.gender);
  }

  /** 首次启动未设置档案时，AppStorage 需要有初始键 */
  static ensureAppStorageKeys(): void {
    AppStorage.setOrCreate('babyName', '');
    AppStorage.setOrCreate('babyBirthday', 0);
    AppStorage.setOrCreate('babyGender', BabyGender.Boy);
  }

  /** 版本号：任何表新增/删除记录时 +1，各页面 @StorageLink @Watch 自动刷新 */
  static ensureDataVersionKey(): void {
    AppStorage.setOrCreate('dataVersion', 0);
  }
}
