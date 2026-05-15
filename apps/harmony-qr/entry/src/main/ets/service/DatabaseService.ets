import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { QRRecord, QRRecordType } from '../model/QRRecord'
import { DB_NAME, TABLE_NAME } from '../utils/Constants'

type UIAbilityContext = common.UIAbilityContext

export class DatabaseService {
  private static instance: DatabaseService = new DatabaseService()
  private store?: relationalStore.RdbStore
  private initializing?: Promise<void>

  private constructor() {
  }

  static getInstance(): DatabaseService {
    return DatabaseService.instance
  }

  async init(context: UIAbilityContext): Promise<void> {
    if (this.store) {
      return
    }
    if (this.initializing) {
      return this.initializing
    }
    this.initializing = this.createStore(context)
    await this.initializing
    this.initializing = undefined
  }

  private async createStore(context: UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.store = await relationalStore.getRdbStore(context, config)
    await this.store.executeSql(
      `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (` +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'type TEXT NOT NULL, ' +
      'content TEXT NOT NULL, ' +
      'contentType TEXT DEFAULT \'text\', ' +
      'color TEXT DEFAULT \'#000000\', ' +
      'bgColor TEXT DEFAULT \'#FFFFFF\', ' +
      'isFavorite INTEGER DEFAULT 0, ' +
      'createdAt INTEGER NOT NULL)'
    )
  }

  async insert(record: QRRecord): Promise<number> {
    const store = this.getStore()
    const values: relationalStore.ValuesBucket = {
      type: record.type,
      content: record.content,
      contentType: record.contentType,
      color: record.color,
      bgColor: record.bgColor,
      isFavorite: record.isFavorite,
      createdAt: record.createdAt
    }
    return Number(await store.insert(TABLE_NAME, values))
  }

  async queryByType(type: QRRecordType): Promise<QRRecord[]> {
    return this.queryRecords(`SELECT * FROM ${TABLE_NAME} WHERE type = ? ORDER BY createdAt DESC`, [type])
  }

  async queryFavorites(): Promise<QRRecord[]> {
    return this.queryRecords(`SELECT * FROM ${TABLE_NAME} WHERE isFavorite = 1 ORDER BY createdAt DESC`, [])
  }

  async search(keyword: string, type?: string, favoriteOnly: boolean = false): Promise<QRRecord[]> {
    const conditions: string[] = []
    const args: relationalStore.ValueType[] = []
    if (keyword.trim().length > 0) {
      conditions.push('content LIKE ?')
      args.push(`%${keyword.trim()}%`)
    }
    if (type) {
      conditions.push('type = ?')
      args.push(type)
    }
    if (favoriteOnly) {
      conditions.push('isFavorite = 1')
    }
    const whereClause = conditions.length > 0 ? ` WHERE ${conditions.join(' AND ')}` : ''
    return this.queryRecords(`SELECT * FROM ${TABLE_NAME}${whereClause} ORDER BY createdAt DESC`, args)
  }

  async delete(id: number): Promise<void> {
    const store = this.getStore()
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    predicates.equalTo('id', id)
    await store.delete(predicates)
  }

  async toggleFavorite(id: number, isFavorite: boolean): Promise<void> {
    const store = this.getStore()
    const values: relationalStore.ValuesBucket = {
      isFavorite: isFavorite ? 1 : 0
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME)
    predicates.equalTo('id', id)
    await store.update(values, predicates)
  }

  async close(): Promise<void> {
    if (this.store) {
      await this.store.close()
      this.store = undefined
    }
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('DatabaseService is not initialized')
    }
    return this.store
  }

  private async queryRecords(sql: string, args: relationalStore.ValueType[]): Promise<QRRecord[]> {
    const store = this.getStore()
    const resultSet = await store.querySql(sql, args)
    const records: QRRecord[] = []
    try {
      while (resultSet.goToNextRow()) {
        records.push(new QRRecord({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          type: resultSet.getString(resultSet.getColumnIndex('type')) as QRRecordType,
          content: resultSet.getString(resultSet.getColumnIndex('content')),
          contentType: resultSet.getString(resultSet.getColumnIndex('contentType')) as QRRecord['contentType'],
          color: resultSet.getString(resultSet.getColumnIndex('color')),
          bgColor: resultSet.getString(resultSet.getColumnIndex('bgColor')),
          isFavorite: resultSet.getLong(resultSet.getColumnIndex('isFavorite')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
        }))
      }
    } finally {
      resultSet.close()
    }
    return records
  }
}

export default DatabaseService.getInstance()
