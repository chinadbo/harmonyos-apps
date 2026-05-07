import router from '@ohos.router';
import { EMPTY_RECIPE, Ingredient, Recipe, Step } from '../model/RecipeModel';
import DatabaseService from '../service/DatabaseService';
import { StarButton } from '../components/StarButton';

@Entry
@Component
struct RecipeDetail {
  @State recipe: Recipe = EMPTY_RECIPE;

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number>;
    const recipeId = Number(params.recipeId ?? 0);
    const recipe = await DatabaseService.getInstance().getRecipeById(recipeId);
    if (recipe) {
      this.recipe = recipe;
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Text(this.recipe.coverImage || '🍽️')
              .fontSize(72)
            Blank()
            StarButton({
              recipeId: this.recipe.id,
              favorite: this.recipe.isFavorite,
              onChanged: async () => {
                const latestRecipe = await DatabaseService.getInstance().getRecipeById(this.recipe.id);
                if (latestRecipe) {
                  this.recipe = latestRecipe;
                }
              }
            })
          }
          .width('100%')

          Text(this.recipe.name)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2B1F19')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(this.recipe.description)
            .fontSize(15)
            .lineHeight(24)
            .fontColor('#7A6659')
            .width('100%')

          Row() {
            this.MetaTag(this.recipe.category)
            this.MetaTag(`${this.recipe.cookTime} 分钟`)
            this.MetaTag(`${this.recipe.servings} 人份`)
            this.MetaTag(this.recipe.difficulty)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Column({ space: 12 }) {
            Text('食材')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2B1F19')
              .width('100%')
              .textAlign(TextAlign.Start)
            ForEach(this.recipe.ingredients, (item: Ingredient) => {
              Row() {
                Text(item.name)
                  .fontSize(15)
                  .fontColor('#2B1F19')
                Blank()
                Text(item.amount)
                  .fontSize(15)
                  .fontColor('#7A6659')
              }
              .padding(14)
              .backgroundColor('#FFFDF8')
              .borderRadius(18)
            }, (item: Ingredient) => `${item.name}-${item.amount}`)
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('步骤')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2B1F19')
              .width('100%')
              .textAlign(TextAlign.Start)
            ForEach(this.recipe.steps, (step: Step) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Text(`${step.index}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .width(28)
                    .height(28)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#FF8A3D')
                    .borderRadius(14)
                  Text(`${step.duration} 秒`)
                    .fontSize(12)
                    .fontColor('#A07C5D')
                }
                .width('100%')

                Text(step.description)
                  .fontSize(15)
                  .lineHeight(22)
                  .fontColor('#2B1F19')
                  .width('100%')
              }
              .padding(16)
              .backgroundColor('#FFFDF8')
              .borderRadius(20)
              .alignItems(HorizontalAlign.Start)
            }, (step: Step) => `${step.index}`)
          }
          .width('100%')

          Button('开始烹饪')
            .width('100%')
            .height(52)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF8A3D')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CookingTimer',
                params: {
                  recipeId: this.recipe.id
                }
              });
            })
        }
        .padding(20)
        .backgroundColor('#FFF9F4')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF9F4')
  }

  @Builder
  private MetaTag(value: string) {
    Text(value)
      .fontSize(12)
      .fontColor('#8A5B32')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor('#FFF0E2')
      .borderRadius(14)
  }
}
