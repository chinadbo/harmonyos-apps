import { DietDao } from '../database/DietDao'
import { DietRecord } from '../model/DietRecord'

@Entry
@Component
struct History {
  private dietDao: DietDao = new DietDao()
  @State records: DietRecord[] = []

  aboutToAppear(): void {
    this.records = this.dietDao.findAll()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('History')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Start)

        ForEach(this.records, (record: DietRecord) => {
          Column({ space: 10 }) {
            Row() {
              Text(record.date)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
              Blank()
              Text(`${record.totalCalories()} kcal`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.primary'))
            }
            .width('100%')

            Text(`Protein ${record.totalProtein()}g · Carbs ${record.totalCarbs()}g · Fat ${record.totalFat()}g · Fiber ${record.totalFiber()}g`)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')

            Text(record.note.length > 0 ? record.note : 'No notes')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
          }
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(20)
        })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
