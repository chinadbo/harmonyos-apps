import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import DatabaseHelper from './DatabaseHelper'
import { Trip, TripSummary, createTripRow } from '../model/Trip'
import { TripStatus } from '../model/Constants'

export default class TripDao {
  private static tableName: string = 'trips'

  static resolveStatus(startDate: number, endDate: number): string {
    const now = Date.now()
    if (now < startDate) {
      return TripStatus.UPCOMING
    }
    if (now <= endDate) {
      return TripStatus.ACTIVE
    }
    return TripStatus.COMPLETED
  }

  static async save(context: common.Context, trip: Trip): Promise<number> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    trip.status = TripDao.resolveStatus(trip.startDate, trip.endDate)
    trip.updatedAt = Date.now()
    if (trip.id > 0) {
      const predicates = new relationalStore.RdbPredicates(TripDao.tableName)
      predicates.equalTo('id', trip.id)
      await store.update(createTripRow(trip) as relationalStore.ValuesBucket, predicates)
      return trip.id
    }
    trip.createdAt = Date.now()
    const values = createTripRow(trip) as relationalStore.ValuesBucket
    delete (values as Record<string, number | string>).id
    return await store.insert(TripDao.tableName, values)
  }

  static async updateReminderIds(context: common.Context, tripId: number, reminder24Id: number, reminder2Id: number): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const predicates = new relationalStore.RdbPredicates(TripDao.tableName)
    predicates.equalTo('id', tripId)
    await store.update({
      reminder_24_id: reminder24Id,
      reminder_2_id: reminder2Id,
      updated_at: Date.now()
    } as relationalStore.ValuesBucket, predicates)
  }

  static async updateStatus(context: common.Context, tripId: number, status: string): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const predicates = new relationalStore.RdbPredicates(TripDao.tableName)
    predicates.equalTo('id', tripId)
    await store.update({
      status: status,
      updated_at: Date.now()
    } as relationalStore.ValuesBucket, predicates)
  }

  static async findById(context: common.Context, tripId: number): Promise<Trip | null> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`SELECT * FROM trips WHERE id = ${tripId} LIMIT 1`)
    const trip = TripDao.readSingleTrip(resultSet)
    resultSet.close()
    return trip
  }

  static async delete(context: common.Context, tripId: number): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    let itemPredicates = new relationalStore.RdbPredicates('items')
    itemPredicates.equalTo('trip_id', tripId)
    await store.delete(itemPredicates)
    let tripPredicates = new relationalStore.RdbPredicates(TripDao.tableName)
    tripPredicates.equalTo('id', tripId)
    await store.delete(tripPredicates)
  }

  static async queryByStatus(context: common.Context, status: string): Promise<TripSummary[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const sql = `
      SELECT t.*, COUNT(i.id) AS total_items, SUM(CASE WHEN i.is_packed = 1 THEN 1 ELSE 0 END) AS packed_items
      FROM trips t
      LEFT JOIN items i ON t.id = i.trip_id
      WHERE t.status = '${status}'
      GROUP BY t.id
      ORDER BY t.start_date ASC
    `
    const resultSet = await store.querySql(sql)
    const list = TripDao.readSummaryList(resultSet)
    resultSet.close()
    return list
  }

  static async listAll(context: common.Context): Promise<TripSummary[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const sql = `
      SELECT t.*, COUNT(i.id) AS total_items, SUM(CASE WHEN i.is_packed = 1 THEN 1 ELSE 0 END) AS packed_items
      FROM trips t
      LEFT JOIN items i ON t.id = i.trip_id
      GROUP BY t.id
      ORDER BY t.start_date ASC
    `
    const resultSet = await store.querySql(sql)
    const list = TripDao.readSummaryList(resultSet)
    resultSet.close()
    return list
  }

  static async listRecentSummaries(context: common.Context, limit: number = 6): Promise<TripSummary[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const sql = `
      SELECT t.*, COUNT(i.id) AS total_items, SUM(CASE WHEN i.is_packed = 1 THEN 1 ELSE 0 END) AS packed_items
      FROM trips t
      LEFT JOIN items i ON t.id = i.trip_id
      GROUP BY t.id
      ORDER BY t.start_date DESC
      LIMIT ${limit}
    `
    const resultSet = await store.querySql(sql)
    const list = TripDao.readSummaryList(resultSet)
    resultSet.close()
    return list.reverse()
  }

  static async getMonthTripCount(context: common.Context, year: number, month: number): Promise<number> {
    const start = new Date(year, month - 1, 1).getTime()
    const end = new Date(year, month, 1).getTime()
    const store = await DatabaseHelper.getInstance().getStore(context)
    const sql = `SELECT COUNT(id) AS total_count FROM trips WHERE start_date >= ${start} AND start_date < ${end}`
    const resultSet = await store.querySql(sql)
    const count = TripDao.readNumber(resultSet, 'total_count')
    resultSet.close()
    return count
  }

  private static readSummaryList(resultSet: relationalStore.ResultSet): TripSummary[] {
    const list: TripSummary[] = []
    if (resultSet.rowCount === 0) {
      return list
    }
    resultSet.goToFirstRow()
    do {
      const trip = TripDao.readTrip(resultSet)
      const totalItems = TripDao.getNumber(resultSet, 'total_items')
      const packedItems = TripDao.getNumber(resultSet, 'packed_items')
      list.push({
        trip: trip,
        totalItems: totalItems,
        packedItems: packedItems,
        progress: totalItems === 0 ? 0 : Math.round((packedItems / totalItems) * 100)
      })
    } while (resultSet.goToNextRow())
    return list
  }

  private static readSingleTrip(resultSet: relationalStore.ResultSet): Trip | null {
    if (resultSet.rowCount === 0) {
      return null
    }
    resultSet.goToFirstRow()
    return TripDao.readTrip(resultSet)
  }

  private static readTrip(resultSet: relationalStore.ResultSet): Trip {
    return new Trip({
      id: TripDao.getNumber(resultSet, 'id'),
      title: TripDao.getString(resultSet, 'title'),
      destination: TripDao.getString(resultSet, 'destination'),
      startDate: TripDao.getNumber(resultSet, 'start_date'),
      endDate: TripDao.getNumber(resultSet, 'end_date'),
      tripType: TripDao.getString(resultSet, 'trip_type'),
      status: TripDao.getString(resultSet, 'status'),
      note: TripDao.getString(resultSet, 'note'),
      reminder24Id: TripDao.getNumber(resultSet, 'reminder_24_id'),
      reminder2Id: TripDao.getNumber(resultSet, 'reminder_2_id'),
      createdAt: TripDao.getNumber(resultSet, 'created_at'),
      updatedAt: TripDao.getNumber(resultSet, 'updated_at')
    })
  }

  private static readNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    if (resultSet.rowCount === 0) {
      return 0
    }
    resultSet.goToFirstRow()
    return TripDao.getNumber(resultSet, columnName)
  }

  private static getNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    const index = resultSet.getColumnIndex(columnName)
    return index >= 0 ? Number(resultSet.getLong(index)) : 0
  }

  private static getString(resultSet: relationalStore.ResultSet, columnName: string): string {
    const index = resultSet.getColumnIndex(columnName)
    return index >= 0 ? resultSet.getString(index) : ''
  }
}
