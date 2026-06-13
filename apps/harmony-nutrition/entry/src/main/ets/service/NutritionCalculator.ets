import { DietRecord } from '../model/DietRecord'
import { FoodItem } from '../model/FoodItem'
import { UserProfile } from '../model/UserProfile'

export class NutritionCalculator {
  static calorieProgress(record: DietRecord, profile: UserProfile): number {
    return Math.min(1, record.totalCalories() / profile.dailyCalorieGoal)
  }

  static macroDistribution(record: DietRecord): number[] {
    let proteinCalories = record.totalProtein() * 4
    let carbCalories = record.totalCarbs() * 4
    let fatCalories = record.totalFat() * 9
    let total = proteinCalories + carbCalories + fatCalories
    if (total <= 0) {
      return [0, 0, 0]
    }
    return [
      Number(((proteinCalories / total) * 100).toFixed(1)),
      Number(((carbCalories / total) * 100).toFixed(1)),
      Number(((fatCalories / total) * 100).toFixed(1))
    ]
  }

  static averageCalories(records: DietRecord[]): number {
    if (records.length === 0) {
      return 0
    }
    let total = records.reduce((sum: number, item: DietRecord) => sum + item.totalCalories(), 0)
    return Number((total / records.length).toFixed(1))
  }

  static totalsForFoods(foods: FoodItem[]): { calories: number; protein: number; carbs: number; fat: number; fiber: number } {
    return foods.reduce((summary, item: FoodItem) => {
      summary.calories += item.totalCalories()
      summary.protein += item.totalProtein()
      summary.carbs += item.totalCarbs()
      summary.fat += item.totalFat()
      summary.fiber += item.totalFiber()
      return summary
    }, {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0
    })
  }
}
