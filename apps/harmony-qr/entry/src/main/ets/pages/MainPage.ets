import { STORAGE_KEYS } from '../utils/Constants'
import ScanPage from './ScanPage'
import GeneratePage from './GeneratePage'
import HistoryPage from './HistoryPage'

@Component
struct MainPage {
  @StorageLink(STORAGE_KEYS.MAIN_TAB_INDEX) private currentIndex: number = 0
  private readonly tabsController: TabsController = new TabsController()

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          ScanPage()
        }
        .tabBar(this.TabBuilder('扫码', 0))

        TabContent() {
          GeneratePage()
        }
        .tabBar(this.TabBuilder('生成', 1))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.TabBuilder('历史', 2))
      }
      .vertical(false)
      .scrollable(false)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .onAppear(() => {
        this.tabsController.changeIndex(this.currentIndex)
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8FAFC')
  }

  @Builder
  private TabBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(index === 0 ? '扫' : index === 1 ? '码' : '史')
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? '#FF0A59F7' : '#FF64748B')
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#FF0A59F7' : '#FF64748B')
    }
    .padding({ top: 8, bottom: 8 })
  }
}

export default MainPage
