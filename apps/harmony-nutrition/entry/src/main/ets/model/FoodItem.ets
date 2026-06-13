export enum MealType {
  BREAKFAST = 'Breakfast',
  LUNCH = 'Lunch',
  DINNER = 'Dinner',
  SNACK = 'Snack'
}

export class FoodItem {
  id: string = ''
  name: string = ''
  category: string = ''
  calories: number = 0
  protein: number = 0
  carbs: number = 0
  fat: number = 0
  fiber: number = 0
  unit: string = '100g'
  mealType: MealType = MealType.BREAKFAST
  quantity: number = 1
  image: string = ''

  constructor(init?: Partial<FoodItem>) {
    Object.assign(this, init)
  }

  totalCalories(): number {
    return Number((this.calories * this.quantity).toFixed(1))
  }

  totalProtein(): number {
    return Number((this.protein * this.quantity).toFixed(1))
  }

  totalCarbs(): number {
    return Number((this.carbs * this.quantity).toFixed(1))
  }

  totalFat(): number {
    return Number((this.fat * this.quantity).toFixed(1))
  }

  totalFiber(): number {
    return Number((this.fiber * this.quantity).toFixed(1))
  }
}
