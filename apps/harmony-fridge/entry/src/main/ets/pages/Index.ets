import { Constants } from '../common/Constants';
import { FridgeHomePage } from '../views/FridgeHomePage';
import { ShoppingListPage } from '../views/ShoppingListPage';
import { StatsPage } from '../views/StatsPage';
import { SettingsPage } from '../views/SettingsPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private pathStack: NavPathStack = new NavPathStack();

  @Builder
  private buildContent() {
    if (this.currentIndex === 0) {
      FridgeHomePage()
    } else if (this.currentIndex === 1) {
      ShoppingListPage()
    } else if (this.currentIndex === 2) {
      StatsPage()
    } else {
      SettingsPage()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Tabs({ barPosition: BarPosition.End, controller: new TabsController() }) {
          TabContent() {
            FridgeHomePage()
          }
          .tabBar({ text: '首页' })

          TabContent() {
            ShoppingListPage()
          }
          .tabBar({ text: '购物清单' })

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
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor('#F4F8F4')
  }
}
