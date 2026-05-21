import { GalleryView } from '../views/GalleryView'
import { EditView } from '../views/EditView'
import { FavoritesView } from '../views/FavoritesView'

@Entry
@Component
struct Index {
  @State private currentTab: number = 0

  build() {
    Tabs({
      barPosition: BarPosition.End,
      index: this.currentTab
    }) {
      TabContent() {
        GalleryView()
      }
      .tabBar(this.tabBarBuilder('相册', 0))

      TabContent() {
        EditView()
      }
      .tabBar(this.tabBarBuilder('编辑', 1))

      TabContent() {
        FavoritesView()
      }
      .tabBar(this.tabBarBuilder('收藏', 2))
    }
    .backgroundColor('#F5F5F5')
    .onChange((index: number) => {
      this.currentTab = index
    })
  }

  @Builder
  tabBarBuilder(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(this.currentTab === index ? '#2196F3' : '#888888')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .padding({ top: 8, bottom: 8 })
    .width(80)
    .justifyContent(FlexAlign.Center)
  }
}
