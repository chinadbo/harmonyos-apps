import relationalStore from '@ohos.data.relationalStore';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { Favorite } from '../model/Favorite';

const DB_NAME: string = 'harmonysolar.db';
const TABLE_FAVORITES: string = 'favorites';
const SQL_CREATE_FAVORITES: string =
  'CREATE TABLE IF NOT EXISTS favorites (term_id TEXT PRIMARY KEY, saved_at INTEGER NOT NULL)';
const PREF_NAME: string = 'harmonysolar_settings';
const KEY_REMIND: string = 'remind_enabled';
const KEY_ADVANCE: string = 'remind_advance_days';

export class DbHelper {
  private static store: relationalStore.RdbStore | null = null;
  private static initTask: Promise<relationalStore.RdbStore> | null = null;

  private static getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (DbHelper.store !== null) {
      return Promise.resolve(DbHelper.store);
    }
    if (DbHelper.initTask !== null) {
      return DbHelper.initTask;
    }
    const task: Promise<relationalStore.RdbStore> = DbHelper.openStore(context);
    DbHelper.initTask = task;
    return task;
  }

  private static async openStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config);
      await store.executeSql(SQL_CREATE_FAVORITES);
      DbHelper.store = store;
      return store;
    } finally {
      DbHelper.initTask = null;
    }
  }

  static async addFavorite(context: common.UIAbilityContext, termId: string): Promise<void> {
    const store: relationalStore.RdbStore = await DbHelper.getStore(context);
    const values: relationalStore.ValuesBucket = {
      'term_id': termId,
      'saved_at': Date.now()
    };
    await store.insert(TABLE_FAVORITES, values, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
  }

  static async removeFavorite(context: common.UIAbilityContext, termId: string): Promise<void> {
    const store: relationalStore.RdbStore = await DbHelper.getStore(context);
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_FAVORITES);
    predicates.equalTo('term_id', termId);
    await store.delete(predicates);
  }

  static async isFavorite(context: common.UIAbilityContext, termId: string): Promise<boolean> {
    const store: relationalStore.RdbStore = await DbHelper.getStore(context);
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_FAVORITES);
    predicates.equalTo('term_id', termId);
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['term_id']);
    const exists: boolean = resultSet.goToFirstRow();
    resultSet.close();
    return exists;
  }

  static async toggleFavorite(context: common.UIAbilityContext, termId: string): Promise<boolean> {
    const exists: boolean = await DbHelper.isFavorite(context, termId);
    if (exists) {
      await DbHelper.removeFavorite(context, termId);
      return false;
    }
    await DbHelper.addFavorite(context, termId);
    return true;
  }

  static async getFavorites(context: common.UIAbilityContext): Promise<Favorite[]> {
    const store: relationalStore.RdbStore = await DbHelper.getStore(context);
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_FAVORITES);
    predicates.orderByDesc('saved_at');
    const resultSet: relationalStore.ResultSet = await store.query(predicates, ['term_id', 'saved_at']);
    const list: Favorite[] = [];
    while (resultSet.goToNextRow()) {
      const item: Favorite = {
        termId: resultSet.getString(resultSet.getColumnIndex('term_id')),
        savedAt: resultSet.getLong(resultSet.getColumnIndex('saved_at'))
      };
      list.push(item);
    }
    resultSet.close();
    return list;
  }
}

export class ReminderPrefs {
  private static store: preferences.Preferences | null = null;

  private static async getStore(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    if (ReminderPrefs.store !== null) {
      return ReminderPrefs.store;
    }
    const store: preferences.Preferences = await preferences.getPreferences(context, PREF_NAME);
    ReminderPrefs.store = store;
    return store;
  }

  static async isEnabled(context: common.UIAbilityContext): Promise<boolean> {
    const store: preferences.Preferences = await ReminderPrefs.getStore(context);
    const value: preferences.ValueType = await store.get(KEY_REMIND, false);
    return value as boolean;
  }

  static async setEnabled(context: common.UIAbilityContext, enabled: boolean): Promise<void> {
    const store: preferences.Preferences = await ReminderPrefs.getStore(context);
    await store.put(KEY_REMIND, enabled);
    await store.flush();
  }

  static async getAdvanceDays(context: common.UIAbilityContext): Promise<number> {
    const store: preferences.Preferences = await ReminderPrefs.getStore(context);
    const value: preferences.ValueType = await store.get(KEY_ADVANCE, 0);
    return value as number;
  }

  static async setAdvanceDays(context: common.UIAbilityContext, days: number): Promise<void> {
    const store: preferences.Preferences = await ReminderPrefs.getStore(context);
    await store.put(KEY_ADVANCE, days);
    await store.flush();
  }
}
