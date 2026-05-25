import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { SpeedRecord } from '../model/SpeedRecord'

const DB_NAME = 'speed_test.db'
const TABLE_NAME = 'speed_records'
const MAX_RECORDS = 100

const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER NOT NULL,
  download_speed REAL NOT NULL,
  upload_speed REAL NOT NULL,
  ping INTEGER NOT NULL,
  jitter INTEGER NOT NULL,
  network_type TEXT NOT NULL,
  server_host TEXT NOT NULL
)`

let rdbStore: relationalStore.RdbStore | null = null

export class SpeedDatabase {
  async init(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    rdbStore = await relationalStore.getRdbStore(context, config)
    await rdbStore.executeSql(SQL_CREATE_TABLE)
  }

  async insertRecord(record: SpeedRecord): Promise<void> {
    if (!rdbStore) { return }
    const values: relationalStore.ValuesBucket = {
      timestamp: record.timestamp,
      download_speed: record.downloadSpeed,
      upload_speed: record.uploadSpeed,
      ping: record.ping,
      jitter: record.jitter,
      network_type: record.networkType,
      server_host: record.serverHost
    }
    await rdbStore.insert(TABLE_NAME, values)
    await this.deleteOldest()
  }

  async queryRecords(limit: number = 20): Promise<SpeedRecord[]> {
    if (!rdbStore) { return [] }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    predicates.orderByDesc('timestamp')
    predicates.limitAs(limit)
    const cursor = await rdbStore.query(predicates, [
      'id', 'timestamp', 'download_speed', 'upload_speed',
      'ping', 'jitter', 'network_type', 'server_host'
    ])
    const records: SpeedRecord[] = []
    while (cursor.goToNextRow()) {
      records.push({
        id: cursor.getLong(cursor.getColumnIndex('id')),
        timestamp: cursor.getLong(cursor.getColumnIndex('timestamp')),
        downloadSpeed: cursor.getDouble(cursor.getColumnIndex('download_speed')),
        uploadSpeed: cursor.getDouble(cursor.getColumnIndex('upload_speed')),
        ping: cursor.getLong(cursor.getColumnIndex('ping')),
        jitter: cursor.getLong(cursor.getColumnIndex('jitter')),
        networkType: cursor.getString(cursor.getColumnIndex('network_type')),
        serverHost: cursor.getString(cursor.getColumnIndex('server_host'))
      })
    }
    cursor.close()
    return records
  }

  async deleteAll(): Promise<void> {
    if (!rdbStore) { return }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    await rdbStore.delete(predicates)
  }

  private async deleteOldest(): Promise<void> {
    if (!rdbStore) { return }
    // Count rows
    const countPred = new relationalStore.RdbPredicates(TABLE_NAME)
    const cursor = await rdbStore.query(countPred, ['id'])
    let count = 0
    while (cursor.goToNextRow()) { count++ }
    cursor.close()

    if (count > MAX_RECORDS) {
      // Delete oldest (lowest timestamp)
      const deleteSql = `DELETE FROM ${TABLE_NAME} WHERE id IN (SELECT id FROM ${TABLE_NAME} ORDER BY timestamp ASC LIMIT ${count - MAX_RECORDS})`
      await rdbStore.executeSql(deleteSql)
    }
  }
}

export const speedDb = new SpeedDatabase()
