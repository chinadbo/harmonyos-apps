/**
 * Index.ets — 应用主页，承载 4 个 Tab：藏品库 / 心愿单 / 统计 / 设置
 */
import { CollectionTab } from '../views/CollectionTab';
import { WishlistTab } from '../views/WishlistTab';
import { StatsView } from '../views/StatsView';
import { SettingsView } from '../views/SettingsView';
import { bumpRefresh, C_BG, C_CARD, C_LINE, C_BRAND, C_SUB } from '../common/Constants';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    if (AppStorage.get<string>('viewMode') === undefined) {
      AppStorage.setOrCreate<string>('viewMode', 'grid');
    }
    if (AppStorage.get<string>('sortMode') === undefined) {
      AppStorage.setOrCreate<string>('sortMode', 'created');
    }
    if (AppStorage.get<boolean>('showAcquired') === undefined) {
      AppStorage.setOrCreate<boolean>('showAcquired', false);
    }
    if (AppStorage.get<number>('refreshTick') === undefined) {
      AppStorage.setOrCreate<number>('refreshTick', 0);
    }
  }

  onPageShow(): void {
    // 从详情/编辑页返回时刷新各 Tab 数据
    bumpRefresh();
  }

  @Builder
  TabBar(index: number, label: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(21)
        .fontColor(this.currentIndex === index ? C_BRAND : C_SUB)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? C_BRAND : C_SUB)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 3 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        CollectionTab()
      }
      .tabBar(this.TabBar(0, '藏品', '▦'))

      TabContent() {
        WishlistTab()
      }
      .tabBar(this.TabBar(1, '心愿', '♡'))

      TabContent() {
        StatsView({ showTopBar: true })
      }
      .tabBar(this.TabBar(2, '统计', '▤'))

      TabContent() {
        SettingsView()
      }
      .tabBar(this.TabBar(3, '设置', '⚙'))
    }
    .barHeight(64)
    .barBackgroundColor(C_CARD)
    .scrollable(false)
    .animationDuration(200)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
