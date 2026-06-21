import common from '@ohos.app.ability.common';
import { Poem } from '../model/Poem';
import { PoemService } from '../service/PoemService';
import { DailyPoemService } from '../service/DailyPoemService';
import { PoemCard } from '../components/PoemCard';
import { EmptyView } from '../components/EmptyView';
import { ExplorePage } from './ExplorePage';
import { SearchPage } from './SearchPage';
import { FavoritePage } from './FavoritePage';

@Entry
@Component
struct Index {
  @State poems: Poem[] = [];
  @State dailyPoem: Poem | null = null;
  @State loading: boolean = true;
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    this.loadPoems();
  }

  async loadPoems(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.poems = await PoemService.loadPoems(context);
    this.dailyPoem = DailyPoemService.getDailyPoem(this.poems);
    this.loading = false;
  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(this.currentIndex === index ? $r('app.color.theme_primary') : $r('app.color.text_secondary'))
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? $r('app.color.theme_primary') : $r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
  }

  @Builder
  HomeTabBuilder() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 10 }) {
          Text('每日一诗')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.theme_primary'))
            .width('100%')
          Text('按日期确定推荐，每天打开都能读到固定的一首经典诗词。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(18)
        .backgroundColor('#F9EFD9')
        .borderRadius(20)

        if (this.loading) {
          LoadingProgress()
            .width(40)
            .height(40)
        } else if (this.dailyPoem) {
          PoemCard({ poem: this.dailyPoem })
        } else {
          EmptyView({ title: '暂无诗词数据', description: '请检查 rawfile/poems.json 是否存在。' })
        }

        Column({ space: 12 }) {
          Text('经典推荐')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
          ForEach(this.poems.slice(0, 6), (poem: Poem) => {
            PoemCard({ poem: poem })
          }, (poem: Poem) => `${poem.id}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.theme_background'))
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        this.HomeTabBuilder()
      }
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.icon_home')))

      TabContent() {
        ExplorePage()
      }
      .tabBar(this.TabBuilder('探索', 1, $r('app.media.icon_explore')))

      TabContent() {
        SearchPage()
      }
      .tabBar(this.TabBuilder('搜索', 2, $r('app.media.icon_search')))

      TabContent() {
        FavoritePage()
      }
      .tabBar(this.TabBuilder('收藏', 3, $r('app.media.icon_favorite')))
    }
    .barMode(BarMode.Fixed)
    .backgroundColor($r('app.color.theme_background'))
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
