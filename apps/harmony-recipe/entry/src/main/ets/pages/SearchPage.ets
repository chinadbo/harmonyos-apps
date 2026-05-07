import router from '@ohos.router';
import { Recipe } from '../model/RecipeModel';
import RecipeDataSource from '../model/RecipeDataSource';
import DatabaseService from '../service/DatabaseService';
import { RecipeCard } from '../components/RecipeCard';

@Entry
@Component
struct SearchPage {
  private searchDataSource: RecipeDataSource = new RecipeDataSource();
  @State keyword: string = '';
  @State resultCount: number = 0;

  aboutToAppear(): void {
    this.searchRecipes('');
  }

  private async searchRecipes(keyword: string): Promise<void> {
    const recipes = await DatabaseService.getInstance().searchRecipes(keyword);
    this.searchDataSource.setData(recipes);
    this.resultCount = recipes.length;
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Text('←')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.back();
          })
        Text('搜索菜谱')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B1F19')
        Blank()
      }
      .width('100%')

      TextInput({ text: this.keyword, placeholder: '搜索菜谱、食材或关键字' })
        .width('100%')
        .height(52)
        .backgroundColor('#FFFDF8')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.keyword = value;
          this.searchRecipes(value);
        })

      Text(`共找到 ${this.resultCount} 道菜谱`)
        .fontSize(14)
        .fontColor('#8E7A6A')
        .width('100%')

      Grid() {
        LazyForEach(this.searchDataSource, (recipe: Recipe) => {
          GridItem() {
            RecipeCard({
              recipe,
              onChanged: () => {
                this.searchRecipes(this.keyword);
              }
            })
          }
        }, (recipe: Recipe) => `${recipe.id}`)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }
}
