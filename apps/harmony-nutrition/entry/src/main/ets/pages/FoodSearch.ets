import { FoodCard } from '../components/FoodCard'
import { FoodDatabase } from '../service/FoodDatabase'
import { FoodItem } from '../model/FoodItem'

@Entry
@Component
struct FoodSearch {
  private foodDatabase: FoodDatabase = new FoodDatabase()
  @State keyword: string = ''
  @State foodItems: FoodItem[] = []

  aboutToAppear(): void {
    this.foodItems = this.foodDatabase.search('')
  }

  private refresh(): void {
    this.foodItems = this.foodDatabase.search(this.keyword)
  }

  build() {
    Column({ space: 16 }) {
      Text('Food Search')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ top: 20, left: 16, right: 16 })

      TextInput({ text: this.keyword, placeholder: 'Search food name or category' })
        .onChange((value: string) => {
          this.keyword = value
          this.refresh()
        })
        .margin({ left: 16, right: 16 })
        .height(48)
        .backgroundColor($r('app.color.card_background'))

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.foodItems, (item: FoodItem) => {
            FoodCard({ foodItem: item })
          })
        }
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
