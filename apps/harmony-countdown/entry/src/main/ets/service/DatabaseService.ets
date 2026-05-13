import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { CountdownEvent } from '../model/CountdownEvent';

interface CountdownEventRow {
  id: number
  title: string
  target_date: string
  note: string
  icon: string
  color: string
  is_reminder_enabled: number
  reminder_hour: number
  reminder_minute: number
  is_repeat_yearly: number
  created_at: number
  updated_at: number
}

class DatabaseService {
  private static instance?: DatabaseService;
  private store?: relationalStore.RdbStore;

  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return;
    }
    let config: relationalStore.StoreConfig = {
      name: 'countdown.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.store.executeSql(
      'CREATE TABLE IF NOT EXISTS countdown_events (' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'title TEXT NOT NULL, ' +
      'target_date TEXT NOT NULL, ' +
      'note TEXT, ' +
      'icon TEXT NOT NULL, ' +
      'color TEXT NOT NULL, ' +
      'is_reminder_enabled INTEGER NOT NULL, ' +
      'reminder_hour INTEGER NOT NULL, ' +
      'reminder_minute INTEGER NOT NULL, ' +
      'is_repeat_yearly INTEGER NOT NULL, ' +
      'created_at INTEGER NOT NULL, ' +
      'updated_at INTEGER NOT NULL)'
    );
  }

  async listEvents(): Promise<CountdownEvent[]> {
    if (!this.store) {
      return [];
    }
    let resultSet = await this.store.querySql('SELECT * FROM countdown_events ORDER BY updated_at DESC');
    let events: CountdownEvent[] = [];
    while (resultSet.goToNextRow()) {
      let row: CountdownEventRow = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        target_date: resultSet.getString(resultSet.getColumnIndex('target_date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        is_reminder_enabled: resultSet.getLong(resultSet.getColumnIndex('is_reminder_enabled')),
        reminder_hour: resultSet.getLong(resultSet.getColumnIndex('reminder_hour')),
        reminder_minute: resultSet.getLong(resultSet.getColumnIndex('reminder_minute')),
        is_repeat_yearly: resultSet.getLong(resultSet.getColumnIndex('is_repeat_yearly')),
        created_at: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updated_at: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      };
      events.push(this.toEvent(row));
    }
    resultSet.close();
    return events;
  }

  async getEventById(id: number): Promise<CountdownEvent | null> {
    if (!this.store) {
      return null;
    }
    let resultSet = await this.store.querySql('SELECT * FROM countdown_events WHERE id = ?', [id]);
    let event: CountdownEvent | null = null;
    if (resultSet.goToNextRow()) {
      let row: CountdownEventRow = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        target_date: resultSet.getString(resultSet.getColumnIndex('target_date')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        is_reminder_enabled: resultSet.getLong(resultSet.getColumnIndex('is_reminder_enabled')),
        reminder_hour: resultSet.getLong(resultSet.getColumnIndex('reminder_hour')),
        reminder_minute: resultSet.getLong(resultSet.getColumnIndex('reminder_minute')),
        is_repeat_yearly: resultSet.getLong(resultSet.getColumnIndex('is_repeat_yearly')),
        created_at: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updated_at: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      };
      event = this.toEvent(row);
    }
    resultSet.close();
    return event;
  }

  async saveEvent(event: CountdownEvent): Promise<number> {
    if (!this.store) {
      return 0;
    }
    let bucket: relationalStore.ValuesBucket = {
      title: event.title,
      target_date: event.targetDate,
      note: event.note,
      icon: event.icon,
      color: event.color,
      is_reminder_enabled: event.isReminderEnabled ? 1 : 0,
      reminder_hour: event.reminderHour,
      reminder_minute: event.reminderMinute,
      is_repeat_yearly: event.isRepeatYearly ? 1 : 0,
      created_at: event.createdAt,
      updated_at: event.updatedAt
    };
    if (event.id > 0) {
      let predicates = new relationalStore.RdbPredicates('countdown_events');
      predicates.equalTo('id', event.id);
      await this.store.update(bucket, predicates);
      return event.id;
    }
    return await this.store.insert('countdown_events', bucket);
  }

  async deleteEvent(id: number): Promise<void> {
    if (!this.store) {
      return;
    }
    let predicates = new relationalStore.RdbPredicates('countdown_events');
    predicates.equalTo('id', id);
    await this.store.delete(predicates);
  }

  private toEvent(row: CountdownEventRow): CountdownEvent {
    return {
      id: row.id,
      title: row.title,
      targetDate: row.target_date,
      note: row.note || '',
      icon: row.icon,
      color: row.color,
      isReminderEnabled: row.is_reminder_enabled === 1,
      reminderHour: row.reminder_hour,
      reminderMinute: row.reminder_minute,
      isRepeatYearly: row.is_repeat_yearly === 1,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}

export default DatabaseService.getInstance();
