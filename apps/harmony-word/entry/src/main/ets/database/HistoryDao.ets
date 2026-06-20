import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import { HistoryEntry } from '../model/WordEntry'

export interface HistoryListEntry extends HistoryEntry {
  entryType: string
}

export class HistoryDao {
  async save(entryId: number, entryType: string, word: string, pinyin: string, definition: string, queryText: string, createdAt: string): Promise<void> {
    const store = DatabaseHelper.getStore()
    const removePredicates = new relationalStore.RdbPredicates('HISTORY')
    removePredicates.equalTo('entry_id', entryId).equalTo('entry_type', entryType)
    await store.delete(removePredicates)
    await store.insert('HISTORY', {
      entry_id: entryId,
      entry_type: entryType,
      word,
      pinyin,
      definition,
      query_text: queryText,
      created_at: createdAt
    })

    const allPredicates = new relationalStore.RdbPredicates('HISTORY')
    allPredicates.orderByDesc('created_at')
    const allResultSet = await store.query(allPredicates)
    const keepIds: string[] = []
    if (allResultSet.goToFirstRow()) {
      do {
        if (keepIds.length < 50) {
          keepIds.push(`${allResultSet.getLong(allResultSet.getColumnIndex('id'))}`)
        }
      } while (allResultSet.goToNextRow())
    }
    allResultSet.close()

    if (keepIds.length > 0) {
      const trimPredicates = new relationalStore.RdbPredicates('HISTORY')
      trimPredicates.notIn('id', keepIds)
      await store.delete(trimPredicates)
    }
  }

  async listRecent(): Promise<HistoryListEntry[]> {
    const store = DatabaseHelper.getStore()
    const predicates = new relationalStore.RdbPredicates('HISTORY')
    predicates.orderByDesc('created_at').limitAs(50)
    const resultSet = await store.query(predicates)
    const list: HistoryListEntry[] = []
    if (resultSet.goToFirstRow()) {
      do {
        const entryType = resultSet.getString(resultSet.getColumnIndex('entry_type'))
        list.push({
          historyId: resultSet.getLong(resultSet.getColumnIndex('id')),
          id: resultSet.getLong(resultSet.getColumnIndex('entry_id')),
          entryType,
          word: resultSet.getString(resultSet.getColumnIndex('word')),
          pinyin: resultSet.getString(resultSet.getColumnIndex('pinyin')),
          definition: resultSet.getString(resultSet.getColumnIndex('definition')),
          example: '',
          synonyms: '',
          antonyms: '',
          groupName: entryType === 'idiom' ? '成语' : '默认',
          strokes: 0,
          radical: '',
          isRecommended: 0,
          queryText: resultSet.getString(resultSet.getColumnIndex('query_text')),
          createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
        })
      } while (resultSet.goToNextRow())
    }
    resultSet.close()
    return list
  }
}
