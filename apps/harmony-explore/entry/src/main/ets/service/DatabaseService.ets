import common from '@ohos.app.ability.common'
import { BusinessError } from '@ohos.base'
import relationalStore from '@ohos.data.relationalStore'
import { CheckInDetailModel, CheckInModel, CheckInPhotoModel } from '../model/CheckInModel'
import { SpotModel } from '../model/SpotModel'
import { DbConfig, DbTables, StatisticsConstants } from '../utils/Constants'
import { DateUtils } from '../utils/DateUtils'

interface RecentStatisticItem {
  date: number
  count: number
}

interface StatisticsSummary {
  totalCheckIns: number
  totalCities: number
  recent: RecentStatisticItem[]
}

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private context?: common.UIAbilityContext
  private store?: relationalStore.RdbStore
  private initialized: boolean = false

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized && this.store) {
      return
    }
    this.context = context
    this.store = await new Promise<relationalStore.RdbStore>((resolve, reject) => {
      relationalStore.getRdbStore(context, {
        name: DbConfig.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      }, 1, (err: BusinessError, store: relationalStore.RdbStore) => {
        if (err) {
          reject(err)
          return
        }
        resolve(store)
      })
    })
    await this.createTables()
    this.initialized = true
  }

  async addSpotAndCheckIn(spot: SpotModel, checkIn: Omit<CheckInModel, 'id' | 'spotId'>, photoUris: string[]): Promise<number> {
    const spotId: number = await this.saveSpot(spot)
    await this.createCheckIn(spotId, checkIn, photoUris)
    return spotId
  }

  async saveSpot(spot: SpotModel): Promise<number> {
    const store: relationalStore.RdbStore = await this.requireStore()
    const values: relationalStore.ValuesBucket = {
      name: spot.name,
      address: spot.address,
      latitude: spot.latitude,
      longitude: spot.longitude,
      city: spot.city,
      category: spot.category,
      coverUri: spot.coverUri,
      createdAt: spot.createdAt,
      checkInCount: spot.checkInCount
    }
    if (spot.id > 0) {
      await this.execute(
        `UPDATE ${DbTables.SPOTS} SET name=?, address=?, latitude=?, longitude=?, city=?, category=?, coverUri=?, checkInCount=? WHERE id=?`,
        [spot.name, spot.address, spot.latitude, spot.longitude, spot.city, spot.category, spot.coverUri, spot.checkInCount, spot.id]
      )
      return spot.id
    }
    return await new Promise<number>((resolve, reject) => {
      store.insert(DbTables.SPOTS, values, (err: BusinessError, rowId: number) => {
        if (err) {
          reject(err)
          return
        }
        resolve(rowId)
      })
    })
  }

  async getAllSpots(): Promise<SpotModel[]> {
    return await this.queryRows<SpotModel>(
      `SELECT id, name, address, latitude, longitude, city, category, coverUri, createdAt, checkInCount FROM ${DbTables.SPOTS} ORDER BY createdAt DESC`,
      [],
      (resultSet: relationalStore.ResultSet) => {
        return {
          id: this.getNumber(resultSet, 'id'),
          name: this.getString(resultSet, 'name'),
          address: this.getString(resultSet, 'address'),
          latitude: this.getDouble(resultSet, 'latitude'),
          longitude: this.getDouble(resultSet, 'longitude'),
          city: this.getString(resultSet, 'city'),
          category: this.getString(resultSet, 'category'),
          coverUri: this.getString(resultSet, 'coverUri'),
          createdAt: this.getNumber(resultSet, 'createdAt'),
          checkInCount: this.getNumber(resultSet, 'checkInCount')
        }
      }
    )
  }

  async getSpotById(id: number): Promise<SpotModel | null> {
    const rows: SpotModel[] = await this.queryRows<SpotModel>(
      `SELECT id, name, address, latitude, longitude, city, category, coverUri, createdAt, checkInCount FROM ${DbTables.SPOTS} WHERE id=? LIMIT 1`,
      [id],
      (resultSet: relationalStore.ResultSet) => {
        return {
          id: this.getNumber(resultSet, 'id'),
          name: this.getString(resultSet, 'name'),
          address: this.getString(resultSet, 'address'),
          latitude: this.getDouble(resultSet, 'latitude'),
          longitude: this.getDouble(resultSet, 'longitude'),
          city: this.getString(resultSet, 'city'),
          category: this.getString(resultSet, 'category'),
          coverUri: this.getString(resultSet, 'coverUri'),
          createdAt: this.getNumber(resultSet, 'createdAt'),
          checkInCount: this.getNumber(resultSet, 'checkInCount')
        }
      }
    )
    return rows.length > 0 ? rows[0] : null
  }

  async deleteSpot(id: number): Promise<void> {
    await this.execute(`DELETE FROM ${DbTables.PHOTOS} WHERE checkInId IN (SELECT id FROM ${DbTables.CHECK_INS} WHERE spotId=?)`, [id])
    await this.execute(`DELETE FROM ${DbTables.CHECK_INS} WHERE spotId=?`, [id])
    await this.execute(`DELETE FROM ${DbTables.SPOTS} WHERE id=?`, [id])
  }

  async createCheckIn(spotId: number, checkIn: Omit<CheckInModel, 'id' | 'spotId'>, photoUris: string[]): Promise<number> {
    const store: relationalStore.RdbStore = await this.requireStore()
    const checkInId: number = await new Promise<number>((resolve, reject) => {
      const values: relationalStore.ValuesBucket = {
        spotId,
        checkInAt: checkIn.checkInAt,
        mood: checkIn.mood,
        weather: checkIn.weather,
        note: checkIn.note
      }
      store.insert(DbTables.CHECK_INS, values, (err: BusinessError, rowId: number) => {
        if (err) {
          reject(err)
          return
        }
        resolve(rowId)
      })
    })
    for (const uri of photoUris) {
      await new Promise<number>((resolve, reject) => {
        const values: relationalStore.ValuesBucket = {
          checkInId,
          uri,
          createdAt: Date.now()
        }
        store.insert(DbTables.PHOTOS, values, (err: BusinessError, rowId: number) => {
          if (err) {
            reject(err)
            return
          }
          resolve(rowId)
        })
      })
    }
    await this.execute(`UPDATE ${DbTables.SPOTS} SET checkInCount = checkInCount + 1, coverUri = CASE WHEN coverUri='' THEN ? ELSE coverUri END WHERE id=?`, [photoUris[0] ?? '', spotId])
    return checkInId
  }

  async getCheckInList(): Promise<CheckInDetailModel[]> {
    const rows: CheckInDetailModel[] = await this.queryRows<CheckInDetailModel>(
      `SELECT c.id, c.spotId, c.checkInAt, c.mood, c.weather, c.note, s.name AS spotName, s.city AS city, s.address AS address, s.category AS category, s.coverUri AS coverUri FROM ${DbTables.CHECK_INS} c LEFT JOIN ${DbTables.SPOTS} s ON c.spotId = s.id ORDER BY c.checkInAt DESC`,
      [],
      (resultSet: relationalStore.ResultSet) => {
        return {
          id: this.getNumber(resultSet, 'id'),
          spotId: this.getNumber(resultSet, 'spotId'),
          checkInAt: this.getNumber(resultSet, 'checkInAt'),
          mood: this.getString(resultSet, 'mood'),
          weather: this.getString(resultSet, 'weather'),
          note: this.getString(resultSet, 'note'),
          spotName: this.getString(resultSet, 'spotName'),
          city: this.getString(resultSet, 'city'),
          address: this.getString(resultSet, 'address'),
          category: this.getString(resultSet, 'category'),
          coverUri: this.getString(resultSet, 'coverUri'),
          photoUris: []
        }
      }
    )
    for (const item of rows) {
      item.photoUris = await this.getPhotosByCheckInId(item.id)
    }
    return rows
  }

  async getCheckInDetail(id: number): Promise<CheckInDetailModel | null> {
    const rows: CheckInDetailModel[] = await this.queryRows<CheckInDetailModel>(
      `SELECT c.id, c.spotId, c.checkInAt, c.mood, c.weather, c.note, s.name AS spotName, s.city AS city, s.address AS address, s.category AS category, s.coverUri AS coverUri FROM ${DbTables.CHECK_INS} c LEFT JOIN ${DbTables.SPOTS} s ON c.spotId = s.id WHERE c.id=? LIMIT 1`,
      [id],
      (resultSet: relationalStore.ResultSet) => {
        return {
          id: this.getNumber(resultSet, 'id'),
          spotId: this.getNumber(resultSet, 'spotId'),
          checkInAt: this.getNumber(resultSet, 'checkInAt'),
          mood: this.getString(resultSet, 'mood'),
          weather: this.getString(resultSet, 'weather'),
          note: this.getString(resultSet, 'note'),
          spotName: this.getString(resultSet, 'spotName'),
          city: this.getString(resultSet, 'city'),
          address: this.getString(resultSet, 'address'),
          category: this.getString(resultSet, 'category'),
          coverUri: this.getString(resultSet, 'coverUri'),
          photoUris: []
        }
      }
    )
    if (rows.length === 0) {
      return null
    }
    rows[0].photoUris = await this.getPhotosByCheckInId(id)
    return rows[0]
  }

  async getPhotosByCheckInId(checkInId: number): Promise<string[]> {
    const photos: CheckInPhotoModel[] = await this.queryRows<CheckInPhotoModel>(
      `SELECT id, checkInId, uri, createdAt FROM ${DbTables.PHOTOS} WHERE checkInId=? ORDER BY createdAt ASC`,
      [checkInId],
      (resultSet: relationalStore.ResultSet) => {
        return {
          id: this.getNumber(resultSet, 'id'),
          checkInId: this.getNumber(resultSet, 'checkInId'),
          uri: this.getString(resultSet, 'uri'),
          createdAt: this.getNumber(resultSet, 'createdAt')
        }
      }
    )
    return photos.map((item: CheckInPhotoModel) => item.uri)
  }

  async getStatisticsSummary(): Promise<StatisticsSummary> {
    const checkIns: CheckInDetailModel[] = await this.getCheckInList()
    const citySet: Set<string> = new Set<string>()
    checkIns.forEach((item: CheckInDetailModel) => {
      if (item.city.length > 0) {
        citySet.add(item.city)
      }
    })
    const days: number[] = DateUtils.recentDays(StatisticsConstants.RECENT_DAYS)
    const recent: RecentStatisticItem[] = days.map((date: number) => ({
      date,
      count: 0
    }))
    for (const item of checkIns) {
      const targetDay: number = DateUtils.startOfDay(item.checkInAt)
      const found: RecentStatisticItem | undefined = recent.find((entry: RecentStatisticItem) => entry.date === targetDay)
      if (found) {
        found.count++
      }
    }
    return {
      totalCheckIns: checkIns.length,
      totalCities: citySet.size,
      recent
    }
  }

  async getAchievementMetrics(): Promise<Record<string, number>> {
    const summary: StatisticsSummary = await this.getStatisticsSummary()
    return {
      checkInCount: summary.totalCheckIns,
      cityCount: summary.totalCities
    }
  }

  async getLatestCheckInAt(): Promise<number> {
    const values: Array<{ latestAt: number }> = await this.queryRows<{ latestAt: number }>(
      `SELECT MAX(checkInAt) AS latestAt FROM ${DbTables.CHECK_INS}`,
      [],
      (resultSet: relationalStore.ResultSet) => ({
        latestAt: this.getNumber(resultSet, 'latestAt')
      })
    )
    return values.length > 0 ? values[0].latestAt : 0
  }

  private async createTables(): Promise<void> {
    await this.execute(`CREATE TABLE IF NOT EXISTS ${DbTables.SPOTS} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, address TEXT NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL, city TEXT, category TEXT, coverUri TEXT DEFAULT '', createdAt INTEGER NOT NULL, checkInCount INTEGER DEFAULT 0)`)
    await this.execute(`CREATE TABLE IF NOT EXISTS ${DbTables.CHECK_INS} (id INTEGER PRIMARY KEY AUTOINCREMENT, spotId INTEGER NOT NULL, checkInAt INTEGER NOT NULL, mood TEXT, weather TEXT, note TEXT)`)
    await this.execute(`CREATE TABLE IF NOT EXISTS ${DbTables.PHOTOS} (id INTEGER PRIMARY KEY AUTOINCREMENT, checkInId INTEGER NOT NULL, uri TEXT NOT NULL, createdAt INTEGER NOT NULL)`)
  }

  private async requireStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store
    }
    if (!this.context) {
      throw new Error('DatabaseService is not initialized')
    }
    await this.init(this.context)
    if (!this.store) {
      throw new Error('DatabaseService failed to initialize store')
    }
    return this.store
  }

  private async execute(sql: string, bindArgs: Array<string | number> = []): Promise<void> {
    const store: relationalStore.RdbStore = await this.requireStore()
    await new Promise<void>((resolve, reject) => {
      store.executeSql(sql, bindArgs, (err: BusinessError) => {
        if (err) {
          reject(err)
          return
        }
        resolve()
      })
    })
  }

  private async queryRows<T>(sql: string, bindArgs: Array<string | number>, mapper: (resultSet: relationalStore.ResultSet) => T): Promise<T[]> {
    const store: relationalStore.RdbStore = await this.requireStore()
    return await new Promise<T[]>((resolve, reject) => {
      store.querySql(sql, bindArgs, (err: BusinessError, resultSet: relationalStore.ResultSet) => {
        if (err) {
          reject(err)
          return
        }
        const rows: T[] = []
        if (resultSet.rowCount === 0) {
          resultSet.close()
          resolve(rows)
          return
        }
        resultSet.goToFirstRow()
        do {
          rows.push(mapper(resultSet))
        } while (resultSet.goToNextRow())
        resultSet.close()
        resolve(rows)
      })
    })
  }

  private getString(resultSet: relationalStore.ResultSet, columnName: string): string {
    const index: number = resultSet.getColumnIndex(columnName)
    return index >= 0 ? resultSet.getString(index) : ''
  }

  private getNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    const index: number = resultSet.getColumnIndex(columnName)
    return index >= 0 ? Number(resultSet.getLong(index)) : 0
  }

  private getDouble(resultSet: relationalStore.ResultSet, columnName: string): number {
    const index: number = resultSet.getColumnIndex(columnName)
    return index >= 0 ? resultSet.getDouble(index) : 0
  }
}
