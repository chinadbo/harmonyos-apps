import { HomeView } from '../views/HomeView'
import { HistoryView } from '../views/HistoryView'
import { SettingsView } from '../views/SettingsView'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  @Builder
  TabBarItem(icon: string, label: string, index: number) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(20)
        .fontColor(this.currentIndex === index ? '#2196F3' : '#9E9E9E')
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#2196F3' : '#9E9E9E')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        HomeView()
      }
      .tabBar(this.TabBarItem('🏠', '主页', 0))

      TabContent() {
        HistoryView()
      }
      .tabBar(this.TabBarItem('🕐', '历史', 1))

      TabContent() {
        SettingsView()
      }
      .tabBar(this.TabBarItem('⚙️', '设置', 2))
    }
    .width('100%')
    .height('100%')
    .barWidth('100%')
    .barHeight(60)
    .backgroundColor('#12121E')
    .barBackgroundColor('#1E1E2E')
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
