import * as relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { EventModel, RepeatType } from '../models/EventModel';
import { TagModel } from '../models/TagModel';
import { DEFAULT_TAGS } from '../utils/Constants';
import { addDays, addMonths, createDateKey, endOfDay, filterEventsForRange, getStartOfWeek, startOfDay } from '../utils/DateUtils';

// 数据库管理单例，负责所有日程与标签持久化操作
export class StorageManager {
  private static instance: StorageManager = new StorageManager();
  private rdbStore?: relationalStore.RdbStore;
  private initialized: boolean = false;

  static getInstance(): StorageManager {
    return StorageManager.instance;
  }

  async initialize(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized && this.rdbStore) {
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmonyschedule.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.rdbStore = await relationalStore.getRdbStore(context, config);
    await this.rdbStore.executeSql('CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, start_time INTEGER, end_time INTEGER, is_all_day INTEGER, location TEXT, tag_id INTEGER, reminder_times TEXT, repeat_type TEXT, repeat_end INTEGER, color TEXT, created_at INTEGER, updated_at INTEGER)');
    await this.rdbStore.executeSql('CREATE TABLE IF NOT EXISTS tags (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, color TEXT NOT NULL, sort_order INTEGER DEFAULT 0)');
    await this.seedDefaultTags();
    this.initialized = true;
  }

  async getEventsForMonth(month: Date): Promise<EventModel[]> {
    await this.ensureReady();
    const rangeStart: Date = new Date(month.getFullYear(), month.getMonth(), 1, 0, 0, 0, 0);
    const rangeEnd: Date = new Date(month.getFullYear(), month.getMonth() + 1, 0, 23, 59, 59, 999);
    return this.queryEventsInRange(rangeStart.getTime(), rangeEnd.getTime());
  }

  async getEventsForDay(date: Date): Promise<EventModel[]> {
    await this.ensureReady();
    return this.queryEventsInRange(startOfDay(date).getTime(), endOfDay(date).getTime());
  }

  async getEventsForWeek(date: Date): Promise<EventModel[]> {
    await this.ensureReady();
    const start: Date = getStartOfWeek(date);
    const end: Date = endOfDay(addDays(start, 6));
    return this.queryEventsInRange(start.getTime(), end.getTime());
  }

  async getAllEvents(): Promise<EventModel[]> {
    await this.ensureReady();
    const resultSet: relationalStore.ResultSet = await this.rdbStore!.querySql('SELECT * FROM events ORDER BY start_time ASC');
    return this.readEvents(resultSet);
  }

  async getEventById(eventId: number): Promise<EventModel | null> {
    await this.ensureReady();
    const resultSet: relationalStore.ResultSet = await this.rdbStore!.querySql('SELECT * FROM events WHERE id = ?', [eventId]);
    const events: EventModel[] = this.readEvents(resultSet);
    return events.length > 0 ? events[0] : null;
  }

  async saveEvent(event: EventModel): Promise<number> {
    await this.ensureReady();
    const now: number = Date.now();
    const valueBucket: relationalStore.ValuesBucket = {
      title: event.title,
      description: event.description,
      start_time: event.startTime,
      end_time: event.endTime,
      is_all_day: event.isAllDay ? 1 : 0,
      location: event.location,
      tag_id: event.tagId,
      reminder_times: JSON.stringify(event.reminderTimes),
      repeat_type: event.repeatType,
      repeat_end: event.repeatEnd,
      color: event.color,
      created_at: event.id > 0 ? event.createdAt : now,
      updated_at: now
    };
    if (event.id > 0) {
      await this.rdbStore!.update(valueBucket, new relationalStore.RdbPredicates('events').equalTo('id', event.id));
      return event.id;
    }
    const insertedId: number = await this.rdbStore!.insert('events', valueBucket);
    return insertedId;
  }

  async deleteEvent(eventId: number): Promise<void> {
    await this.ensureReady();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('events');
    predicates.equalTo('id', eventId);
    await this.rdbStore!.delete(predicates);
  }

  async getAllTags(): Promise<TagModel[]> {
    await this.ensureReady();
    const resultSet: relationalStore.ResultSet = await this.rdbStore!.querySql('SELECT * FROM tags ORDER BY sort_order ASC, id ASC');
    return this.readTags(resultSet);
  }

  async saveTag(tag: TagModel): Promise<number> {
    await this.ensureReady();
    const valueBucket: relationalStore.ValuesBucket = {
      name: tag.name,
      color: tag.color,
      sort_order: tag.sortOrder
    };
    if (tag.id > 0) {
      await this.rdbStore!.update(valueBucket, new relationalStore.RdbPredicates('tags').equalTo('id', tag.id));
      return tag.id;
    }
    return this.rdbStore!.insert('tags', valueBucket);
  }

  async deleteTag(tagId: number): Promise<void> {
    await this.ensureReady();
    const fallbackTag: TagModel | undefined = (await this.getAllTags()).find((tag: TagModel) => tag.name === '其他');
    if (fallbackTag) {
      const updateBucket: relationalStore.ValuesBucket = { tag_id: fallbackTag.id };
      await this.rdbStore!.update(updateBucket, new relationalStore.RdbPredicates('events').equalTo('tag_id', tagId));
    }
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('tags');
    predicates.equalTo('id', tagId);
    await this.rdbStore!.delete(predicates);
  }

  async exportToJson(): Promise<string> {
    const payload: object = {
      exportedAt: Date.now(),
      tags: await this.getAllTags(),
      events: await this.getAllEvents()
    };
    return JSON.stringify(payload, null, 2);
  }

  async importFromJson(jsonText: string): Promise<void> {
    await this.ensureReady();
    const payload: Record<string, object> = JSON.parse(jsonText) as Record<string, object>;
    await this.rdbStore!.executeSql('DELETE FROM events');
    await this.rdbStore!.executeSql('DELETE FROM tags');
    const tags: TagModel[] = (payload.tags as TagModel[]) ?? [];
    const events: EventModel[] = (payload.events as EventModel[]) ?? [];
    for (const tag of tags) {
      await this.saveTag({
        id: 0,
        name: tag.name,
        color: tag.color,
        sortOrder: tag.sortOrder,
        isPreset: tag.isPreset
      });
    }
    for (const event of events) {
      await this.saveEvent({
        ...event,
        id: 0,
        createdAt: event.createdAt ?? Date.now(),
        updatedAt: event.updatedAt ?? Date.now(),
        repeatType: (event.repeatType ?? 'NONE') as RepeatType,
        reminderTimes: event.reminderTimes ?? []
      });
    }
    await this.seedDefaultTags();
  }

  async getEventCountMapForMonth(month: Date): Promise<Map<string, number>> {
    const events: EventModel[] = await this.getEventsForMonth(month);
    const result: Map<string, number> = new Map<string, number>();
    events.forEach((event: EventModel) => {
      const key: string = createDateKey(new Date(event.startTime));
      const currentCount: number = result.get(key) ?? 0;
      result.set(key, currentCount + 1);
    });
    return result;
  }

  async getExpandedEventsForRange(start: Date, end: Date): Promise<EventModel[]> {
    const events: EventModel[] = await this.getAllEvents();
    return filterEventsForRange(this.expandRepeatingEvents(events, start, end), start, end);
  }

  private async ensureReady(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('StorageManager has not been initialized.');
    }
  }

  private async seedDefaultTags(): Promise<void> {
    const existingTags: TagModel[] = await this.getAllTagsInternal();
    if (existingTags.length > 0) {
      const existingNames: Set<string> = new Set(existingTags.map((tag: TagModel) => tag.name));
      for (const tag of DEFAULT_TAGS) {
        if (!existingNames.has(tag.name)) {
          await this.saveTag({ ...tag, id: 0 });
        }
      }
      return;
    }
    for (const tag of DEFAULT_TAGS) {
      await this.saveTag({ ...tag, id: 0 });
    }
  }

  private async getAllTagsInternal(): Promise<TagModel[]> {
    if (!this.rdbStore) {
      return [];
    }
    const resultSet: relationalStore.ResultSet = await this.rdbStore.querySql('SELECT * FROM tags ORDER BY sort_order ASC, id ASC');
    return this.readTags(resultSet);
  }

  private async queryEventsInRange(startTime: number, endTime: number): Promise<EventModel[]> {
    const resultSet: relationalStore.ResultSet = await this.rdbStore!.querySql(
      'SELECT * FROM events WHERE start_time <= ? AND end_time >= ? ORDER BY start_time ASC',
      [endTime, startTime]
    );
    const events: EventModel[] = this.readEvents(resultSet);
    return this.expandRepeatingEvents(events, new Date(startTime), new Date(endTime));
  }

  private expandRepeatingEvents(events: EventModel[], rangeStart: Date, rangeEnd: Date): EventModel[] {
    const expanded: EventModel[] = [];
    events.forEach((event: EventModel) => {
      if (event.repeatType === 'NONE') {
        expanded.push(event);
        return;
      }
      let currentStart: Date = new Date(event.startTime);
      let currentEnd: Date = new Date(event.endTime);
      const limitEnd: number = event.repeatEnd > 0 ? Math.min(event.repeatEnd, rangeEnd.getTime()) : rangeEnd.getTime();
      while (currentStart.getTime() <= limitEnd) {
        if (currentEnd.getTime() >= rangeStart.getTime() && currentStart.getTime() <= rangeEnd.getTime()) {
          expanded.push({
            ...event,
            startTime: currentStart.getTime(),
            endTime: currentEnd.getTime()
          });
        }
        if (event.repeatType === 'DAILY') {
          currentStart = addDays(currentStart, 1);
          currentEnd = addDays(currentEnd, 1);
        } else if (event.repeatType === 'WEEKLY') {
          currentStart = addDays(currentStart, 7);
          currentEnd = addDays(currentEnd, 7);
        } else {
          currentStart = addMonths(currentStart, 1);
          currentEnd = addMonths(currentEnd, 1);
        }
      }
    });
    return expanded.sort((first: EventModel, second: EventModel) => first.startTime - second.startTime);
  }

  private readEvents(resultSet: relationalStore.ResultSet): EventModel[] {
    const events: EventModel[] = [];
    if (resultSet.rowCount === 0) {
      resultSet.close();
      return events;
    }
    resultSet.goToFirstRow();
    do {
      events.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        description: this.safeGetString(resultSet, 'description'),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
        isAllDay: resultSet.getLong(resultSet.getColumnIndex('is_all_day')) === 1,
        location: this.safeGetString(resultSet, 'location'),
        tagId: resultSet.getLong(resultSet.getColumnIndex('tag_id')),
        reminderTimes: this.parseReminderTimes(this.safeGetString(resultSet, 'reminder_times')),
        repeatType: (this.safeGetString(resultSet, 'repeat_type') as RepeatType) || 'NONE',
        repeatEnd: resultSet.getLong(resultSet.getColumnIndex('repeat_end')),
        color: this.safeGetString(resultSet, 'color') || '#4A90D9',
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      });
    } while (resultSet.goToNextRow());
    resultSet.close();
    return events;
  }

  private readTags(resultSet: relationalStore.ResultSet): TagModel[] {
    const tags: TagModel[] = [];
    if (resultSet.rowCount === 0) {
      resultSet.close();
      return tags;
    }
    resultSet.goToFirstRow();
    do {
      tags.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        isPreset: DEFAULT_TAGS.some((presetTag: TagModel) => presetTag.name === resultSet.getString(resultSet.getColumnIndex('name')))
      });
    } while (resultSet.goToNextRow());
    resultSet.close();
    return tags;
  }

  private parseReminderTimes(jsonText: string): number[] {
    if (!jsonText) {
      return [];
    }
    try {
      const parsedValue: number[] = JSON.parse(jsonText) as number[];
      return Array.isArray(parsedValue) ? parsedValue : [];
    } catch (error) {
      console.error(`Failed to parse reminder times: ${JSON.stringify(error)}`);
      return [];
    }
  }

  private safeGetString(resultSet: relationalStore.ResultSet, columnName: string): string {
    const columnIndex: number = resultSet.getColumnIndex(columnName);
    if (columnIndex < 0) {
      return '';
    }
    return resultSet.getString(columnIndex) ?? '';
  }
}

export default StorageManager.getInstance();
