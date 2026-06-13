import { FoodItem } from '../model/FoodItem'
import { FoodCard } from '../components/FoodCard'

@Component
export struct MealSection {
  @Prop title: string = ''
  @Prop mealColor: Resource = $r('app.color.primary')
  // V1 体系下传入数组使用 @State 本地拷贝，避免 @Prop 深层对象不触发渲染
  @State localFoods: FoodItem[] = []
  foodsData: FoodItem[] = []

  aboutToAppear(): void {
    this.localFoods = [...this.foodsData]
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Row()
          .width(10)
          .height(10)
          .borderRadius(5)
          .backgroundColor(this.mealColor)
          .margin({ right: 8 })
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(`${this.localFoods.length} 项`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      if (this.localFoods.length === 0) {
        Text('暂无记录，点击 + 添加')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          .textAlign(TextAlign.Center)
      } else {
        ForEach(this.localFoods, (food: FoodItem) => {
          FoodCard({ foodItem: food })
        }, (food: FoodItem) => food.id)
      }
    }
    .width('100%')
  }
}
