import { WordEntry } from '../model/WordEntry'
import { WordDao, SearchResultEntry } from '../database/WordDao'

export class SearchService {
  private readonly wordDao: WordDao = new WordDao()

  async search(keyword: string): Promise<SearchResultEntry[]> {
    return this.wordDao.getHomeResults(keyword)
  }

  async getTodayWord(): Promise<WordEntry | null> {
    return this.wordDao.getRecommendedWord()
  }
}
