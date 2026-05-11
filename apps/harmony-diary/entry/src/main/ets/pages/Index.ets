import { HomeTab } from '../views/HomeTab';
import { CalendarTab } from '../views/CalendarTab';
import { StatsTab } from '../views/StatsTab';
import { DiaryEditor } from '../views/DiaryEditor';
import { DiaryDetail } from '../views/DiaryDetail';
import { SearchPage } from '../views/SearchPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  navPathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          HomeTab({ navPathStack: this.navPathStack })
        }
        .tabBar(this.tabBuilder('首页', '⌂', 0))

        TabContent() {
          CalendarTab({ navPathStack: this.navPathStack })
        }
        .tabBar(this.tabBuilder('月历', '□', 1))

        TabContent() {
          StatsTab()
        }
        .tabBar(this.tabBuilder('统计', '◔', 2))
      }
      .onChange((index: number) => this.currentIndex = index)
      .barMode(BarMode.Fixed)
      .divider({ strokeWidth: 0 })
      .backgroundColor('#FFFFFF')
    }
    .navDestination(this.routeBuilder)
    .hideTitleBar(true)
  }

  // P1 Fix: @Builder 内不允许 const/let 声明，抽取路由参数解析到独立方法
  private getRouteId(param: Object): number {
    return (param as Record<string, number>)['id'] ?? 0;
  }

  private getRouteDate(param: Object): string {
    return (param as Record<string, string>)['date'] ?? '';
  }

  @Builder
  routeBuilder(name: string, param: Object) {
    if (name === 'DiaryEditor') {
      DiaryEditor({
        navPathStack: this.navPathStack,
        diaryId: this.getRouteId(param),
        initialDate: this.getRouteDate(param)
      })
    } else if (name === 'DiaryDetail') {
      DiaryDetail({
        navPathStack: this.navPathStack,
        id: this.getRouteId(param)
      })
    } else if (name === 'SearchPage') {
      SearchPage({ navPathStack: this.navPathStack })
    } else {
      HomeTab({ navPathStack: this.navPathStack })
    }
  }

  @Builder
  private tabBuilder(label: string, icon: string, index: number) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(18)
        .fontColor(this.currentIndex === index ? '#0F172A' : '#94A3B8')
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#0F172A' : '#94A3B8')
    }
    .padding({ top: 8, bottom: 8 })
  }
}
