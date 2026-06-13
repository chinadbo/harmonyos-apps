import { FoodItem, MealType } from '../model/FoodItem'

@Component
export struct AddFoodDialog {
  @Link isVisible: boolean
  @Link foodName: string
  @Link calories: string
  @Link quantity: string
  @Link mealType: MealType
  onConfirm: (food: FoodItem) => void = () => {}

  private createFood(): FoodItem {
    return new FoodItem({
      id: `custom-${Date.now()}`,
      name: this.foodName.trim().length > 0 ? this.foodName.trim() : 'Custom Food',
      category: 'Custom',
      calories: Number(this.calories) || 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      unit: 'serving',
      quantity: Number(this.quantity) || 1,
      mealType: this.mealType
    })
  }

  build() {
    if (this.isVisible) {
      Column({ space: 12 }) {
        Text('Add Food')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        TextInput({ text: this.foodName, placeholder: 'Food name' })
          .onChange((value: string) => {
            this.foodName = value
          })
          .width('100%')
          .height(48)
          .backgroundColor('#0F000000')

        TextInput({ text: this.calories, placeholder: 'Calories per serving' })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.calories = value
          })
          .width('100%')
          .height(48)
          .backgroundColor('#0F000000')

        TextInput({ text: this.quantity, placeholder: 'Quantity' })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.quantity = value
          })
          .width('100%')
          .height(48)
          .backgroundColor('#0F000000')

        Row({ space: 8 }) {
          Button('Breakfast')
            .type(this.mealType === MealType.BREAKFAST ? ButtonType.Capsule : ButtonType.Normal)
            .onClick(() => this.mealType = MealType.BREAKFAST)
          Button('Lunch')
            .type(this.mealType === MealType.LUNCH ? ButtonType.Capsule : ButtonType.Normal)
            .onClick(() => this.mealType = MealType.LUNCH)
          Button('Dinner')
            .type(this.mealType === MealType.DINNER ? ButtonType.Capsule : ButtonType.Normal)
            .onClick(() => this.mealType = MealType.DINNER)
          Button('Snack')
            .type(this.mealType === MealType.SNACK ? ButtonType.Capsule : ButtonType.Normal)
            .onClick(() => this.mealType = MealType.SNACK)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row({ space: 12 }) {
          Button('Cancel')
            .layoutWeight(1)
            .backgroundColor('#12000000')
            .fontColor($r('app.color.text_primary'))
            .onClick(() => {
              this.isVisible = false
            })
          Button('Save')
            .layoutWeight(1)
            .backgroundColor($r('app.color.primary'))
            .onClick(() => {
              this.onConfirm(this.createFood())
              this.isVisible = false
            })
        }
        .width('100%')
      }
      .width('88%')
      .padding(20)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(24)
      .shadow({ radius: 24, color: '#22000000', offsetX: 0, offsetY: 8 })
    }
  }
}
