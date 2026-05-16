import { HomePage } from './HomePage'
import { WorkoutListPage } from './WorkoutListPage'
import { StatsPage } from './StatsPage'
import { SettingsPage } from './SettingsPage'

@Entry
@Component
export struct Index {
  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }
      .tabBar({ text: '首页' })

      TabContent() {
        WorkoutListPage()
      }
      .tabBar({ text: '记录' })

      TabContent() {
        StatsPage()
      }
      .tabBar({ text: '统计' })

      TabContent() {
        SettingsPage()
      }
      .tabBar({ text: '设置' })
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .scrollable(false)
    .barHeight(60)
    .width('100%')
    .height('100%')
  }
}
