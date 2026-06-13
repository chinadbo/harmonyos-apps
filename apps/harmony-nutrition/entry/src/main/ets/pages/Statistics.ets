import { TrendLineChart } from '../components/TrendLineChart'
import { DietDao } from '../database/DietDao'
import { DietRecord } from '../model/DietRecord'
import { NutritionCalculator } from '../service/NutritionCalculator'

@Entry
@Component
struct Statistics {
  private dietDao: DietDao = new DietDao()
  @State records: DietRecord[] = []

  aboutToAppear(): void {
    this.records = this.dietDao.findAll()
  }

  build() {
    let values = this.records.slice(0, 7).reverse().map((record: DietRecord) => record.totalCalories())
    let averageCalories = NutritionCalculator.averageCalories(this.records)

    Scroll() {
      Column({ space: 16 }) {
        Text('Statistics')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Start)

        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text('Average Calories')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Text(`${averageCalories} kcal`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)

          Column({ space: 8 }) {
            Text('Tracked Days')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Text(`${this.records.length}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)
        }
        .width('100%')

        TrendLineChart({ values: values.length > 0 ? values : [0, 0, 0, 0, 0, 0, 0] })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
