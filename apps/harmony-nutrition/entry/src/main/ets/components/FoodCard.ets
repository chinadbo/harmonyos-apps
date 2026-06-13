import { FoodItem } from '../model/FoodItem'

@Component
export struct FoodCard {
  @Prop foodItem: FoodItem = new FoodItem()

  build() {
    Row() {
      Column({ space: 6 }) {
        Text(this.foodItem.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(`${this.foodItem.category} · ${this.foodItem.unit}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(`P ${this.foodItem.totalProtein()}g · C ${this.foodItem.totalCarbs()}g · F ${this.foodItem.totalFat()}g`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 6 }) {
        Text(`${this.foodItem.totalCalories()} kcal`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
        Text(`x${this.foodItem.quantity}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.End)
    }
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(18)
  }
}
