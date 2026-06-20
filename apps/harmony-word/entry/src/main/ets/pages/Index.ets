import router from '@ohos.router'
import { SearchBar } from '../components/SearchBar'
import { WordCard } from '../components/WordCard'
import { SearchService } from '../service/SearchService'
import { WordEntry } from '../model/WordEntry'
import { SearchResultEntry } from '../database/WordDao'
import { FavoriteView } from './FavoritePage'
import { HistoryView } from './HistoryPage'
import { IdiomView } from './IdiomPage'

@Entry
@Component
export struct Index {
  @State private currentTab: number = 0
  @State private keyword: string = ''
  @State private todayWord: WordEntry | null = null
  @State private results: SearchResultEntry[] = []
  private readonly tabTitles: string[] = ['首页', '收藏', '历史', '成语']
  private searchService: SearchService = new SearchService()

  async aboutToAppear(): Promise<void> {
    this.todayWord = await this.searchService.getTodayWord()
    this.results = await this.searchService.search('')
  }

  private async loadSearchResult(): Promise<void> {
    this.results = await this.searchService.search(this.keyword)
  }

  private openResult(item: SearchResultEntry): void {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: {
        id: item.id,
        type: item.entryType,
        queryText: this.keyword || item.word
      }
    })
  }

  @Builder
  private TabButton(index: number, title: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentTab === index ? '#2563EB' : '#6B7280')
      if (this.currentTab === index) {
        Row()
          .width(18)
          .height(3)
          .borderRadius(2)
          .backgroundColor('#2563EB')
      }
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .onClick(() => {
      this.currentTab = index
    })
  }

  @Builder
  private HomeView() {
    Column({ space: 16 }) {
      SearchBar({
        keyword: $keyword,
        onChangeAction: () => this.loadSearchResult(),
        onSearchAction: () => this.loadSearchResult()
      })

      if (this.todayWord) {
        Column({ space: 10 }) {
          Text('今日推荐')
            .fontSize(16)
            .fontColor('#2563EB')
          WordCard({
            word: this.todayWord.word,
            pinyin: this.todayWord.pinyin,
            definition: this.todayWord.definition,
            groupName: this.todayWord.groupName,
            onClickAction: () => {
              if (this.todayWord) {
                this.openResult({
                  id: this.todayWord.id,
                  word: this.todayWord.word,
                  pinyin: this.todayWord.pinyin,
                  definition: this.todayWord.definition,
                  groupName: this.todayWord.groupName,
                  entryType: 'word'
                })
              }
            }
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Text(this.keyword.length > 0 ? '搜索结果' : '推荐词条')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .width('100%')

      if (this.results.length === 0) {
        Blank()
        Text('暂无匹配结果')
          .fontSize(15)
          .fontColor('#6B7280')
        Blank()
      } else {
        List({ space: 12 }) {
          ForEach(this.results, (item: SearchResultEntry) => {
            ListItem() {
              WordCard({
                word: item.word,
                pinyin: item.pinyin,
                definition: item.definition,
                groupName: item.groupName,
                onClickAction: () => this.openResult(item)
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private ContentView() {
    if (this.currentTab === 0) {
      this.HomeView()
    } else if (this.currentTab === 1) {
      Column() {
        FavoriteView()
      }.width('100%').layoutWeight(1)
    } else if (this.currentTab === 2) {
      Column() {
        HistoryView()
      }.width('100%').layoutWeight(1)
    } else {
      Column() {
        IdiomView()
      }.width('100%').layoutWeight(1)
    }
  }

  build() {
    Column() {
      this.ContentView()
      Row() {
        ForEach(this.tabTitles, (title: string) => {
          this.TabButton(this.tabTitles.indexOf(title), title)
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 10 })
      .backgroundColor(Color.White)
      .shadow({ radius: 8, color: '#12000000', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
