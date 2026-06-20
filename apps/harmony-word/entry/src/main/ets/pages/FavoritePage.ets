import router from '@ohos.router'
import { FavoriteDao, FavoriteEntry } from '../database/FavoriteDao'
import { WordCard } from '../components/WordCard'

@Component
export struct FavoriteView {
  @State private currentGroup: string = ''
  @State private items: FavoriteEntry[] = []
  private readonly groups: string[] = ['全部', '默认', '生僻字', '成语']
  private favoriteDao: FavoriteDao = new FavoriteDao()

  aboutToAppear(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    const groupName = this.currentGroup === '全部' ? '' : this.currentGroup
    this.items = await this.favoriteDao.list(groupName)
  }

  private openDetail(item: FavoriteEntry): void {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: {
        id: item.entryId,
        type: item.entryType,
        queryText: item.word
      }
    })
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 10 }) {
        ForEach(this.groups, (group: string) => {
          Text(group)
            .fontSize(14)
            .fontColor(this.currentGroup === group || (group === '全部' && this.currentGroup === '') ? '#FFFFFF' : '#2563EB')
            .backgroundColor(this.currentGroup === group || (group === '全部' && this.currentGroup === '') ? '#2563EB' : '#EFF6FF')
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(16)
            .onClick(() => {
              this.currentGroup = group === '全部' ? '' : group
              this.loadData()
            })
        })
      }
      .width('100%')

      if (this.items.length === 0) {
        Blank()
        Text('暂无收藏内容')
          .fontSize(15)
          .fontColor('#6B7280')
        Blank()
      } else {
        List({ space: 12 }) {
          ForEach(this.items, (item: FavoriteEntry) => {
            ListItem() {
              WordCard({
                word: item.word,
                pinyin: item.pinyin,
                definition: item.definition,
                groupName: item.groupName,
                onClickAction: () => this.openDetail(item)
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
    .backgroundColor('#F8FAFC')
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
export struct FavoritePage {
  build() {
    FavoriteView()
  }
}
