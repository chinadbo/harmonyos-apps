import { DietRecord } from '../model/DietRecord'
import { FoodItem, MealType } from '../model/FoodItem'
import { UserProfile } from '../model/UserProfile'

export class DatabaseHelper {
  private static instance: DatabaseHelper = new DatabaseHelper()
  private foodLibrary: FoodItem[] = []
  private dietRecords: DietRecord[] = []
  private userProfile: UserProfile = new UserProfile()

  private constructor() {
    this.seedData()
  }

  static getInstance(): DatabaseHelper {
    return DatabaseHelper.instance
  }

  getFoodLibrary(): FoodItem[] {
    return [...this.foodLibrary]
  }

  saveFoodLibrary(items: FoodItem[]): void {
    this.foodLibrary = [...items]
  }

  getDietRecords(): DietRecord[] {
    return [...this.dietRecords]
  }

  saveDietRecords(records: DietRecord[]): void {
    this.dietRecords = [...records]
  }

  getUserProfile(): UserProfile {
    return new UserProfile(this.userProfile)
  }

  saveUserProfile(profile: UserProfile): void {
    this.userProfile = new UserProfile(profile)
  }

  private seedData(): void {
    // 内置 50 条常见中国食物数据（与 rawfile/foods.json 数据一致）
    this.foodLibrary = [
      // 主食 (10条)
      new FoodItem({ id: 'f001', name: '米饭', category: '主食', calories: 116, protein: 2.6, carbs: 25.6, fat: 0.3, fiber: 0.3, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f002', name: '馒头', category: '主食', calories: 223, protein: 7.0, carbs: 47.0, fat: 1.1, fiber: 1.3, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f003', name: '面条（煮）', category: '主食', calories: 110, protein: 3.5, carbs: 22.0, fat: 0.7, fiber: 0.8, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f004', name: '玉米', category: '主食', calories: 112, protein: 4.0, carbs: 22.8, fat: 1.2, fiber: 2.9, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f005', name: '红薯', category: '主食', calories: 99, protein: 1.1, carbs: 23.1, fat: 0.2, fiber: 1.6, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f006', name: '燕麦片', category: '主食', calories: 338, protein: 10.1, carbs: 57.6, fat: 7.2, fiber: 6.0, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f007', name: '全麦面包', category: '主食', calories: 246, protein: 8.8, carbs: 44.5, fat: 4.0, fiber: 6.9, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f008', name: '糙米饭', category: '主食', calories: 111, protein: 2.6, carbs: 23.0, fat: 0.9, fiber: 1.8, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f009', name: '花卷', category: '主食', calories: 217, protein: 6.4, carbs: 44.4, fat: 2.0, fiber: 1.0, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f010', name: '小米粥', category: '主食', calories: 46, protein: 1.4, carbs: 9.8, fat: 0.3, fiber: 0.2, unit: '100g', mealType: MealType.BREAKFAST }),
      // 蔬菜 (10条)
      new FoodItem({ id: 'f011', name: '西兰花', category: '蔬菜', calories: 34, protein: 2.8, carbs: 6.6, fat: 0.4, fiber: 2.6, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f012', name: '菠菜', category: '蔬菜', calories: 24, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f013', name: '白菜', category: '蔬菜', calories: 17, protein: 1.5, carbs: 3.2, fat: 0.2, fiber: 0.8, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f014', name: '黄瓜', category: '蔬菜', calories: 16, protein: 0.8, carbs: 3.6, fat: 0.1, fiber: 0.5, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f015', name: '番茄', category: '蔬菜', calories: 20, protein: 1.0, carbs: 4.4, fat: 0.2, fiber: 1.3, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f016', name: '胡萝卜', category: '蔬菜', calories: 37, protein: 0.9, carbs: 8.8, fat: 0.2, fiber: 2.8, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f017', name: '青椒', category: '蔬菜', calories: 24, protein: 1.0, carbs: 5.4, fat: 0.2, fiber: 1.4, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f018', name: '豆腐', category: '蔬菜', calories: 81, protein: 8.1, carbs: 1.9, fat: 4.8, fiber: 0.4, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f019', name: '芹菜', category: '蔬菜', calories: 16, protein: 0.8, carbs: 3.5, fat: 0.1, fiber: 1.2, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f020', name: '土豆', category: '蔬菜', calories: 77, protein: 2.0, carbs: 17.5, fat: 0.1, fiber: 2.2, unit: '100g', mealType: MealType.LUNCH }),
      // 水果 (10条)
      new FoodItem({ id: 'f021', name: '苹果', category: '水果', calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f022', name: '香蕉', category: '水果', calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f023', name: '橙子', category: '水果', calories: 47, protein: 0.9, carbs: 11.8, fat: 0.1, fiber: 2.4, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f024', name: '葡萄', category: '水果', calories: 69, protein: 0.6, carbs: 18.1, fat: 0.2, fiber: 0.9, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f025', name: '草莓', category: '水果', calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2.0, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f026', name: '西瓜', category: '水果', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.1, fiber: 0.4, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f027', name: '猕猴桃', category: '水果', calories: 61, protein: 1.1, carbs: 14.7, fat: 0.5, fiber: 3.0, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f028', name: '梨', category: '水果', calories: 57, protein: 0.4, carbs: 15.3, fat: 0.1, fiber: 3.1, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f029', name: '芒果', category: '水果', calories: 65, protein: 0.5, carbs: 17.0, fat: 0.3, fiber: 1.8, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f030', name: '蓝莓', category: '水果', calories: 57, protein: 0.7, carbs: 14.5, fat: 0.3, fiber: 2.4, unit: '100g', mealType: MealType.SNACK }),
      // 肉类 (8条)
      new FoodItem({ id: 'f031', name: '鸡胸肉', category: '肉类', calories: 165, protein: 31.0, carbs: 0.0, fat: 3.6, fiber: 0.0, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f032', name: '猪肉（瘦）', category: '肉类', calories: 143, protein: 20.3, carbs: 1.5, fat: 6.2, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f033', name: '牛肉', category: '肉类', calories: 125, protein: 20.2, carbs: 1.2, fat: 4.2, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f034', name: '三文鱼', category: '肉类', calories: 208, protein: 20.4, carbs: 0.0, fat: 13.4, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f035', name: '虾', category: '肉类', calories: 99, protein: 18.0, carbs: 1.7, fat: 1.9, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f036', name: '鸡腿（去皮）', category: '肉类', calories: 132, protein: 24.0, carbs: 0.0, fat: 3.6, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f037', name: '鸭肉', category: '肉类', calories: 201, protein: 15.5, carbs: 0.0, fat: 15.6, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      new FoodItem({ id: 'f038', name: '带鱼', category: '肉类', calories: 127, protein: 18.1, carbs: 3.1, fat: 4.9, fiber: 0.0, unit: '100g', mealType: MealType.DINNER }),
      // 蛋奶 (5条)
      new FoodItem({ id: 'f039', name: '鸡蛋', category: '蛋奶', calories: 155, protein: 12.6, carbs: 1.1, fat: 11.0, fiber: 0.0, unit: '100g', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f040', name: '牛奶', category: '蛋奶', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0.0, unit: '100ml', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f041', name: '希腊酸奶', category: '蛋奶', calories: 59, protein: 10.0, carbs: 3.6, fat: 0.4, fiber: 0.0, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f042', name: '奶酪', category: '蛋奶', calories: 350, protein: 25.0, carbs: 1.3, fat: 27.0, fiber: 0.0, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f043', name: '皮蛋', category: '蛋奶', calories: 171, protein: 14.2, carbs: 4.5, fat: 10.7, fiber: 0.0, unit: '100g', mealType: MealType.BREAKFAST }),
      // 豆制品 (4条)
      new FoodItem({ id: 'f044', name: '豆浆', category: '豆制品', calories: 33, protein: 2.6, carbs: 1.8, fat: 1.8, fiber: 1.1, unit: '100ml', mealType: MealType.BREAKFAST }),
      new FoodItem({ id: 'f045', name: '豆腐干', category: '豆制品', calories: 147, protein: 14.5, carbs: 3.3, fat: 8.6, fiber: 0.8, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f046', name: '纳豆', category: '豆制品', calories: 212, protein: 17.7, carbs: 14.4, fat: 11.0, fiber: 6.7, unit: '100g', mealType: MealType.LUNCH }),
      new FoodItem({ id: 'f047', name: '毛豆', category: '豆制品', calories: 122, protein: 11.9, carbs: 11.1, fat: 5.3, fiber: 4.0, unit: '100g', mealType: MealType.SNACK }),
      // 坚果 (4条)
      new FoodItem({ id: 'f048', name: '核桃', category: '坚果', calories: 654, protein: 15.2, carbs: 13.7, fat: 65.2, fiber: 6.7, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f049', name: '花生', category: '坚果', calories: 567, protein: 25.8, carbs: 16.1, fat: 49.2, fiber: 8.5, unit: '100g', mealType: MealType.SNACK }),
      new FoodItem({ id: 'f050', name: '杏仁', category: '坚果', calories: 579, protein: 21.2, carbs: 21.6, fat: 49.9, fiber: 12.5, unit: '100g', mealType: MealType.SNACK }),
    ]

    let today = this.formatDate(new Date())
    let yesterdayDate = new Date(Date.now() - 24 * 60 * 60 * 1000)
    let yesterday = this.formatDate(yesterdayDate)

    this.dietRecords = [
      new DietRecord({
        id: 'r001',
        date: today,
        foodItems: [
          new FoodItem({ id: 'rf001', name: '燕麦片', category: '主食', calories: 338, protein: 10.1, carbs: 57.6, fat: 7.2, fiber: 6.0, unit: '100g', quantity: 0.5, mealType: MealType.BREAKFAST }),
          new FoodItem({ id: 'rf002', name: '鸡胸肉', category: '肉类', calories: 165, protein: 31.0, carbs: 0.0, fat: 3.6, fiber: 0.0, unit: '100g', quantity: 1.5, mealType: MealType.LUNCH }),
          new FoodItem({ id: 'rf003', name: '米饭', category: '主食', calories: 116, protein: 2.6, carbs: 25.6, fat: 0.3, fiber: 0.3, unit: '100g', quantity: 1.0, mealType: MealType.DINNER }),
          new FoodItem({ id: 'rf004', name: '苹果', category: '水果', calories: 52, protein: 0.3, carbs: 13.8, fat: 0.2, fiber: 2.4, unit: '100g', quantity: 1.0, mealType: MealType.SNACK })
        ],
        note: '今日饮食'
      }),
      new DietRecord({
        id: 'r002',
        date: yesterday,
        foodItems: [
          new FoodItem({ id: 'rf005', name: '全麦面包', category: '主食', calories: 246, protein: 8.8, carbs: 44.5, fat: 4.0, fiber: 6.9, unit: '100g', quantity: 1.0, mealType: MealType.BREAKFAST }),
          new FoodItem({ id: 'rf006', name: '糙米饭', category: '主食', calories: 111, protein: 2.6, carbs: 23.0, fat: 0.9, fiber: 1.8, unit: '100g', quantity: 2.0, mealType: MealType.LUNCH }),
          new FoodItem({ id: 'rf007', name: '西兰花', category: '蔬菜', calories: 34, protein: 2.8, carbs: 6.6, fat: 0.4, fiber: 2.6, unit: '100g', quantity: 1.5, mealType: MealType.DINNER })
        ],
        note: '高纤维日'
      })
    ]
  }

  private formatDate(date: Date): string {
    let year = date.getFullYear()
    let month = `${date.getMonth() + 1}`.padStart(2, '0')
    let day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
