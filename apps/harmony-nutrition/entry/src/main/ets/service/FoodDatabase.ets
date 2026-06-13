import { FoodDao } from '../database/FoodDao'
import { FoodItem, MealType } from '../model/FoodItem'

export class FoodDatabase {
  private foodDao: FoodDao = new FoodDao()

  search(keyword: string): FoodItem[] {
    return this.foodDao.findByKeyword(keyword)
  }

  recommendedFoods(goal: string): FoodItem[] {
    let items = this.foodDao.findAll()
    switch (goal) {
      case 'High Protein':
        return items.sort((left: FoodItem, right: FoodItem) => right.protein - left.protein).slice(0, 5)
      case 'Low Fat':
        return items.sort((left: FoodItem, right: FoodItem) => left.fat - right.fat).slice(0, 5)
      case 'High Fiber':
        return items.sort((left: FoodItem, right: FoodItem) => right.fiber - left.fiber).slice(0, 5)
      default:
        return items.slice(0, 5)
    }
  }

  quickAddTemplate(mealType: MealType): FoodItem[] {
    return this.foodDao.findAll().filter((item: FoodItem) => item.mealType === mealType).slice(0, 4)
  }
}
