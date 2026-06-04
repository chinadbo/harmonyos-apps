import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { createDemoVehicles, Vehicle } from '../models/Vehicle';
import { createDemoRecords, MaintenanceRecord } from '../models/MaintenanceRecord';
import { createDemoReminders, ReminderItem } from '../models/Reminder';
import { DB_NAME, REMINDER_TABLE, RECORD_TABLE, VEHICLE_TABLE } from '../utils/Constants';
import { parseBooleanNumber, parseStringArray, stringifyStringArray } from '../utils/Formatters';

class DatabaseService {
  private context?: common.UIAbilityContext;
  private store?: relationalStore.RdbStore;
  private initialized: boolean = false;

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized && this.store) {
      return;
    }
    this.context = context;
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables(this.store);
    await this.seedIfNeeded();
    this.initialized = true;
  }

  private async createTables(store: relationalStore.RdbStore): Promise<void> {
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${VEHICLE_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plateNumber TEXT NOT NULL,
      brand TEXT NOT NULL,
      model TEXT NOT NULL,
      purchaseDate TEXT,
      mileage INTEGER,
      vin TEXT,
      insuranceExpiry TEXT,
      inspectionExpiry TEXT,
      color TEXT,
      isDefault INTEGER,
      createdAt TEXT
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${RECORD_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicleId INTEGER NOT NULL,
      type TEXT NOT NULL,
      date TEXT,
      mileage INTEGER,
      cost INTEGER,
      shop TEXT,
      note TEXT,
      nextDate TEXT,
      nextMileage INTEGER,
      photos TEXT,
      createdAt TEXT
    )`);
    await store.executeSql(`CREATE TABLE IF NOT EXISTS ${REMINDER_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicleId INTEGER NOT NULL,
      reminderId INTEGER,
      type TEXT NOT NULL,
      title TEXT,
      content TEXT,
      triggerDate TEXT,
      targetMileage INTEGER,
      isActive INTEGER,
      createdAt TEXT
    )`);
  }

  private async seedIfNeeded(): Promise<void> {
    if (!this.store) {
      return;
    }
    const count: number = await this.count(VEHICLE_TABLE);
    if (count > 0) {
      return;
    }
    for (const vehicle of createDemoVehicles()) {
      await this.insertVehicle(vehicle);
    }
    for (const record of createDemoRecords()) {
      await this.insertRecord(record);
    }
    for (const reminder of createDemoReminders()) {
      await this.insertReminder(reminder);
    }
  }

  private ensureStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('DatabaseService is not initialized.');
    }
    return this.store;
  }

  async count(tableName: string): Promise<number> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const resultSet: relationalStore.ResultSet = await store.querySql(`SELECT COUNT(1) AS count FROM ${tableName}`);
    let count: number = 0;
    if (resultSet.goToFirstRow()) {
      count = resultSet.getLong(resultSet.getColumnIndex('count'));
    }
    resultSet.close();
    return count;
  }

  async queryVehicles(): Promise<Vehicle[]> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const resultSet: relationalStore.ResultSet = await store.querySql(`SELECT * FROM ${VEHICLE_TABLE} ORDER BY isDefault DESC, id DESC`);
    const items: Vehicle[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        plateNumber: resultSet.getString(resultSet.getColumnIndex('plateNumber')),
        brand: resultSet.getString(resultSet.getColumnIndex('brand')),
        model: resultSet.getString(resultSet.getColumnIndex('model')),
        purchaseDate: resultSet.getString(resultSet.getColumnIndex('purchaseDate')),
        mileage: resultSet.getLong(resultSet.getColumnIndex('mileage')),
        vin: resultSet.getString(resultSet.getColumnIndex('vin')),
        insuranceExpiry: resultSet.getString(resultSet.getColumnIndex('insuranceExpiry')),
        inspectionExpiry: resultSet.getString(resultSet.getColumnIndex('inspectionExpiry')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        isDefault: resultSet.getLong(resultSet.getColumnIndex('isDefault')) === 1,
        createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
      });
    }
    resultSet.close();
    return items;
  }

  async queryRecords(vehicleId?: number): Promise<MaintenanceRecord[]> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const sql: string = vehicleId && vehicleId > 0
      ? `SELECT * FROM ${RECORD_TABLE} WHERE vehicleId = ? ORDER BY date DESC, id DESC`
      : `SELECT * FROM ${RECORD_TABLE} ORDER BY date DESC, id DESC`;
    const args: relationalStore.ValueType[] = vehicleId && vehicleId > 0 ? [vehicleId] : [];
    const resultSet: relationalStore.ResultSet = await store.querySql(sql, args);
    const items: MaintenanceRecord[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        vehicleId: resultSet.getLong(resultSet.getColumnIndex('vehicleId')),
        type: resultSet.getString(resultSet.getColumnIndex('type')),
        date: resultSet.getString(resultSet.getColumnIndex('date')),
        mileage: resultSet.getLong(resultSet.getColumnIndex('mileage')),
        cost: resultSet.getLong(resultSet.getColumnIndex('cost')),
        shop: resultSet.getString(resultSet.getColumnIndex('shop')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        nextDate: resultSet.getString(resultSet.getColumnIndex('nextDate')),
        nextMileage: resultSet.getLong(resultSet.getColumnIndex('nextMileage')),
        photos: parseStringArray(resultSet.getString(resultSet.getColumnIndex('photos'))),
        createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
      });
    }
    resultSet.close();
    return items;
  }

  async queryReminders(vehicleId?: number): Promise<ReminderItem[]> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const sql: string = vehicleId && vehicleId > 0
      ? `SELECT * FROM ${REMINDER_TABLE} WHERE vehicleId = ? ORDER BY triggerDate ASC, id DESC`
      : `SELECT * FROM ${REMINDER_TABLE} ORDER BY triggerDate ASC, id DESC`;
    const args: relationalStore.ValueType[] = vehicleId && vehicleId > 0 ? [vehicleId] : [];
    const resultSet: relationalStore.ResultSet = await store.querySql(sql, args);
    const items: ReminderItem[] = [];
    while (resultSet.goToNextRow()) {
      items.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        vehicleId: resultSet.getLong(resultSet.getColumnIndex('vehicleId')),
        reminderId: resultSet.getLong(resultSet.getColumnIndex('reminderId')),
        type: resultSet.getString(resultSet.getColumnIndex('type')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        triggerDate: resultSet.getString(resultSet.getColumnIndex('triggerDate')),
        targetMileage: resultSet.getLong(resultSet.getColumnIndex('targetMileage')),
        isActive: resultSet.getLong(resultSet.getColumnIndex('isActive')) === 1,
        createdAt: resultSet.getString(resultSet.getColumnIndex('createdAt'))
      });
    }
    resultSet.close();
    return items;
  }

  async insertVehicle(vehicle: Vehicle): Promise<number> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      plateNumber: vehicle.plateNumber,
      brand: vehicle.brand,
      model: vehicle.model,
      purchaseDate: vehicle.purchaseDate,
      mileage: vehicle.mileage,
      vin: vehicle.vin,
      insuranceExpiry: vehicle.insuranceExpiry,
      inspectionExpiry: vehicle.inspectionExpiry,
      color: vehicle.color,
      isDefault: parseBooleanNumber(vehicle.isDefault),
      createdAt: vehicle.createdAt
    };
    return await store.insert(VEHICLE_TABLE, valueBucket);
  }

  async updateVehicle(vehicle: Vehicle): Promise<void> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(VEHICLE_TABLE);
    predicates.equalTo('id', vehicle.id);
    const valueBucket: relationalStore.ValuesBucket = {
      plateNumber: vehicle.plateNumber,
      brand: vehicle.brand,
      model: vehicle.model,
      purchaseDate: vehicle.purchaseDate,
      mileage: vehicle.mileage,
      vin: vehicle.vin,
      insuranceExpiry: vehicle.insuranceExpiry,
      inspectionExpiry: vehicle.inspectionExpiry,
      color: vehicle.color,
      isDefault: parseBooleanNumber(vehicle.isDefault)
    };
    await store.update(valueBucket, predicates);
  }

  async insertRecord(record: MaintenanceRecord): Promise<number> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      vehicleId: record.vehicleId,
      type: record.type,
      date: record.date,
      mileage: record.mileage,
      cost: record.cost,
      shop: record.shop,
      note: record.note,
      nextDate: record.nextDate,
      nextMileage: record.nextMileage,
      photos: stringifyStringArray(record.photos),
      createdAt: record.createdAt
    };
    return await store.insert(RECORD_TABLE, valueBucket);
  }

  async updateRecord(record: MaintenanceRecord): Promise<void> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(RECORD_TABLE);
    predicates.equalTo('id', record.id);
    const valueBucket: relationalStore.ValuesBucket = {
      vehicleId: record.vehicleId,
      type: record.type,
      date: record.date,
      mileage: record.mileage,
      cost: record.cost,
      shop: record.shop,
      note: record.note,
      nextDate: record.nextDate,
      nextMileage: record.nextMileage,
      photos: stringifyStringArray(record.photos)
    };
    await store.update(valueBucket, predicates);
  }

  async insertReminder(reminder: ReminderItem): Promise<number> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const valueBucket: relationalStore.ValuesBucket = {
      vehicleId: reminder.vehicleId,
      reminderId: reminder.reminderId,
      type: reminder.type,
      title: reminder.title,
      content: reminder.content,
      triggerDate: reminder.triggerDate,
      targetMileage: reminder.targetMileage,
      isActive: parseBooleanNumber(reminder.isActive),
      createdAt: reminder.createdAt
    };
    return await store.insert(REMINDER_TABLE, valueBucket);
  }

  async updateReminder(reminder: ReminderItem): Promise<void> {
    const store: relationalStore.RdbStore = this.ensureStore();
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(REMINDER_TABLE);
    predicates.equalTo('id', reminder.id);
    const valueBucket: relationalStore.ValuesBucket = {
      vehicleId: reminder.vehicleId,
      reminderId: reminder.reminderId,
      type: reminder.type,
      title: reminder.title,
      content: reminder.content,
      triggerDate: reminder.triggerDate,
      targetMileage: reminder.targetMileage,
      isActive: parseBooleanNumber(reminder.isActive)
    };
    await store.update(valueBucket, predicates);
  }
}

export const databaseService: DatabaseService = new DatabaseService();
