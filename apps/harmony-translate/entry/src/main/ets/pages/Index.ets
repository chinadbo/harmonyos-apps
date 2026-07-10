import { TranslateView } from '../views/TranslateView';
import { HistoryView } from '../views/HistoryView';
import { FavoritesView } from '../views/FavoritesView';
import { SettingsView } from '../views/SettingsView';

@Component
struct Index {
  @State selectedIndex: number = 0;
  @StorageProp('currentColorMode') currentColorMode: string = 'light';

  private tabs: Array<{ title: string; icon: string; index: number }> = [
    { title: '翻译', icon: '🌐', index: 0 },
    { title: '历史', icon: '📋', index: 1 },
    { title: '收藏', icon: '⭐', index: 2 },
    { title: '设置', icon: '⚙️', index: 3 }
  ];

  @Builder
  TabBarBuilder(index: number, title: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 2 })
      Text(title)
        .fontSize(12)
        .fontColor(this.selectedIndex === index ? '#4A90D9' : '#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        TranslateView()
      }
      .tabBar(this.TabBarBuilder(0, '翻译', '🌐'))

      TabContent() {
        HistoryView()
      }
      .tabBar(this.TabBarBuilder(1, '历史', '📋'))

      TabContent() {
        FavoritesView()
      }
      .tabBar(this.TabBarBuilder(2, '收藏', '⭐'))

      TabContent() {
        SettingsView()
      }
      .tabBar(this.TabBarBuilder(3, '设置', '⚙️'))
    }
    .width('100%')
    .height('100%')
    .barHeight(60)
    .barBackgroundColor(this.currentColorMode === 'dark' ? '#1A1A1A' : '#FFFFFF')
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.selectedIndex = index;
    })
    .backgroundColor(this.currentColorMode === 'dark' ? '#000000' : '#FFFFFF')
  }
}

export default Index;
