import router from '@ohos.router'
import { FavoriteDao } from '../database/FavoriteDao'
import { HistoryDao } from '../database/HistoryDao'
import { WordDao } from '../database/WordDao'
import { StrokeCanvas } from '../components/StrokeCanvas'
import { DateUtil } from '../utils/DateUtil'
import { WordEntry } from '../model/WordEntry'
import { IdiomEntry } from '../model/IdiomEntry'

@Entry
@Component
export struct DetailPage {
  @State private entryType: string = 'word'
  @State private queryText: string = ''
  @State private wordEntry: WordEntry | null = null
  @State private idiomEntry: IdiomEntry | null = null
  @State private isFavorite: boolean = false
  private readonly wordDao: WordDao = new WordDao()
  private readonly favoriteDao: FavoriteDao = new FavoriteDao()
  private readonly historyDao: HistoryDao = new HistoryDao()

  async aboutToAppear(): Promise<void> {
    const params = router.getParams()
    const id = Number(params && params['id'] ? params['id'] : 0)
    this.entryType = `${params && params['type'] ? params['type'] : 'word'}`
    this.queryText = `${params && params['queryText'] ? params['queryText'] : ''}`
    if (this.entryType === 'idiom') {
      this.idiomEntry = await this.wordDao.getIdiomById(id)
    } else {
      this.wordEntry = await this.wordDao.getWordById(id)
    }
    this.isFavorite = await this.favoriteDao.isFavorite(id, this.entryType)
    await this.recordHistory(id)
  }

  private async recordHistory(id: number): Promise<void> {
    if (this.entryType === 'idiom' && this.idiomEntry) {
      await this.historyDao.save(id, 'idiom', this.idiomEntry.word, this.idiomEntry.pinyin, this.idiomEntry.summary, this.queryText || this.idiomEntry.word, DateUtil.now())
      return
    }
    if (this.wordEntry) {
      await this.historyDao.save(id, 'word', this.wordEntry.word, this.wordEntry.pinyin, this.wordEntry.definition, this.queryText || this.wordEntry.word, DateUtil.now())
    }
  }

  private async toggleFavorite(): Promise<void> {
    const id = this.entryType === 'idiom' ? this.idiomEntry?.id || 0 : this.wordEntry?.id || 0
    if (id === 0) {
      return
    }
    if (this.isFavorite) {
      await this.favoriteDao.remove(id, this.entryType)
      this.isFavorite = false
      return
    }
    const word = this.entryType === 'idiom' ? this.idiomEntry?.word || '' : this.wordEntry?.word || ''
    const pinyin = this.entryType === 'idiom' ? this.idiomEntry?.pinyin || '' : this.wordEntry?.pinyin || ''
    const definition = this.entryType === 'idiom' ? this.idiomEntry?.summary || '' : this.wordEntry?.definition || ''
    const groupName = this.entryType === 'idiom' ? '成语' : this.wordEntry?.groupName || '默认'
    await this.favoriteDao.save(id, this.entryType, word, pinyin, definition, groupName, DateUtil.now())
    this.isFavorite = true
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (this.entryType === 'idiom' && this.idiomEntry) {
          Text(this.idiomEntry.word)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .width('100%')
          Text(this.idiomEntry.pinyin)
            .fontSize(16)
            .fontColor('#6B7280')
            .width('100%')
          Button(this.isFavorite ? '取消收藏' : '加入收藏')
            .backgroundColor(this.isFavorite ? '#F97316' : '#2563EB')
            .onClick(() => this.toggleFavorite())
          Column({ space: 12 }) {
            Text('释义')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.idiomEntry.summary)
              .fontSize(15)
              .lineHeight(24)
            Text('典故')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.idiomEntry.story)
              .fontSize(15)
              .lineHeight(24)
            Text('出处')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.idiomEntry.derivation)
              .fontSize(15)
              .lineHeight(24)
            Text('例句')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.idiomEntry.sample)
              .fontSize(15)
              .lineHeight(24)
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(20)
        } else if (this.wordEntry) {
          Text(this.wordEntry.word)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .width('100%')
          Text(this.wordEntry.pinyin)
            .fontSize(16)
            .fontColor('#6B7280')
            .width('100%')
          Button(this.isFavorite ? '取消收藏' : '加入收藏')
            .backgroundColor(this.isFavorite ? '#F97316' : '#2563EB')
            .onClick(() => this.toggleFavorite())
          StrokeCanvas({ word: this.wordEntry.word.charAt(0) })
          Column({ space: 12 }) {
            Text('释义')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.wordEntry.definition)
              .fontSize(15)
              .lineHeight(24)
            Text('例句')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.wordEntry.example)
              .fontSize(15)
              .lineHeight(24)
            Text('近义词')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.wordEntry.synonyms)
              .fontSize(15)
            Text('反义词')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Text(this.wordEntry.antonyms)
              .fontSize(15)
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Color.White)
          .borderRadius(20)
        }
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
