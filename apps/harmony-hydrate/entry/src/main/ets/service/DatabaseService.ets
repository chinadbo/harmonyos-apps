import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { WaterRecord } from '../model/WaterRecord'

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private store?: relationalStore.RdbStore
  private readonly config: relationalStore.StoreConfig = {
    name: 'harmony_hydrate.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return
    }

    try {
      this.store = await relationalStore.getRdbStore(context, this.config)
      await this.store.executeSql('CREATE TABLE IF NOT EXISTS water_records (id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER NOT NULL, timestamp INTEGER NOT NULL, date TEXT NOT NULL)')
    } catch (error) {
      console.error(`Database init failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database not initialized')
    }
    return this.store
  }

  async insertRecord(amount: number, timestamp: number, date: string): Promise<number> {
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        amount,
        timestamp,
        date
      }
      return await this.getStore().insert('water_records', valueBucket)
    } catch (error) {
      console.error(`Insert record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async updateRecord(record: WaterRecord): Promise<void> {
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        amount: record.amount,
        timestamp: record.timestamp,
        date: record.date
      }
      await this.getStore().update(valueBucket, { tableName: 'water_records', whereClause: 'id = ?', whereArgs: [String(record.id)] })
    } catch (error) {
      console.error(`Update record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async deleteRecord(id: number): Promise<void> {
    try {
      await this.getStore().delete({ tableName: 'water_records', whereClause: 'id = ?', whereArgs: [String(id)] })
    } catch (error) {
      console.error(`Delete record failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async clearAllRecords(): Promise<void> {
    try {
      await this.getStore().executeSql('DELETE FROM water_records')
    } catch (error) {
      console.error(`Clear records failed: ${JSON.stringify(error)}`)
      throw error
    }
  }

  async getAllRecords(): Promise<WaterRecord[]> {
    const records: WaterRecord[] = []
    let resultSet: relationalStore.ResultSet | undefined

    try {
      resultSet = await this.getStore().querySql('SELECT id, amount, timestamp, date FROM water_records ORDER BY timestamp DESC')
      while (resultSet.goToNextRow()) {
        records.push(new WaterRecord(
          resultSet.getLong(resultSet.getColumnIndex('id')),
          resultSet.getLong(resultSet.getColumnIndex('amount')),
          resultSet.getLong(resultSet.getColumnIndex('timestamp')),
          resultSet.getString(resultSet.getColumnIndex('date'))
        ))
      }
      return records
    } catch (error) {
      console.error(`Query all records failed: ${JSON.stringify(error)}`)
      throw error
    } finally {
      resultSet?.close()
    }
  }

  async getRecordsByDate(date: string): Promise<WaterRecord[]> {
    const records: WaterRecord[] = []
    let resultSet: relationalStore.ResultSet | undefined

    try {
      resultSet = await this.getStore().querySql('SELECT id, amount, timestamp, date FROM water_records WHERE date = ? ORDER BY timestamp DESC', [date])
      while (resultSet.goToNextRow()) {
        records.push(new WaterRecord(
          resultSet.getLong(resultSet.getColumnIndex('id')),
          resultSet.getLong(resultSet.getColumnIndex('amount')),
          resultSet.getLong(resultSet.getColumnIndex('timestamp')),
          resultSet.getString(resultSet.getColumnIndex('date'))
        ))
      }
      return records
    } catch (error) {
      console.error(`Query records by date failed: ${JSON.stringify(error)}`)
      throw error
    } finally {
      resultSet?.close()
    }
  }

  async getDailySum(date: string): Promise<number> {
    let resultSet: relationalStore.ResultSet | undefined

    try {
      resultSet = await this.getStore().querySql('SELECT COALESCE(SUM(amount), 0) AS total FROM water_records WHERE date = ?', [date])
      if (resultSet.goToFirstRow()) {
        return resultSet.getLong(resultSet.getColumnIndex('total'))
      }
      return 0
    } catch (error) {
      console.error(`Get daily sum failed: ${JSON.stringify(error)}`)
      throw error
    } finally {
      resultSet?.close()
    }
  }
}
