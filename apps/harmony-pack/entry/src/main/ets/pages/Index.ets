import AddItemPage from './AddItemPage'
import AddTripPage from './AddTripPage'
import StatsPage from './StatsPage'
import TemplateDetailPage from './TemplateDetailPage'
import TemplatePage from './TemplatePage'
import TripDetailPage from './TripDetailPage'
import TripListPage from './TripListPage'

@Entry
@Component
export struct Index {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @State currentTab: number = 0

  @Builder
  PageMap(name: string, param: Record<string, Object>) {
    if (name === 'trip_detail') {
      TripDetailPage({ routeParams: param as Record<string, string | number> })
    } else if (name === 'add_trip') {
      AddTripPage({ routeParams: param as Record<string, string | number> })
    } else if (name === 'add_item') {
      AddItemPage({ routeParams: param as Record<string, string | number> })
    } else if (name === 'template_detail') {
      TemplateDetailPage({ routeParams: param as Record<string, string | number> })
    } else if (name === 'stats') {
      StatsPage()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
          TabContent() {
            TripListPage()
          }
          .tabBar(this.TabBarBuilder('行程', 0))

          TabContent() {
            TemplatePage()
          }
          .tabBar(this.TabBarBuilder('模板', 1))

          TabContent() {
            StatsPage()
          }
          .tabBar(this.TabBarBuilder('统计', 2))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.currentTab = index
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FAFC')
    }
    .title('HarmonyPack')
    .hideBackButton(true)
    .navDestination(this.PageMap.bind(this))
  }

  @Builder
  TabBarBuilder(label: string, index: number) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.currentTab === index ? '#2563EB' : '#94A3B8')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
