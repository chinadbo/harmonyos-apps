/**
 * 应用主页面
 * 底部 TabBar 导航：订阅 / 文章 / 收藏 / 设置
 */
import { FeedListPage } from './FeedListPage';
import { ArticleListPage } from './ArticleListPage';
import { BookmarkPage } from './BookmarkPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;

  @Builder
  TabBuilder(title: string, icon: Resource, index: number) {
    Column({ space: 4 }) {
      Image(icon)
        .width(22)
        .height(22)
        .fillColor(this.currentTab === index ? $r('app.color.primary_color') : $r('app.color.text_hint'))
      Text(title)
        .fontSize(10)
        .fontColor(this.currentTab === index ? $r('app.color.primary_color') : $r('app.color.text_hint'))
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
      TabContent() {
        FeedListPage()
      }
      .tabBar(this.TabBuilder('订阅', $r('sys.media.ohos_ic_public_list'), 0))

      TabContent() {
        ArticleListPage({ feedId: -1, feedTitle: '全部文章' })
      }
      .tabBar(this.TabBuilder('文章', $r('sys.media.ohos_ic_public_news'), 1))

      TabContent() {
        BookmarkPage()
      }
      .tabBar(this.TabBuilder('收藏', $r('sys.media.ohos_ic_public_collect'), 2))

      TabContent() {
        SettingsPage()
      }
      .tabBar(this.TabBuilder('设置', $r('sys.media.ohos_ic_public_settings'), 3))
    }
    .onChange((index) => {
      this.currentTab = index;
    })
    .barHeight(56)
    .divider({ strokeWidth: 0.5, color: $r('app.color.divider_color') })
  }
}
