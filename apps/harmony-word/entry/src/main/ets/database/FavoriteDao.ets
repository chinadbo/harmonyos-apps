import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'

export interface FavoriteEntry {
  id: number
  entryId: number
  entryType: string
  word: string
  pinyin: string
  definition: string
  groupName: string
  createdAt: string
}

export class FavoriteDao {
  async list(groupName: string): Promise<FavoriteEntry[]> {
    const store = DatabaseHelper.getStore()
    const predicates = new relationalStore.RdbPredicates('FAVORITES')
    if (groupName) {
      predicates.equalTo('group_name', groupName)
    }
    predicates.orderByDesc('created_at')
    const resultSet = await store.query(predicates)
    const list: FavoriteEntry[] = []
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          entryId: resultSet.getLong(resultSet.getColumnIndex('entry_id')),
          entryType: resultSet.getString(resultSet.getColumnIndex('entry_type')),
          word: resultSet.getString(resultSet.getColumnIndex('word')),
          pinyin: resultSet.getString(resultSet.getColumnIndex('pinyin')),
          definition: resultSet.getString(resultSet.getColumnIndex('definition')),
          groupName: resultSet.getString(resultSet.getColumnIndex('group_name')),
          createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
        })
      } while (resultSet.goToNextRow())
    }
    resultSet.close()
    return list
  }

  async isFavorite(entryId: number, entryType: string): Promise<boolean> {
    const store = DatabaseHelper.getStore()
    const predicates = new relationalStore.RdbPredicates('FAVORITES')
    predicates.equalTo('entry_id', entryId).equalTo('entry_type', entryType)
    const resultSet = await store.query(predicates)
    const hasFavorite = resultSet.rowCount > 0
    resultSet.close()
    return hasFavorite
  }

  async save(entryId: number, entryType: string, word: string, pinyin: string, definition: string, groupName: string, createdAt: string): Promise<void> {
    const store = DatabaseHelper.getStore()
    await store.insert('FAVORITES', {
      entry_id: entryId,
      entry_type: entryType,
      word,
      pinyin,
      definition,
      group_name: groupName,
      created_at: createdAt
    })
  }

  async remove(entryId: number, entryType: string): Promise<void> {
    const store = DatabaseHelper.getStore()
    const predicates = new relationalStore.RdbPredicates('FAVORITES')
    predicates.equalTo('entry_id', entryId).equalTo('entry_type', entryType)
    await store.delete(predicates)
  }
}
