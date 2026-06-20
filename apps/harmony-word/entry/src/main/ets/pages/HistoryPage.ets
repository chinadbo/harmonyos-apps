import router from '@ohos.router'
import { HistoryDao, HistoryListEntry } from '../database/HistoryDao'
import { WordCard } from '../components/WordCard'

@Component
export struct HistoryView {
  @State private items: HistoryListEntry[] = []
  private historyDao: HistoryDao = new HistoryDao()

  aboutToAppear(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    this.items = await this.historyDao.listRecent()
  }

  private openDetail(item: HistoryListEntry): void {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: {
        id: item.id,
        type: item.entryType,
        queryText: item.queryText
      }
    })
  }

  build() {
    Column({ space: 16 }) {
      Text('最近 50 条查询历史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')

      if (this.items.length === 0) {
        Blank()
        Text('暂无查询历史')
          .fontSize(15)
          .fontColor('#6B7280')
        Blank()
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (item: HistoryListEntry) => {
            ListItem() {
              Column({ space: 6 }) {
                WordCard({
                  word: item.word,
                  pinyin: item.pinyin,
                  definition: item.definition,
                  groupName: item.groupName,
                  onClickAction: () => this.openDetail(item)
                })
                Text(item.createdAt)
                  .fontSize(12)
                  .fontColor('#9CA3AF')
                  .width('100%')
              }
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
    .backgroundColor('#F8FAFC')
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
export struct HistoryPage {
  build() {
    HistoryView()
  }
}
