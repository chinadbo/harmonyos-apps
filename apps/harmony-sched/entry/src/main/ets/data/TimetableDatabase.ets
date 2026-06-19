import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { Course } from './CourseModel';
import { ScheduleProfile } from './ScheduleModel';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmonysched.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

class TimetableDatabase {
  private store?: relationalStore.RdbStore;

  private createTables(rdbStore: relationalStore.RdbStore): Promise<void> {
    const scheduleSql = 'CREATE TABLE IF NOT EXISTS schedules (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, termName TEXT NOT NULL, startDate TEXT NOT NULL, weeks INTEGER NOT NULL, isActive INTEGER NOT NULL DEFAULT 0, createdAt INTEGER NOT NULL, updatedAt INTEGER NOT NULL)';
    const courseSql = 'CREATE TABLE IF NOT EXISTS courses (id INTEGER PRIMARY KEY AUTOINCREMENT, scheduleId INTEGER NOT NULL, name TEXT NOT NULL, teacher TEXT NOT NULL, location TEXT NOT NULL, dayOfWeek INTEGER NOT NULL, startSection INTEGER NOT NULL, duration INTEGER NOT NULL, startWeek INTEGER NOT NULL, endWeek INTEGER NOT NULL, weekType INTEGER NOT NULL DEFAULT 0, color TEXT NOT NULL, reminderEnabled INTEGER NOT NULL DEFAULT 0, reminderMinutes INTEGER NOT NULL DEFAULT 15, reminderId INTEGER NOT NULL DEFAULT 0, note TEXT NOT NULL DEFAULT \'\', createdAt INTEGER NOT NULL, updatedAt INTEGER NOT NULL)';
    return rdbStore.executeSql(scheduleSql)
      .then(() => rdbStore.executeSql(courseSql))
      .then(() => undefined);
  }

  init(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return Promise.resolve(this.store);
    }
    return relationalStore.getRdbStore(context, STORE_CONFIG)
      .then((rdbStore: relationalStore.RdbStore) => {
        this.store = rdbStore;
        return this.createTables(rdbStore).then(() => rdbStore);
      });
  }

  getStore(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return Promise.resolve(this.store);
    }
    return this.init(context);
  }

  resultSetToSchedules(resultSet: relationalStore.ResultSet): ScheduleProfile[] {
    const items: ScheduleProfile[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        items.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          termName: resultSet.getString(resultSet.getColumnIndex('termName')),
          startDate: resultSet.getString(resultSet.getColumnIndex('startDate')),
          weeks: resultSet.getLong(resultSet.getColumnIndex('weeks')),
          isActive: resultSet.getLong(resultSet.getColumnIndex('isActive')) === 1,
          createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
          updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return items;
  }

  resultSetToCourses(resultSet: relationalStore.ResultSet): Course[] {
    const items: Course[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        items.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          scheduleId: resultSet.getLong(resultSet.getColumnIndex('scheduleId')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          teacher: resultSet.getString(resultSet.getColumnIndex('teacher')),
          location: resultSet.getString(resultSet.getColumnIndex('location')),
          dayOfWeek: resultSet.getLong(resultSet.getColumnIndex('dayOfWeek')),
          startSection: resultSet.getLong(resultSet.getColumnIndex('startSection')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          startWeek: resultSet.getLong(resultSet.getColumnIndex('startWeek')),
          endWeek: resultSet.getLong(resultSet.getColumnIndex('endWeek')),
          weekType: resultSet.getLong(resultSet.getColumnIndex('weekType')),
          color: resultSet.getString(resultSet.getColumnIndex('color')),
          reminderEnabled: resultSet.getLong(resultSet.getColumnIndex('reminderEnabled')) === 1,
          reminderMinutes: resultSet.getLong(resultSet.getColumnIndex('reminderMinutes')),
          reminderId: resultSet.getLong(resultSet.getColumnIndex('reminderId')),
          note: resultSet.getString(resultSet.getColumnIndex('note')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
          updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return items;
  }
}

export const timetableDatabase: TimetableDatabase = new TimetableDatabase();
