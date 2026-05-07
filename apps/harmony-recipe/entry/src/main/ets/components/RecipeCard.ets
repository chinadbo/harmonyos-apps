import router from '@ohos.router';
import { EMPTY_RECIPE, Recipe } from '../model/RecipeModel';
import { StarButton } from './StarButton';

@Reusable
@Component
export struct RecipeCard {
  @Prop recipe: Recipe = EMPTY_RECIPE;
  onChanged?: (id: number) => void = undefined;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.recipe.coverImage || '🍽️')
          .fontSize(38)
        Blank()
        StarButton({
          recipeId: this.recipe.id,
          favorite: this.recipe.isFavorite,
          onChanged: () => {
            if (this.onChanged) {
              this.onChanged(this.recipe.id);
            }
          }
        })
      }
      .width('100%')

      Text(this.recipe.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2B1F19')
        .maxLines(1)

      Text(this.recipe.description)
        .fontSize(13)
        .fontColor('#8A7367')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 8 }) {
        Text(this.recipe.category)
          .fontSize(11)
          .fontColor('#FF8A3D')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF1E8')
          .borderRadius(10)
        Text(`${this.recipe.cookTime} 分钟`)
          .fontSize(11)
          .fontColor('#6B5A50')
        Text(this.recipe.difficulty)
          .fontSize(11)
          .fontColor('#6B5A50')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(16)
    .width('100%')
    .height(190)
    .backgroundColor('#FFFDF8')
    .borderRadius(24)
    .shadow({ radius: 18, color: '#14000000', offsetX: 0, offsetY: 8 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/RecipeDetail',
        params: {
          recipeId: this.recipe.id
        }
      });
    })
  }
}
