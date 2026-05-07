import router from '@ohos.router';
import { Recipe } from '../model/RecipeModel';
import RecipeDataSource from '../model/RecipeDataSource';
import DatabaseService from '../service/DatabaseService';
import { RecipeCard } from '../components/RecipeCard';
import { CategoryFilter } from '../components/CategoryFilter';

@Entry
@Component
struct Index {
  private discoverDataSource: RecipeDataSource = new RecipeDataSource();
  private favoriteDataSource: RecipeDataSource = new RecipeDataSource();
  private allRecipes: Recipe[] = [];
  @State selectedCategory: string = '全部';
  @State selectedIndex: number = 0;
  @State categories: string[] = ['全部'];
  @State totalCount: number = 0;
  @State favoriteCount: number = 0;
  @State categoryCount: number = 0;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    let recipes: Recipe[] = [];
    let favorites: Recipe[] = [];
    try {
      recipes = await DatabaseService.getInstance().getAllRecipes();
      favorites = await DatabaseService.getInstance().getFavorites();
    } catch (err) {
      return;
    }
    this.allRecipes = recipes;
    this.favoriteDataSource.setData(favorites);
    this.totalCount = recipes.length;
    this.favoriteCount = favorites.length;
    this.categoryCount = new Set(recipes.map((item: Recipe) => item.category)).size;
    this.categories = ['全部', ...Array.from(new Set(recipes.map((item: Recipe) => item.category)))];
    this.applyDiscoverFilter();
  }

  private applyDiscoverFilter(): void {
    const filtered = this.selectedCategory === '全部'
      ? this.allRecipes
      : this.allRecipes.filter((item: Recipe) => item.category === this.selectedCategory);
    this.discoverDataSource.setData(filtered);
  }

  @Builder
  private SearchBar() {
    Row({ space: 8 }) {
      Text('🔎')
        .fontSize(16)
      Text('搜索菜谱、食材或关键字')
        .fontSize(14)
        .fontColor('#8E7A6A')
      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#FFF7F0')
    .borderRadius(18)
    .onClick(() => {
      router.pushUrl({ url: 'pages/SearchPage' });
    })
  }

  @Builder
  private DiscoverPage() {
    Column({ space: 16 }) {
      Text('今日想做什么')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2B1F19')
        .width('100%')
        .textAlign(TextAlign.Start)

      this.SearchBar()

      CategoryFilter({
        categories: this.categories,
        selectedCategory: this.selectedCategory,
        onSelect: (category: string) => {
          this.selectedCategory = category;
          this.applyDiscoverFilter();
        }
      })

      Grid() {
        LazyForEach(this.discoverDataSource, (recipe: Recipe) => {
          GridItem() {
            RecipeCard({
              recipe,
              onChanged: () => {
                this.loadData();
              }
            })
          }
        }, (recipe: Recipe) => `${recipe.id}`)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .padding({ bottom: 24 })
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }

  @Builder
  private FavoritePage() {
    Column({ space: 16 }) {
      Row() {
        Text('我的收藏')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B1F19')
        Blank()
        Text(`${this.favoriteCount} 道`)
          .fontSize(14)
          .fontColor('#8E7A6A')
      }
      .width('100%')

      if (this.favoriteCount === 0) {
        Column({ space: 10 }) {
          Text('⭐')
            .fontSize(36)
          Text('还没有收藏的菜谱')
            .fontSize(16)
            .fontColor('#8E7A6A')
        }
        .width('100%')
        .height('70%')
        .justifyContent(FlexAlign.Center)
      } else {
        Grid() {
          LazyForEach(this.favoriteDataSource, (recipe: Recipe) => {
            GridItem() {
              RecipeCard({
                recipe,
                onChanged: () => {
                  this.loadData();
                }
              })
            }
          }, (recipe: Recipe) => `${recipe.id}`)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }

  @Builder
  private MinePage() {
    Column({ space: 16 }) {
      Text('我的厨房')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2B1F19')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 12 }) {
        this.StatCard('菜谱总数', `${this.totalCount}`, '#FFF0E5')
        this.StatCard('收藏数量', `${this.favoriteCount}`, '#FDE8E8')
      }
      .width('100%')

      this.StatCard('分类数量', `${this.categoryCount}`, '#EEF6FF')

      Column({ space: 8 }) {
        Text('使用说明')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B1F19')
          .width('100%')
        Text('在发现页浏览家常菜谱，在详情页查看食材与步骤，点击开始烹饪进入步骤计时，并可在收藏页集中管理你最常做的菜。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#6E5C51')
      }
      .padding(18)
      .backgroundColor('#FFFDF8')
      .borderRadius(24)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }

  @Builder
  private StatCard(title: string, value: string, backgroundColor: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#7A6659')
      Text(value)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2B1F19')
    }
    .padding(18)
    .width('100%')
    .backgroundColor(backgroundColor)
    .borderRadius(22)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.selectedIndex }) {
      TabContent() {
        this.DiscoverPage()
      }
      .tabBar('发现')

      TabContent() {
        this.FavoritePage()
      }
      .tabBar('收藏')

      TabContent() {
        this.MinePage()
      }
      .tabBar('我的')
    }
    .vertical(false)
    .onChange((index: number) => {
      this.selectedIndex = index;
      this.loadData();
    })
    .backgroundColor('#FFF9F4')
  }
}
