import common from '@ohos.app.ability.common'
import router from '@ohos.router'
import DatabaseService from '../service/DatabaseService'
import { HistoryItem } from '../components/HistoryItem'
import { QRRecord } from '../model/QRRecord'
import { ROUTES, STORAGE_KEYS } from '../utils/Constants'

class QRDataSource implements IDataSource {
  private list: QRRecord[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.list.length
  }

  getData(index: number): QRRecord {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => listener.onDataReloaded())
  }

  setData(data: QRRecord[]): void {
    this.list = data
    this.notifyDataReload()
  }
}

@Component
export default struct HistoryPage {
  @State private currentIndex: number = 0
  @State private keyword: string = ''
  @State private refreshing: boolean = false
  @StorageProp(STORAGE_KEYS.HISTORY_REFRESH) @Watch('onHistoryRefreshChange') private historyRefresh: number = 0
  private readonly tabsController: TabsController = new TabsController()
  private readonly dataSource: QRDataSource = new QRDataSource()
  private context = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    await DatabaseService.init(this.context)
    await this.loadData()
  }

  async onPageShow(): Promise<void> {
    await this.loadData()
  }

  onHistoryRefreshChange(): void {
    if (this.historyRefresh > 0) {
      this.loadData().then(() => {
        AppStorage.setOrCreate(STORAGE_KEYS.HISTORY_REFRESH, 0)
      }).catch(() => { /* ignore */ })
    }
  }

  private async loadData(): Promise<void> {
    let data: QRRecord[] = []
    if (this.currentIndex === 0) {
      data = await DatabaseService.search(this.keyword, 'scan', false)
    } else if (this.currentIndex === 1) {
      data = await DatabaseService.search(this.keyword, 'generate', false)
    } else {
      data = await DatabaseService.search(this.keyword, undefined, true)
    }
    this.dataSource.setData(data)
    this.refreshing = false
  }

  private async deleteRecord(record: QRRecord): Promise<void> {
    await DatabaseService.delete(record.id)
    await this.loadData()
  }

  private async toggleFavorite(record: QRRecord): Promise<void> {
    await DatabaseService.toggleFavorite(record.id, record.isFavorite !== 1)
    await this.loadData()
  }

  private openRecord(record: QRRecord): void {
    router.pushUrl({
      url: ROUTES.RESULT,
      params: {
        record: JSON.stringify(record)
      }
    })
  }

  @Builder
  private EmptyBuilder(message: string) {
    Column({ space: 10 }) {
      Text('暂无记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF0F172A')
      Text(message)
        .fontSize(14)
        .fontColor('#FF64748B')
    }
    .width('100%')
    .padding({ top: 64 })
  }

  build() {
    Column({ space: 14 }) {
      Column({ space: 6 }) {
        Text('历史记录')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0F172A')
          .width('100%')
        Search({ value: this.keyword, placeholder: '搜索二维码内容' })
          .width('100%')
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(18)
          .onChange((value: string) => {
            this.keyword = value
            this.loadData()
          })
      }
      .padding({ left: 16, right: 16, top: 20 })

      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        TabContent() {
          this.ListBuilder('还没有扫码历史')
        }
        .tabBar('扫描历史')

        TabContent() {
          this.ListBuilder('还没有生成历史')
        }
        .tabBar('生成历史')

        TabContent() {
          this.ListBuilder('还没有收藏内容')
        }
        .tabBar('收藏')
      }
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.currentIndex = index
        this.loadData()
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8FAFC')
  }

  @Builder
  private ListBuilder(emptyMessage: string) {
    if (this.dataSource.totalCount() === 0) {
      this.EmptyBuilder(emptyMessage)
    } else {
      List({ space: 0 }) {
        LazyForEach(this.dataSource, (record: QRRecord) => {
          ListItem() {
            HistoryItem({
              record,
              onDelete: async (item: QRRecord) => {
                await this.deleteRecord(item)
              },
              onToggleFavorite: async (item: QRRecord) => {
                await this.toggleFavorite(item)
              },
              onClick: (item: QRRecord) => {
                this.openRecord(item)
              }
            })
          }
        }, (record: QRRecord) => `${record.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .onReachEnd(() => {
      })
    }
  }
}
