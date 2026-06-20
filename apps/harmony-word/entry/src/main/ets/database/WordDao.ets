import relationalStore from '@ohos.data.relationalStore'
import { DatabaseHelper } from './DatabaseHelper'
import { WordEntry } from '../model/WordEntry'
import { IdiomEntry } from '../model/IdiomEntry'

export interface SearchResultEntry {
  id: number
  word: string
  pinyin: string
  definition: string
  groupName: string
  entryType: string
}

export class WordDao {
  private readonly store: relationalStore.RdbStore

  constructor() {
    this.store = DatabaseHelper.getStore()
  }

  async searchWords(keyword: string): Promise<WordEntry[]> {
    const safeKeyword = `%${keyword.trim()}%`
    const predicates = new relationalStore.RdbPredicates('WORDS')
    if (keyword.trim().length > 0) {
      predicates.beginWrap()
        .like('word', safeKeyword)
        .or()
        .like('pinyin', safeKeyword)
        .or()
        .like('definition', safeKeyword)
        .endWrap()
    }
    predicates.orderByDesc('is_recommended').orderByAsc('id').limitAs(20)
    const resultSet = await this.store.query(predicates)
    return this.mapWords(resultSet)
  }

  async searchIdioms(keyword: string): Promise<IdiomEntry[]> {
    const safeKeyword = `%${keyword.trim()}%`
    const predicates = new relationalStore.RdbPredicates('IDIOMS')
    if (keyword.trim().length > 0) {
      predicates.beginWrap()
        .like('word', safeKeyword)
        .or()
        .like('pinyin', safeKeyword)
        .or()
        .like('summary', safeKeyword)
        .endWrap()
    }
    predicates.orderByAsc('initial').orderByAsc('id').limitAs(30)
    const resultSet = await this.store.query(predicates)
    return this.mapIdioms(resultSet)
  }

  async getWordById(id: number): Promise<WordEntry | null> {
    const predicates = new relationalStore.RdbPredicates('WORDS')
    predicates.equalTo('id', id).limitAs(1)
    const resultSet = await this.store.query(predicates)
    const list = await this.mapWords(resultSet)
    return list.length > 0 ? list[0] : null
  }

  async getIdiomById(id: number): Promise<IdiomEntry | null> {
    const predicates = new relationalStore.RdbPredicates('IDIOMS')
    predicates.equalTo('id', id).limitAs(1)
    const resultSet = await this.store.query(predicates)
    const list = await this.mapIdioms(resultSet)
    return list.length > 0 ? list[0] : null
  }

  async getRecommendedWord(): Promise<WordEntry | null> {
    const words = await this.searchWords('')
    if (words.length === 0) {
      return null
    }
    const dayIndex = new Date().getDate() % words.length
    return words[dayIndex]
  }

  async getIdiomSections(keyword: string, initial: string): Promise<IdiomEntry[]> {
    const idioms = await this.searchIdioms(keyword)
    if (!initial) {
      return idioms
    }
    return idioms.filter((item: IdiomEntry) => item.initial === initial)
  }

  async getHomeResults(keyword: string): Promise<SearchResultEntry[]> {
    const words = await this.searchWords(keyword)
    const idioms = await this.searchIdioms(keyword)
    const wordResults = words.map((item: WordEntry) => ({
      id: item.id,
      word: item.word,
      pinyin: item.pinyin,
      definition: item.definition,
      groupName: item.groupName,
      entryType: 'word'
    }))
    const idiomResults = idioms.slice(0, 10).map((item: IdiomEntry) => ({
      id: item.id,
      word: item.word,
      pinyin: item.pinyin,
      definition: item.summary,
      groupName: '成语',
      entryType: 'idiom'
    }))
    return [...wordResults, ...idiomResults].slice(0, 20)
  }

  private async mapWords(resultSet: relationalStore.ResultSet): Promise<WordEntry[]> {
    const list: WordEntry[] = []
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          word: resultSet.getString(resultSet.getColumnIndex('word')),
          pinyin: resultSet.getString(resultSet.getColumnIndex('pinyin')),
          definition: resultSet.getString(resultSet.getColumnIndex('definition')),
          example: resultSet.getString(resultSet.getColumnIndex('example')),
          synonyms: resultSet.getString(resultSet.getColumnIndex('synonyms')),
          antonyms: resultSet.getString(resultSet.getColumnIndex('antonyms')),
          groupName: resultSet.getString(resultSet.getColumnIndex('group_name')),
          strokes: resultSet.getLong(resultSet.getColumnIndex('strokes')),
          radical: resultSet.getString(resultSet.getColumnIndex('radical')),
          isRecommended: resultSet.getLong(resultSet.getColumnIndex('is_recommended'))
        })
      } while (resultSet.goToNextRow())
    }
    resultSet.close()
    return list
  }

  private async mapIdioms(resultSet: relationalStore.ResultSet): Promise<IdiomEntry[]> {
    const list: IdiomEntry[] = []
    if (resultSet.goToFirstRow()) {
      do {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          word: resultSet.getString(resultSet.getColumnIndex('word')),
          pinyin: resultSet.getString(resultSet.getColumnIndex('pinyin')),
          summary: resultSet.getString(resultSet.getColumnIndex('summary')),
          story: resultSet.getString(resultSet.getColumnIndex('story')),
          derivation: resultSet.getString(resultSet.getColumnIndex('derivation')),
          sample: resultSet.getString(resultSet.getColumnIndex('sample')),
          initial: resultSet.getString(resultSet.getColumnIndex('initial'))
        })
      } while (resultSet.goToNextRow())
    }
    resultSet.close()
    return list
  }
}
