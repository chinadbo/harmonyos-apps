import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { Clothing, Outfit, OutfitLog } from '../model/WardrobeModels'

const SQL_CREATE_CLOTHING: string = `CREATE TABLE IF NOT EXISTS clothing (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  color_name TEXT NOT NULL DEFAULT '',
  season TEXT NOT NULL DEFAULT '四季',
  image_path TEXT NOT NULL DEFAULT '',
  favorite INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
)`

const SQL_CREATE_OUTFIT: string = `CREATE TABLE IF NOT EXISTS outfit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  top_id INTEGER NOT NULL DEFAULT -1,
  bottom_id INTEGER NOT NULL DEFAULT -1,
  outer_id INTEGER NOT NULL DEFAULT -1,
  shoes_id INTEGER NOT NULL DEFAULT -1,
  accessory_id INTEGER NOT NULL DEFAULT -1,
  created_at INTEGER NOT NULL
)`

const SQL_CREATE_OUTFIT_LOG: string = `CREATE TABLE IF NOT EXISTS outfit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  outfit_id INTEGER NOT NULL,
  log_date TEXT NOT NULL,
  created_at INTEGER NOT NULL
)`

export class WardrobeDb {
  private static instance: WardrobeDb | null = null
  private store: relationalStore.RdbStore | null = null
  private readyPromise: Promise<void> | null = null

  static getInstance(): WardrobeDb {
    let inst = WardrobeDb.instance
    if (inst === null) {
      inst = new WardrobeDb()
      WardrobeDb.instance = inst
    }
    return inst
  }

  init(context: common.Context): Promise<void> {
    if (this.readyPromise === null) {
      this.readyPromise = this.doInit(context)
    }
    return this.readyPromise
  }

  private async doInit(context: common.Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: 'wardrobe.db',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    const store = await relationalStore.getRdbStore(context, config)
    await store.executeSql(SQL_CREATE_CLOTHING)
    await store.executeSql(SQL_CREATE_OUTFIT)
    await store.executeSql(SQL_CREATE_OUTFIT_LOG)
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_log_date ON outfit_log(log_date)')
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_log_outfit ON outfit_log(outfit_id)')
    this.store = store
  }

  private async waitReady(): Promise<void> {
    if (this.readyPromise !== null) {
      await this.readyPromise
    }
  }

  async insertClothing(clothing: Clothing): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return -1
    }
    const bucket: relationalStore.ValuesBucket = {
      'name': clothing.name,
      'category': clothing.category,
      'color_name': clothing.colorName,
      'season': clothing.season,
      'image_path': clothing.imagePath,
      'favorite': clothing.favorite ? 1 : 0,
      'created_at': clothing.createdAt
    }
    return this.store.insert('clothing', bucket)
  }

  async updateClothing(clothing: Clothing): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return 0
    }
    const bucket: relationalStore.ValuesBucket = {
      'name': clothing.name,
      'category': clothing.category,
      'color_name': clothing.colorName,
      'season': clothing.season,
      'image_path': clothing.imagePath,
      'favorite': clothing.favorite ? 1 : 0
    }
    const predicates = new relationalStore.RdbPredicates('clothing')
    predicates.equalTo('id', clothing.id)
    return this.store.update(bucket, predicates)
  }

  async deleteClothing(id: number): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return 0
    }
    const predicates = new relationalStore.RdbPredicates('clothing')
    predicates.equalTo('id', id)
    return this.store.delete(predicates)
  }

  async queryClothing(category: string): Promise<Clothing[]> {
    await this.waitReady()
    const list: Clothing[] = []
    if (this.store === null) {
      return list
    }
    const predicates = new relationalStore.RdbPredicates('clothing')
    if (category !== '') {
      predicates.equalTo('category', category)
    }
    predicates.orderByDesc('created_at')
    const rs = await this.store.query(predicates)
    while (rs.goToNextRow()) {
      list.push(this.rowToClothing(rs))
    }
    rs.close()
    return list
  }

  async getClothingById(id: number): Promise<Clothing | null> {
    await this.waitReady()
    if (this.store === null) {
      return null
    }
    const predicates = new relationalStore.RdbPredicates('clothing')
    predicates.equalTo('id', id)
    const rs = await this.store.query(predicates)
    let result: Clothing | null = null
    if (rs.goToNextRow()) {
      result = this.rowToClothing(rs)
    }
    rs.close()
    return result
  }

  private rowToClothing(rs: relationalStore.ResultSet): Clothing {
    return new Clothing(
      rs.getLong(rs.getColumnIndex('id')),
      rs.getString(rs.getColumnIndex('name')),
      rs.getString(rs.getColumnIndex('category')),
      rs.getString(rs.getColumnIndex('color_name')),
      rs.getString(rs.getColumnIndex('season')),
      rs.getString(rs.getColumnIndex('image_path')),
      rs.getLong(rs.getColumnIndex('favorite')) === 1,
      rs.getLong(rs.getColumnIndex('created_at'))
    )
  }

  async insertOutfit(outfit: Outfit): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return -1
    }
    const bucket: relationalStore.ValuesBucket = {
      'name': outfit.name,
      'top_id': outfit.topId,
      'bottom_id': outfit.bottomId,
      'outer_id': outfit.outerId,
      'shoes_id': outfit.shoesId,
      'accessory_id': outfit.accessoryId,
      'created_at': outfit.createdAt
    }
    return this.store.insert('outfit', bucket)
  }

  async deleteOutfit(id: number): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return 0
    }
    const logPredicates = new relationalStore.RdbPredicates('outfit_log')
    logPredicates.equalTo('outfit_id', id)
    await this.store.delete(logPredicates)
    const predicates = new relationalStore.RdbPredicates('outfit')
    predicates.equalTo('id', id)
    return this.store.delete(predicates)
  }

  async queryOutfits(): Promise<Outfit[]> {
    await this.waitReady()
    const list: Outfit[] = []
    if (this.store === null) {
      return list
    }
    const predicates = new relationalStore.RdbPredicates('outfit')
    predicates.orderByDesc('created_at')
    const rs = await this.store.query(predicates)
    while (rs.goToNextRow()) {
      list.push(this.rowToOutfit(rs))
    }
    rs.close()
    return list
  }

  async getOutfitById(id: number): Promise<Outfit | null> {
    await this.waitReady()
    if (this.store === null) {
      return null
    }
    const predicates = new relationalStore.RdbPredicates('outfit')
    predicates.equalTo('id', id)
    const rs = await this.store.query(predicates)
    let result: Outfit | null = null
    if (rs.goToNextRow()) {
      result = this.rowToOutfit(rs)
    }
    rs.close()
    return result
  }

  private rowToOutfit(rs: relationalStore.ResultSet): Outfit {
    return new Outfit(
      rs.getLong(rs.getColumnIndex('id')),
      rs.getString(rs.getColumnIndex('name')),
      rs.getLong(rs.getColumnIndex('top_id')),
      rs.getLong(rs.getColumnIndex('bottom_id')),
      rs.getLong(rs.getColumnIndex('outer_id')),
      rs.getLong(rs.getColumnIndex('shoes_id')),
      rs.getLong(rs.getColumnIndex('accessory_id')),
      rs.getLong(rs.getColumnIndex('created_at'))
    )
  }

  async insertLog(outfitId: number, logDate: string): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return -1
    }
    await this.deleteLogByDate(logDate)
    const bucket: relationalStore.ValuesBucket = {
      'outfit_id': outfitId,
      'log_date': logDate,
      'created_at': Date.now()
    }
    return this.store.insert('outfit_log', bucket)
  }

  async deleteLogByDate(logDate: string): Promise<number> {
    await this.waitReady()
    if (this.store === null) {
      return 0
    }
    const predicates = new relationalStore.RdbPredicates('outfit_log')
    predicates.equalTo('log_date', logDate)
    return this.store.delete(predicates)
  }

  async queryLogsBetween(startDate: string, endDate: string): Promise<OutfitLog[]> {
    await this.waitReady()
    const list: OutfitLog[] = []
    if (this.store === null) {
      return list
    }
    const predicates = new relationalStore.RdbPredicates('outfit_log')
    predicates.between('log_date', startDate, endDate)
    predicates.orderByAsc('log_date')
    const rs = await this.store.query(predicates)
    while (rs.goToNextRow()) {
      list.push(this.rowToLog(rs))
    }
    rs.close()
    return list
  }

  async queryLogsByOutfit(outfitId: number): Promise<OutfitLog[]> {
    await this.waitReady()
    const list: OutfitLog[] = []
    if (this.store === null) {
      return list
    }
    const predicates = new relationalStore.RdbPredicates('outfit_log')
    predicates.equalTo('outfit_id', outfitId)
    predicates.orderByDesc('log_date')
    const rs = await this.store.query(predicates)
    while (rs.goToNextRow()) {
      list.push(this.rowToLog(rs))
    }
    rs.close()
    return list
  }

  async queryWearCounts(): Promise<Map<number, number>> {
    await this.waitReady()
    const map = new Map<number, number>()
    if (this.store === null) {
      return map
    }
    const rs = await this.store.querySql('SELECT outfit_id, COUNT(*) AS cnt FROM outfit_log GROUP BY outfit_id ORDER BY cnt DESC')
    while (rs.goToNextRow()) {
      map.set(rs.getLong(rs.getColumnIndex('outfit_id')), rs.getLong(rs.getColumnIndex('cnt')))
    }
    rs.close()
    return map
  }

  private rowToLog(rs: relationalStore.ResultSet): OutfitLog {
    return new OutfitLog(
      rs.getLong(rs.getColumnIndex('id')),
      rs.getLong(rs.getColumnIndex('outfit_id')),
      rs.getString(rs.getColumnIndex('log_date')),
      rs.getLong(rs.getColumnIndex('created_at'))
    )
  }
}
