import router from '@ohos.router'
import { CalorieRingChart } from '../components/CalorieRingChart'
import { NutrientPieChart } from '../components/NutrientPieChart'
import { MealSection } from '../components/MealSection'
import { AddFoodDialog } from '../components/AddFoodDialog'
import { DietDao } from '../database/DietDao'
import { DatabaseHelper } from '../database/DatabaseHelper'
import { DietRecord } from '../model/DietRecord'
import { FoodItem, MealType } from '../model/FoodItem'
import { UserProfile } from '../model/UserProfile'
import { NutritionCalculator } from '../service/NutritionCalculator'

@Entry
@Component
struct Index {
  private dietDao: DietDao = new DietDao()
  @State currentRecord: DietRecord = new DietRecord()
  @State userProfile: UserProfile = DatabaseHelper.getInstance().getUserProfile()
  @State showAddDialog: boolean = false
  @State foodName: string = ''
  @State calories: string = ''
  @State quantity: string = '1'
  @State selectedMealType: MealType = MealType.BREAKFAST
  @State currentTabIndex: number = 0

  aboutToAppear(): void {
    this.loadTodayRecord()
  }

  private loadTodayRecord(): void {
    let today = this.formatDate(new Date())
    let record = this.dietDao.findByDate(today)
    if (record) {
      this.currentRecord = record
    } else {
      this.currentRecord = new DietRecord({ id: `record-${today}`, date: today, foodItems: [] })
    }
  }

  private formatDate(date: Date): string {
    let year = date.getFullYear()
    let month = `${date.getMonth() + 1}`.padStart(2, '0')
    let day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  private saveFood(food: FoodItem): void {
    this.currentRecord = this.dietDao.appendFood(this.currentRecord.date, food)
    this.foodName = ''
    this.calories = ''
    this.quantity = '1'
    this.showAddDialog = false
  }

  @Builder
  tabContent() {
    Tabs({ index: this.currentTabIndex }) {
      // Tab 0: 今日记录
      TabContent() {
        this.homePage()
      }
      .tabBar(this.tabBarItem('首页', '🏠', 0))

      // Tab 1: 历史
      TabContent() {
        Text('历史')
          .onClick(() => router.pushUrl({ url: 'pages/History' }))
          .fontSize(16)
          .fontColor($r('app.color.primary'))
      }
      .tabBar(this.tabBarItem('历史', '📊', 1))
      .onAppear(() => {
        router.pushUrl({ url: 'pages/History' })
      })

      // Tab 2: 统计
      TabContent() {
        Text('统计')
          .fontSize(16)
          .fontColor($r('app.color.primary'))
      }
      .tabBar(this.tabBarItem('统计', '📈', 2))
      .onAppear(() => {
        router.pushUrl({ url: 'pages/Statistics' })
      })

      // Tab 3: 设置
      TabContent() {
        Text('设置')
          .fontSize(16)
          .fontColor($r('app.color.primary'))
      }
      .tabBar(this.tabBarItem('设置', '⚙️', 3))
      .onAppear(() => {
        router.pushUrl({ url: 'pages/Settings' })
      })
    }
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentTabIndex = index
    })
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
  }

  @Builder
  tabBarItem(label: string, icon: string, index: number) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(20)
      Text(label)
        .fontSize(10)
        .fontColor(this.currentTabIndex === index
          ? $r('app.color.primary')
          : $r('app.color.text_secondary'))
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentTabIndex === index
      ? $r('app.color.card_background')
      : $r('app.color.page_background'))
  }

  @Builder
  homePage() {
    let progress = NutritionCalculator.calorieProgress(this.currentRecord, this.userProfile)
    let macros = NutritionCalculator.macroDistribution(this.currentRecord)

    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 6 }) {
            Text('今日饮食')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .textAlign(TextAlign.Start)
            Text(this.currentRecord.date)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')

          Column({ space: 16 }) {
            CalorieRingChart({
              progress: progress,
              consumed: this.currentRecord.totalCalories(),
              target: this.userProfile.dailyCalorieGoal
            })
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(24)

          NutrientPieChart({
            proteinPercent: macros[0],
            carbPercent: macros[1],
            fatPercent: macros[2]
          })

          // 早餐
          MealSection({
            title: '早餐',
            mealColor: $r('app.color.breakfast'),
            foodsData: this.currentRecord.foodsByMeal(MealType.BREAKFAST)
          })

          // 午餐
          MealSection({
            title: '午餐',
            mealColor: $r('app.color.lunch'),
            foodsData: this.currentRecord.foodsByMeal(MealType.LUNCH)
          })

          // 晚餐
          MealSection({
            title: '晚餐',
            mealColor: $r('app.color.dinner'),
            foodsData: this.currentRecord.foodsByMeal(MealType.DINNER)
          })

          // 加餐
          MealSection({
            title: '加餐',
            mealColor: $r('app.color.snack'),
            foodsData: this.currentRecord.foodsByMeal(MealType.SNACK)
          })

          if (this.showAddDialog) {
            AddFoodDialog({
              isVisible: $showAddDialog,
              foodName: $foodName,
              calories: $calories,
              quantity: $quantity,
              mealType: $selectedMealType,
              onConfirm: (food: FoodItem) => this.saveFood(food)
            })
          }
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 100 })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .backgroundColor($r('app.color.page_background'))

      // 搜索食物 FAB
      Button('+ 添加食物')
        .height(48)
        .borderRadius(24)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .backgroundColor($r('app.color.primary'))
        .padding({ left: 20, right: 20 })
        .margin({ right: 20, bottom: 24 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/FoodSearch',
            params: { date: this.currentRecord.date, mealType: this.selectedMealType }
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  build() {
    this.tabContent()
  }
}
