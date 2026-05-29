import { RouteNames } from '../ets/utils/Constants'
import { ExploreMapPage } from '../ets/views/ExploreMapPage'
import { CheckInListPage } from '../ets/views/CheckInListPage'
import { CheckInDetailPage } from '../ets/views/CheckInDetailPage'
import { AddSpotPage } from '../ets/views/AddSpotPage'
import { AchievementPage } from '../ets/views/AchievementPage'
import { StatisticsPage } from '../ets/views/StatisticsPage'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  @Builder
  private destinationBuilder(name: string) {
    // Tab 页面（EXPLORE_MAP / CHECKIN_LIST / ACHIEVEMENT / STATISTICS）直接在 Tabs 内渲染，无需在此映射
    // 只注册需要通过 NavPathStack push 的子页面
    if (name === RouteNames.CHECKIN_DETAIL) {
      CheckInDetailPage({ pathStack: this.pathStack })
    } else if (name === RouteNames.ADD_SPOT) {
      AddSpotPage({ pathStack: this.pathStack })
    }
  }

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          ExploreMapPage({ pathStack: this.pathStack })
        }
        .tabBar($r('app.string.tab_explore'))

        TabContent() {
          CheckInListPage({ pathStack: this.pathStack })
        }
        .tabBar($r('app.string.tab_checkin'))

        TabContent() {
          AchievementPage()
        }
        .tabBar($r('app.string.tab_achievement'))

        TabContent() {
          StatisticsPage()
        }
        .tabBar($r('app.string.tab_statistics'))
      }
      .vertical(false)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .barMode(BarMode.Fixed)
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')
    }
    .hideTitleBar(true)
    .navDestination(this.destinationBuilder)
    .backgroundColor('#F5F7FA')
  }
}
