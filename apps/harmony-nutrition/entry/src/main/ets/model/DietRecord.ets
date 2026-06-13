import { FoodItem, MealType } from '../model/FoodItem'

export class DietRecord {
  id: string = ''
  date: string = ''
  foodItems: FoodItem[] = []
  note: string = ''

  constructor(init?: Partial<DietRecord>) {
    Object.assign(this, init)
    this.foodItems = init?.foodItems ?? []
  }

  addFood(food: FoodItem): void {
    this.foodItems.push(food)
  }

  foodsByMeal(mealType: MealType): FoodItem[] {
    return this.foodItems.filter((item: FoodItem) => item.mealType === mealType)
  }

  totalCalories(): number {
    return Number(this.foodItems.reduce((sum: number, item: FoodItem) => sum + item.totalCalories(), 0).toFixed(1))
  }

  totalProtein(): number {
    return Number(this.foodItems.reduce((sum: number, item: FoodItem) => sum + item.totalProtein(), 0).toFixed(1))
  }

  totalCarbs(): number {
    return Number(this.foodItems.reduce((sum: number, item: FoodItem) => sum + item.totalCarbs(), 0).toFixed(1))
  }

  totalFat(): number {
    return Number(this.foodItems.reduce((sum: number, item: FoodItem) => sum + item.totalFat(), 0).toFixed(1))
  }

  totalFiber(): number {
    return Number(this.foodItems.reduce((sum: number, item: FoodItem) => sum + item.totalFiber(), 0).toFixed(1))
  }
}
