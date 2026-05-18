import relationalStore from '@ohos.data.relationalStore';
import type common from '@ohos.app.ability.common';
import type { BusinessError } from '@ohos.base';
import type { PackageRecord } from '../model/PackageModel';
import type { TrackingEvent } from '../model/TrackingEventModel';
import { DATABASE_NAME, PACKAGE_TABLE, TRACKING_EVENT_TABLE } from '../utils/Constants';

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService();
  private store: relationalStore.RdbStore | null = null;

  static getInstance(): DatabaseService {
    return DatabaseService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store !== null) {
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await new Promise<relationalStore.RdbStore>((resolve, reject) => {
      relationalStore.getRdbStore(context, config, 1, (err: BusinessError, store: relationalStore.RdbStore) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(store);
      });
    });
    await this.executeSql(`CREATE TABLE IF NOT EXISTS ${PACKAGE_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tracking_no TEXT NOT NULL UNIQUE,
      courier_code TEXT NOT NULL,
      courier_name TEXT NOT NULL,
      remark TEXT,
      status INTEGER NOT NULL,
      last_update TEXT NOT NULL,
      latest_desc TEXT NOT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )`);
    await this.executeSql(`CREATE TABLE IF NOT EXISTS ${TRACKING_EVENT_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      package_id INTEGER NOT NULL,
      time TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      event_type TEXT NOT NULL
    )`);
  }

  async saveOrUpdatePackage(record: PackageRecord, events: TrackingEvent[]): Promise<number> {
    const existing: PackageRecord | null = await this.findPackageByTrackingNo(record.trackingNo);
    if (existing?.id) {
      await this.updatePackage(existing.id, record);
      await this.replaceEvents(existing.id, events);
      return existing.id;
    }
    const packageId: number = await this.insert(PACKAGE_TABLE, {
      tracking_no: record.trackingNo,
      courier_code: record.courierCode,
      courier_name: record.courierName,
      remark: record.remark,
      status: record.status,
      last_update: record.lastUpdate,
      latest_desc: record.latestDesc,
      is_archived: record.isArchived ? 1 : 0,
      created_at: record.createdAt
    });
    await this.replaceEvents(packageId, events);
    return packageId;
  }

  async refreshPackage(packageId: number, record: PackageRecord, events: TrackingEvent[]): Promise<void> {
    await this.updatePackage(packageId, record);
    await this.replaceEvents(packageId, events);
  }

  async archivePackage(packageId: number): Promise<void> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('id', packageId);
    await this.update(predicates, { is_archived: 1 });
  }

  async getActivePackages(): Promise<PackageRecord[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('is_archived', 0);
    predicates.orderByDesc('last_update');
    return this.queryPackages(predicates);
  }

  async getArchivedPackages(): Promise<PackageRecord[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('is_archived', 1);
    predicates.orderByDesc('last_update');
    return this.queryPackages(predicates);
  }

  async findPackageByTrackingNo(trackingNo: string): Promise<PackageRecord | null> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('tracking_no', trackingNo);
    const list: PackageRecord[] = await this.queryPackages(predicates);
    return list.length > 0 ? list[0] : null;
  }

  async getPackageById(packageId: number): Promise<PackageRecord | null> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('id', packageId);
    const list: PackageRecord[] = await this.queryPackages(predicates);
    return list.length > 0 ? list[0] : null;
  }

  async getEventsByPackageId(packageId: number): Promise<TrackingEvent[]> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TRACKING_EVENT_TABLE);
    predicates.equalTo('package_id', packageId);
    predicates.orderByDesc('time');
    const resultSet: relationalStore.ResultSet = await this.query(predicates, ['id', 'package_id', 'time', 'location', 'description', 'event_type']);
    const result: TrackingEvent[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        result.push({
          id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
          packageId: Number(resultSet.getLong(resultSet.getColumnIndex('package_id'))),
          time: resultSet.getString(resultSet.getColumnIndex('time')),
          location: resultSet.getString(resultSet.getColumnIndex('location')),
          description: resultSet.getString(resultSet.getColumnIndex('description')),
          eventType: resultSet.getString(resultSet.getColumnIndex('event_type'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return result;
  }

  private async updatePackage(packageId: number, record: PackageRecord): Promise<void> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(PACKAGE_TABLE);
    predicates.equalTo('id', packageId);
    await this.update(predicates, {
      tracking_no: record.trackingNo,
      courier_code: record.courierCode,
      courier_name: record.courierName,
      remark: record.remark,
      status: record.status,
      last_update: record.lastUpdate,
      latest_desc: record.latestDesc,
      is_archived: record.isArchived ? 1 : 0
    });
  }

  private async replaceEvents(packageId: number, events: TrackingEvent[]): Promise<void> {
    const deletePredicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TRACKING_EVENT_TABLE);
    deletePredicates.equalTo('package_id', packageId);
    await this.delete(deletePredicates);
    for (const event of events) {
      await this.insert(TRACKING_EVENT_TABLE, {
        package_id: packageId,
        time: event.time,
        location: event.location,
        description: event.description,
        event_type: event.eventType
      });
    }
  }

  private async queryPackages(predicates: relationalStore.RdbPredicates): Promise<PackageRecord[]> {
    const resultSet: relationalStore.ResultSet = await this.query(predicates, [
      'id',
      'tracking_no',
      'courier_code',
      'courier_name',
      'remark',
      'status',
      'last_update',
      'latest_desc',
      'is_archived',
      'created_at'
    ]);
    const result: PackageRecord[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        result.push({
          id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
          trackingNo: resultSet.getString(resultSet.getColumnIndex('tracking_no')),
          courierCode: resultSet.getString(resultSet.getColumnIndex('courier_code')),
          courierName: resultSet.getString(resultSet.getColumnIndex('courier_name')),
          remark: resultSet.getString(resultSet.getColumnIndex('remark')),
          status: Number(resultSet.getLong(resultSet.getColumnIndex('status'))),
          lastUpdate: resultSet.getString(resultSet.getColumnIndex('last_update')),
          latestDesc: resultSet.getString(resultSet.getColumnIndex('latest_desc')),
          isArchived: Number(resultSet.getLong(resultSet.getColumnIndex('is_archived'))) === 1,
          createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return result;
  }

  private async executeSql(sql: string, bindArgs: relationalStore.ValueType[] = []): Promise<void> {
    const store: relationalStore.RdbStore = this.getStore();
    await new Promise<void>((resolve, reject) => {
      store.executeSql(sql, bindArgs, (err: BusinessError) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });
  }

  private async insert(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    const store: relationalStore.RdbStore = this.getStore();
    return await new Promise<number>((resolve, reject) => {
      store.insert(table, values, (err: BusinessError, rowId: number) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(Number(rowId));
      });
    });
  }

  private async update(predicates: relationalStore.RdbPredicates, values: relationalStore.ValuesBucket): Promise<void> {
    const store: relationalStore.RdbStore = this.getStore();
    await new Promise<void>((resolve, reject) => {
      store.update(values, predicates, (err: BusinessError) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });
  }

  private async delete(predicates: relationalStore.RdbPredicates): Promise<void> {
    const store: relationalStore.RdbStore = this.getStore();
    await new Promise<void>((resolve, reject) => {
      store.delete(predicates, (err: BusinessError) => {
        if (err) {
          reject(err);
          return;
        }
        resolve();
      });
    });
  }

  private async query(predicates: relationalStore.RdbPredicates, columns: string[]): Promise<relationalStore.ResultSet> {
    const store: relationalStore.RdbStore = this.getStore();
    return await new Promise<relationalStore.ResultSet>((resolve, reject) => {
      store.query(predicates, columns, (err: BusinessError, resultSet: relationalStore.ResultSet) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(resultSet);
      });
    });
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('DatabaseService has not been initialized');
    }
    return this.store;
  }
}
