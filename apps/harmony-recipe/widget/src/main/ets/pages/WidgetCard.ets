@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('widgetRecipeName') recipeName: string = '今日推荐';
  @LocalStorageProp('widgetRecipeCategory') recipeCategory: string = '早餐';
  @LocalStorageProp('widgetRecipeDescription') recipeDescription: string = '轻巧快手，适合忙碌的清晨。';
  @LocalStorageProp('widgetRecipeEmoji') recipeEmoji: string = '🍳';

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('HarmonyRecipe')
          .fontSize(12)
          .fontColor('#FFE7D7')
        Blank()
        Text(this.recipeEmoji)
          .fontSize(24)
      }
      .width('100%')

      Text(this.recipeName)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)
        .maxLines(1)

      Text(this.recipeCategory)
        .fontSize(12)
        .fontColor('#FFF1E6')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#33FFFFFF')
        .borderRadius(12)

      Text(this.recipeDescription)
        .fontSize(12)
        .fontColor('#FFF5EE')
        .lineHeight(18)
        .maxLines(2)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FF8A3D')
    .borderRadius(24)
  }
}
