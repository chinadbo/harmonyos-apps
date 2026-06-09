import UIAbilityContext from '@ohos.app.ability.UIAbilityContext'
import relationalStore from '@ohos.data.relationalStore'

import { Medicine } from '../models/MedicineModel'
import { RecordItem } from '../models/RecordModel'
import { Schedule } from '../models/ScheduleModel'

export interface TodayScheduleItem {
  schedule: Schedule
  medicine: Medicine
  record?: RecordItem
}

export interface DailyStatsItem {
  date: string
  planned: number
  taken: number
}

export interface CalendarStatusItem {
  date: string
  hasTaken: boolean
  hasMissed: boolean
}

export class PillDatabase {
  private static instance?: PillDatabase
  private context?: UIAbilityContext
  private store?: relationalStore.RdbStore
  private initialized: boolean = false

  static getInstance(): PillDatabase {
    if (!PillDatabase.instance) {
      PillDatabase.instance = new PillDatabase()
    }
    return PillDatabase.instance
  }

  async init(context: UIAbilityContext): Promise<void> {
    if (this.initialized) {
      return
    }
    this.context = context
    const config: relationalStore.StoreConfig = {
      name: 'harmonypill.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.store = await relationalStore.getRdbStore(context, config)
    await this.createTables()
    this.initialized = true
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database is not initialized')
    }
    return this.store
  }

  private async createTables(): Promise<void> {
    const store = this.getStore()
    await store.executeSql(`CREATE TABLE IF NOT EXISTS medicine (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      spec TEXT,
      notes TEXT,
      stock INTEGER,
      unit TEXT
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS schedule (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      medicineId INTEGER NOT NULL,
      hour INTEGER NOT NULL,
      minute INTEGER NOT NULL,
      dose TEXT NOT NULL,
      frequency TEXT NOT NULL,
      weekDays TEXT,
      reminderId INTEGER,
      enabled INTEGER NOT NULL DEFAULT 1
    )`)
    await store.executeSql(`CREATE TABLE IF NOT EXISTS record (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      medicineId INTEGER NOT NULL,
      scheduleId INTEGER NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      dose TEXT NOT NULL,
      status INTEGER NOT NULL
    )`)
  }

  private rowToMedicineSet(row: relationalStore.ResultSet): Medicine {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      name: row.getString(row.getColumnIndex('name')),
      spec: row.getString(row.getColumnIndex('spec')),
      notes: row.getString(row.getColumnIndex('notes')),
      stock: row.getLong(row.getColumnIndex('stock')),
      unit: row.getString(row.getColumnIndex('unit'))
    }
  }

  private rowToScheduleSet(row: relationalStore.ResultSet): Schedule {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      medicineId: row.getLong(row.getColumnIndex('medicineId')),
      hour: row.getLong(row.getColumnIndex('hour')),
      minute: row.getLong(row.getColumnIndex('minute')),
      dose: row.getString(row.getColumnIndex('dose')),
      frequency: row.getString(row.getColumnIndex('frequency')) as ('DAILY' | 'EVERY_OTHER_DAY' | 'WEEKLY'),
      weekDays: row.getString(row.getColumnIndex('weekDays')),
      reminderId: row.getLong(row.getColumnIndex('reminderId')),
      enabled: row.getLong(row.getColumnIndex('enabled'))
    }
  }

  private rowToRecordSet(row: relationalStore.ResultSet): RecordItem {
    return {
      id: row.getLong(row.getColumnIndex('id')),
      medicineId: row.getLong(row.getColumnIndex('medicineId')),
      scheduleId: row.getLong(row.getColumnIndex('scheduleId')),
      date: row.getString(row.getColumnIndex('date')),
      time: row.getString(row.getColumnIndex('time')),
      dose: row.getString(row.getColumnIndex('dose')),
      status: row.getLong(row.getColumnIndex('status')) as (0 | 1 | 2)
    }
  }

  async getMedicines(): Promise<Medicine[]> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates('medicine')
    predicates.orderByAsc('name')
    const result = await store.query(predicates)
    const list: Medicine[] = []
    while (result.goToNextRow()) {
      list.push(this.rowToMedicineSet(result))
    }
    result.close()
    return list
  }

  async getMedicineById(id: number): Promise<Medicine | undefined> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates('medicine')
    predicates.equalTo('id', id)
    const result = await store.query(predicates)
    let medicine: Medicine | undefined = undefined
    if (result.goToFirstRow()) {
      medicine = this.rowToMedicineSet(result)
    }
    result.close()
    return medicine
  }

  async saveMedicine(medicine: Medicine): Promise<number> {
    const store = this.getStore()
    const value: relationalStore.ValuesBucket = {
      name: medicine.name,
      spec: medicine.spec,
      notes: medicine.notes,
      stock: medicine.stock,
      unit: medicine.unit
    }
    if (medicine.id > 0) {
      const predicates = new relationalStore.RdbPredicates('medicine')
      predicates.equalTo('id', medicine.id)
      await store.update(value, predicates)
      return medicine.id
    }
    return await store.insert('medicine', value)
  }

  async deleteMedicine(id: number): Promise<void> {
    const store = this.getStore()
    let predicates = new relationalStore.RdbPredicates('schedule')
    predicates.equalTo('medicineId', id)
    await store.delete(predicates)
    predicates = new relationalStore.RdbPredicates('record')
    predicates.equalTo('medicineId', id)
    await store.delete(predicates)
    predicates = new relationalStore.RdbPredicates('medicine')
    predicates.equalTo('id', id)
    await store.delete(predicates)
  }

  async getSchedules(): Promise<Schedule[]> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates('schedule')
    predicates.orderByAsc('hour').orderByAsc('minute')
    const result = await store.query(predicates)
    const list: Schedule[] = []
    while (result.goToNextRow()) {
      list.push(this.rowToScheduleSet(result))
    }
    result.close()
    return list
  }

  async saveSchedule(schedule: Schedule): Promise<number> {
    const store = this.getStore()
    const value: relationalStore.ValuesBucket = {
      medicineId: schedule.medicineId,
      hour: schedule.hour,
      minute: schedule.minute,
      dose: schedule.dose,
      frequency: schedule.frequency,
      weekDays: schedule.weekDays,
      reminderId: schedule.reminderId,
      enabled: schedule.enabled
    }
    if (schedule.id > 0) {
      const predicates = new relationalStore.RdbPredicates('schedule')
      predicates.equalTo('id', schedule.id)
      await store.update(value, predicates)
      return schedule.id
    }
    return await store.insert('schedule', value)
  }

  async updateScheduleReminder(scheduleId: number, reminderId: number): Promise<void> {
    const store = this.getStore()
    const value: relationalStore.ValuesBucket = {
      reminderId: reminderId
    }
    const predicates = new relationalStore.RdbPredicates('schedule')
    predicates.equalTo('id', scheduleId)
    await store.update(value, predicates)
  }

  async getRecordsByDate(date: string): Promise<RecordItem[]> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates('record')
    predicates.equalTo('date', date).orderByAsc('time')
    const result = await store.query(predicates)
    const list: RecordItem[] = []
    while (result.goToNextRow()) {
      list.push(this.rowToRecordSet(result))
    }
    result.close()
    return list
  }

  async saveRecord(record: RecordItem): Promise<number> {
    const store = this.getStore()
    const value: relationalStore.ValuesBucket = {
      medicineId: record.medicineId,
      scheduleId: record.scheduleId,
      date: record.date,
      time: record.time,
      dose: record.dose,
      status: record.status
    }
    if (record.id > 0) {
      const predicates = new relationalStore.RdbPredicates('record')
      predicates.equalTo('id', record.id)
      await store.update(value, predicates)
      return record.id
    }
    return await store.insert('record', value)
  }

  async getTodayScheduleItems(date: string, weekDay: number): Promise<TodayScheduleItem[]> {
    const medicines = await this.getMedicines()
    const medicineMap = new Map<number, Medicine>()
    medicines.forEach((medicine: Medicine) => medicineMap.set(medicine.id, medicine))
    const records = await this.getRecordsByDate(date)
    const recordMap = new Map<number, RecordItem>()
    records.forEach((record: RecordItem) => recordMap.set(record.scheduleId, record))
    const schedules = await this.getSchedules()
    return schedules
      .filter((schedule: Schedule) => schedule.enabled === 1 && this.matchesSchedule(schedule, date, weekDay))
      .map((schedule: Schedule) => {
        return {
          schedule: schedule,
          medicine: medicineMap.get(schedule.medicineId) as Medicine,
          record: recordMap.get(schedule.id)
        }
      })
      .filter((item: TodayScheduleItem) => !!item.medicine)
      .sort((left: TodayScheduleItem, right: TodayScheduleItem) => {
        const leftValue = left.schedule.hour * 60 + left.schedule.minute
        const rightValue = right.schedule.hour * 60 + right.schedule.minute
        return leftValue - rightValue
      })
  }

  private matchesSchedule(schedule: Schedule, date: string, weekDay: number): boolean {
    if (schedule.frequency === 'DAILY') {
      return true
    }
    if (schedule.frequency === 'EVERY_OTHER_DAY') {
      const dayNumber = Number(date.split('-')[2])
      return dayNumber % 2 === 1
    }
    if (schedule.frequency === 'WEEKLY') {
      const days = schedule.weekDays.split(',').filter((item: string) => item.length > 0)
      return days.includes(String(weekDay))
    }
    return false
  }

  async getCalendarStatus(yearMonth: string): Promise<CalendarStatusItem[]> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates('record')
    predicates.beginsWith('date', yearMonth)
    const result = await store.query(predicates)
    const map = new Map<string, CalendarStatusItem>()
    while (result.goToNextRow()) {
      const item = this.rowToRecordSet(result)
      const current = map.get(item.date) || {
        date: item.date,
        hasTaken: false,
        hasMissed: false
      }
      if (item.status === 1) {
        current.hasTaken = true
      }
      if (item.status === 2) {
        current.hasMissed = true
      }
      map.set(item.date, current)
    }
    result.close()
    return Array.from(map.values())
  }

  async getWeeklyStats(startDate: string, endDate: string): Promise<DailyStatsItem[]> {
    const dates = this.buildDateRange(startDate, endDate)
    const schedules = await this.getSchedules()
    const recordsByDate = new Map<string, RecordItem[]>()
    for (let i = 0; i < dates.length; i++) {
      recordsByDate.set(dates[i], await this.getRecordsByDate(dates[i]))
    }

    return dates.map((date: string) => {
      const weekday = this.getWeekDayNumber(date)
      const planned = schedules.filter((schedule: Schedule) => schedule.enabled === 1 && this.matchesSchedule(schedule, date, weekday)).length
      const records = recordsByDate.get(date) || []
      const taken = records.filter((record: RecordItem) => record.status === 1).length
      return {
        date: date,
        planned: planned,
        taken: taken
      }
    })
  }

  async getTotalMedicineCount(): Promise<number> {
    return (await this.getMedicines()).length
  }

  async getTotalScheduleCount(): Promise<number> {
    return (await this.getSchedules()).length
  }

  private buildDateRange(startDate: string, endDate: string): string[] {
    const list: string[] = []
    const current = new Date(`${startDate}T00:00:00`)
    const end = new Date(`${endDate}T00:00:00`)
    while (current.getTime() <= end.getTime()) {
      list.push(this.formatDate(current))
      current.setDate(current.getDate() + 1)
    }
    return list
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  private getWeekDayNumber(date: string): number {
    const weekDay = new Date(`${date}T00:00:00`).getDay()
    return weekDay === 0 ? 7 : weekDay
  }
}

export const pillDatabase = PillDatabase.getInstance()
