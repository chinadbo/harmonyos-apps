import router from '@ohos.router'
import { SearchBar } from '../components/SearchBar'
import { WordCard } from '../components/WordCard'
import { WordDao } from '../database/WordDao'
import { IdiomEntry } from '../model/IdiomEntry'

@Component
export struct IdiomView {
  @State private keyword: string = ''
  @State private selectedIndex: number = 0
  @State private idioms: IdiomEntry[] = []
  private readonly indexerArray: string[] = ['A', 'B', 'C', 'D', 'H', 'K', 'M', 'S', 'T', 'W', 'X', 'Y', 'Z']
  private wordDao: WordDao = new WordDao()

  aboutToAppear(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    const initial = this.indexerArray[this.selectedIndex] || ''
    this.idioms = await this.wordDao.getIdiomSections(this.keyword, initial)
  }

  private openDetail(item: IdiomEntry): void {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: {
        id: item.id,
        type: 'idiom',
        queryText: item.word
      }
    })
  }

  build() {
    Row() {
      Column({ space: 16 }) {
        SearchBar({
          keyword: $keyword,
          onChangeAction: () => this.loadData(),
          onSearchAction: () => this.loadData()
        })

        if (this.idioms.length === 0) {
          Blank()
          Text('暂无匹配结果')
            .fontSize(15)
            .fontColor('#6B7280')
          Blank()
        } else {
          List({ space: 12 }) {
            ForEach(this.idioms, (item: IdiomEntry) => {
              ListItem() {
                WordCard({
                  word: item.word,
                  pinyin: item.pinyin,
                  definition: item.summary,
                  groupName: '成语',
                  onClickAction: () => this.openDetail(item)
                })
              }
            })
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .layoutWeight(1)
      .height('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)

      AlphabetIndexer({
        arrayValue: this.indexerArray,
        selected: this.selectedIndex
      })
        .height('75%')
        .selectedColor('#2563EB')
        .popupColor('#2563EB')
        .selectedFont({ size: 16, weight: FontWeight.Medium })
        .popupFont({ size: 18, weight: FontWeight.Bold })
        .onSelect((index: number) => {
          this.selectedIndex = index
          this.loadData()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
export struct IdiomPage {
  build() {
    IdiomView()
  }
}
