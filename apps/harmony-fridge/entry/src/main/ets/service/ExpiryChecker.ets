import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { FoodItemDao } from '../database/FoodItemDao';
import { NotificationService } from './NotificationService';
import { Constants } from '../common/Constants';
import { FoodItem } from '../model/FoodItem';
import { DateUtils } from '../common/DateUtils';

export class ExpiryChecker {
  private static instance?: ExpiryChecker;
  private context?: common.UIAbilityContext;
  private foodItemDao: FoodItemDao = new FoodItemDao();

  private constructor() {
  }

  static getInstance(): ExpiryChecker {
    if (!ExpiryChecker.instance) {
      ExpiryChecker.instance = new ExpiryChecker();
    }
    return ExpiryChecker.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
  }

  async refreshAll(): Promise<void> {
    const items: FoodItem[] = await this.foodItemDao.getAll();
    let expiredCount: number = 0;
    let expiringSoonCount: number = 0;
    items.forEach((item: FoodItem) => {
      const remaining: number = DateUtils.daysUntil(item.expiryDate);
      if (remaining < 0) {
        expiredCount += 1;
      } else if (remaining <= Constants.WARNING_DAYS) {
        expiringSoonCount += 1;
      }
    });
    AppStorage.SetOrCreate(Constants.STORAGE_TOTAL, items.length);
    AppStorage.SetOrCreate(Constants.STORAGE_EXPIRED, expiredCount);
    AppStorage.SetOrCreate(Constants.STORAGE_EXPIRING, expiringSoonCount);
    await this.syncWidgetState(expiringSoonCount, expiredCount);
    await NotificationService.getInstance().publishExpiryNotification(expiredCount, expiringSoonCount);
  }

  private async syncWidgetState(expiringSoonCount: number, expiredCount: number): Promise<void> {
    if (!this.context) {
      return;
    }
    const pref: preferences.Preferences = preferences.getPreferencesSync(this.context, {
      name: Constants.PREFS_WIDGET
    });
    pref.putSync(Constants.PREFS_EXPIRING_COUNT, expiringSoonCount);
    pref.putSync(Constants.PREFS_EXPIRED_COUNT, expiredCount);
    pref.putSync(Constants.PREFS_UPDATED_AT, Date.now());
    pref.flushSync();
  }
}
