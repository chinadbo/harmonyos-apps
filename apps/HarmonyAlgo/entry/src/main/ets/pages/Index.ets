import common from '@ohos.app.ability.common';
import { Database } from '../model/Database';
import { Problem } from '../model/Problem';
import { CATEGORIES } from '../data/problemset';
import { ProblemCard } from '../components/ProblemCard';
import { CategoryChip } from '../components/CategoryChip';
import { EmptyView } from '../components/EmptyView';
import { Theme } from '../common/Theme';
import { openProblem } from '../common/RouterUtil';
import { FavoritesView } from './Favorites';
import { MistakesView } from './Mistakes';
import { StatsView } from './Stats';
import { DailyView } from './Daily';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State refreshTick: number = 0;

  // 题库浏览状态
  @State problems: Problem[] = [];
  @State statusMap: Map<number, number> = new Map<number, number>();
  @State favSet: Set<number> = new Set<number>();
  @State category: string = '全部';
  @State difficulty: number = 0;
  @State keyword: string = '';
  @State loaded: boolean = false;

  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    this.loadBrowse();
  }

  onPageShow(): void {
    // 从详情页返回时刷新所有 Tab 数据
    this.refreshTick++;
    this.loadBrowse();
  }

  async loadBrowse(): Promise<void> {
    const db = Database.getInstance();
    await db.init(getContext(this) as common.UIAbilityContext);
    const list = await db.queryProblems(this.category, this.difficulty, this.keyword);
    const status = await db.getStatusMap();
    const favs = await db.getFavoriteIdSet();
    this.problems = list;
    this.statusMap = status;
    this.favSet = favs;
    this.loaded = true;
  }

  statusOf(id: number): number {
    const s = this.statusMap.get(id);
    return s === undefined ? 0 : s;
  }

  isFav(id: number): boolean {
    return this.favSet.has(id);
  }

  selectCategory(c: string): void {
    this.category = c;
    this.loadBrowse();
  }

  selectDifficulty(d: number): void {
    this.difficulty = d;
    this.loadBrowse();
  }

  @Builder
  TabBarItem(index: number, title: string) {
    Column({ space: 3 }) {
      Stack() {
      }
      .width(18)
      .height(3)
      .borderRadius(2)
      .backgroundColor(this.currentIndex === index ? Theme.primary : '#00000000')
      Text(title)
        .fontSize(13)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? Theme.primary : Theme.subText)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  BrowseContent() {
    Column() {
      Row() {
        Column() {
          Text('题库')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.text)
          Text('共 ' + this.problems.length + ' 道题目')
            .fontSize(12)
            .fontColor(Theme.subText)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 10 })

      Row() {
        Search({ value: this.keyword, placeholder: '搜索题目 / 标签' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Theme.card)
          .placeholderColor('#B4B9C6')
          .onChange((value: string) => {
            this.keyword = value;
            this.loadBrowse();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 分类筛选
      Scroll() {
        Row({ space: 8 }) {
          CategoryChip({
            label: '全部',
            selected: this.category === '全部',
            onSelect: () => {
              this.selectCategory('全部');
            }
          })
          ForEach(CATEGORIES, (c: string) => {
            CategoryChip({
              label: c,
              selected: this.category === c,
              onSelect: () => {
                this.selectCategory(c);
              }
            })
          }, (c: string) => c)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ top: 10 })

      // 难度筛选
      Row({ space: 8 }) {
        CategoryChip({
          label: '全部难度',
          selected: this.difficulty === 0,
          onSelect: () => {
            this.selectDifficulty(0);
          }
        })
        CategoryChip({
          label: '简单',
          selected: this.difficulty === 1,
          onSelect: () => {
            this.selectDifficulty(1);
          }
        })
        CategoryChip({
          label: '中等',
          selected: this.difficulty === 2,
          onSelect: () => {
            this.selectDifficulty(2);
          }
        })
        CategoryChip({
          label: '困难',
          selected: this.difficulty === 3,
          onSelect: () => {
            this.selectDifficulty(3);
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 10, bottom: 6 })

      if (this.loaded && this.problems.length === 0) {
        EmptyView({ title: '没有找到题目', subtitle: '换个筛选条件或关键字试试' })
      } else {
        List({ space: 10 }) {
          ForEach(this.problems, (item: Problem) => {
            ListItem() {
              ProblemCard({
                problem: item,
                status: this.statusOf(item.id),
                favorite: this.isFav(item.id),
                onTap: () => openProblem(item.id)
              })
            }
          }, (item: Problem) => item.id.toString())
          ListItem() {
            Row().height(12)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.tabsController }) {
      TabContent() {
        this.BrowseContent()
      }
      .tabBar(this.TabBarItem(0, '题库'))

      TabContent() {
        FavoritesView({ refreshTick: this.refreshTick })
      }
      .tabBar(this.TabBarItem(1, '收藏'))

      TabContent() {
        MistakesView({ refreshTick: this.refreshTick })
      }
      .tabBar(this.TabBarItem(2, '错题'))

      TabContent() {
        StatsView({ refreshTick: this.refreshTick })
      }
      .tabBar(this.TabBarItem(3, '统计'))

      TabContent() {
        DailyView({ refreshTick: this.refreshTick })
      }
      .tabBar(this.TabBarItem(4, '每日'))
    }
    .barHeight(60)
    .barMode(BarMode.Fixed)
    .scrollable(false)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
