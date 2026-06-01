import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import DatabaseHelper from './DatabaseHelper'
import { Item, CategoryItemGroup, createItemRow } from '../model/Item'
import { CATEGORY_OPTIONS } from '../model/Constants'

export interface MissedItemStat {
  name: string
  missedCount: number
}

export default class ItemDao {
  private static tableName: string = 'items'

  static async save(context: common.Context, item: Item): Promise<number> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    item.updatedAt = Date.now()
    if (item.id > 0) {
      const predicates = new relationalStore.RdbPredicates(ItemDao.tableName)
      predicates.equalTo('id', item.id)
      await store.update(createItemRow(item) as relationalStore.ValuesBucket, predicates)
      return item.id
    }
    item.createdAt = Date.now()
    const values = createItemRow(item) as relationalStore.ValuesBucket
    delete (values as Record<string, number | string>).id
    return await store.insert(ItemDao.tableName, values)
  }

  static async findById(context: common.Context, itemId: number): Promise<Item | null> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`SELECT * FROM items WHERE id = ${itemId} LIMIT 1`)
    const item = ItemDao.readSingle(resultSet)
    resultSet.close()
    return item
  }

  static async listByTripId(context: common.Context, tripId: number): Promise<Item[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`SELECT * FROM items WHERE trip_id = ${tripId} ORDER BY sort_order ASC, id ASC`)
    const list = ItemDao.readList(resultSet)
    resultSet.close()
    return list
  }

  static async listByTripAndCategory(context: common.Context, tripId: number, category: string): Promise<Item[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`SELECT * FROM items WHERE trip_id = ${tripId} AND category = '${category}' ORDER BY sort_order ASC, id ASC`)
    const list = ItemDao.readList(resultSet)
    resultSet.close()
    return list
  }

  static async listGroupedByCategory(context: common.Context, tripId: number): Promise<CategoryItemGroup[]> {
    const items = await ItemDao.listByTripId(context, tripId)
    const groups: CategoryItemGroup[] = []
    CATEGORY_OPTIONS.forEach((option: { value: string; label: string }) => {
      const categoryItems = items.filter((item: Item) => item.category === option.value)
      if (categoryItems.length > 0) {
        groups.push({ category: option.value, items: categoryItems })
      }
    })
    const remainingItems = items.filter((item: Item) => !CATEGORY_OPTIONS.some((option: { value: string; label: string }) => option.value === item.category))
    if (remainingItems.length > 0) {
      groups.push({ category: 'other', items: remainingItems })
    }
    return groups
  }

  static async delete(context: common.Context, itemId: number): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const predicates = new relationalStore.RdbPredicates(ItemDao.tableName)
    predicates.equalTo('id', itemId)
    await store.delete(predicates)
  }

  static async togglePacked(context: common.Context, itemId: number, isPacked: boolean): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const predicates = new relationalStore.RdbPredicates(ItemDao.tableName)
    predicates.equalTo('id', itemId)
    await store.update({
      is_packed: isPacked ? 1 : 0,
      updated_at: Date.now()
    } as relationalStore.ValuesBucket, predicates)
  }

  static async markUnpackedAsMissed(context: common.Context, tripId: number): Promise<void> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    await store.executeSql(`UPDATE items SET is_missed = CASE WHEN is_packed = 0 THEN 1 ELSE is_missed END, updated_at = ${Date.now()} WHERE trip_id = ${tripId}`)
  }

  static async getTripProgress(context: common.Context, tripId: number): Promise<{ total: number; packed: number; progress: number }> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`
      SELECT COUNT(id) AS total_count, SUM(CASE WHEN is_packed = 1 THEN 1 ELSE 0 END) AS packed_count
      FROM items
      WHERE trip_id = ${tripId}
    `)
    const total = ItemDao.readNumber(resultSet, 'total_count')
    const packed = ItemDao.readNumber(resultSet, 'packed_count')
    resultSet.close()
    return {
      total: total,
      packed: packed,
      progress: total === 0 ? 0 : Math.round((packed / total) * 100)
    }
  }

  static async listMissedTop5(context: common.Context): Promise<MissedItemStat[]> {
    const store = await DatabaseHelper.getInstance().getStore(context)
    const resultSet = await store.querySql(`
      SELECT name, COUNT(id) AS missed_count
      FROM items
      WHERE is_missed = 1
      GROUP BY name
      ORDER BY missed_count DESC, name ASC
      LIMIT 5
    `)
    const list: MissedItemStat[] = []
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow()
      do {
        list.push({
          name: ItemDao.getString(resultSet, 'name'),
          missedCount: ItemDao.getNumber(resultSet, 'missed_count')
        })
      } while (resultSet.goToNextRow())
    }
    resultSet.close()
    return list
  }

  private static readList(resultSet: relationalStore.ResultSet): Item[] {
    const list: Item[] = []
    if (resultSet.rowCount === 0) {
      return list
    }
    resultSet.goToFirstRow()
    do {
      list.push(ItemDao.readItem(resultSet))
    } while (resultSet.goToNextRow())
    return list
  }

  private static readSingle(resultSet: relationalStore.ResultSet): Item | null {
    if (resultSet.rowCount === 0) {
      return null
    }
    resultSet.goToFirstRow()
    return ItemDao.readItem(resultSet)
  }

  private static readItem(resultSet: relationalStore.ResultSet): Item {
    return new Item({
      id: ItemDao.getNumber(resultSet, 'id'),
      tripId: ItemDao.getNumber(resultSet, 'trip_id'),
      templateId: ItemDao.getString(resultSet, 'template_id'),
      name: ItemDao.getString(resultSet, 'name'),
      category: ItemDao.getString(resultSet, 'category'),
      quantity: ItemDao.getNumber(resultSet, 'quantity'),
      importance: ItemDao.getNumber(resultSet, 'importance'),
      note: ItemDao.getString(resultSet, 'note'),
      isPacked: ItemDao.getNumber(resultSet, 'is_packed') === 1,
      isMissed: ItemDao.getNumber(resultSet, 'is_missed') === 1,
      sortOrder: ItemDao.getNumber(resultSet, 'sort_order'),
      createdAt: ItemDao.getNumber(resultSet, 'created_at'),
      updatedAt: ItemDao.getNumber(resultSet, 'updated_at')
    })
  }

  private static readNumber(resultSet: relationalStore.ResultSet, columnName: string): number {
    if (resultSet.rowCount === 0) {
      return 0
    }
    resultSet.goToFirstRow()
    return ItemDao.getNumber(resultSet, columnName)
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
