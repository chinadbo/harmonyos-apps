import { CalendarStatusItem } from '../services/PillDatabase'

@Component
export struct CalendarView {
  @Prop year: number
  @Prop month: number
  @Prop statusList: CalendarStatusItem[] = []
  onDateSelect?: (date: string) => void

  private getDaysInMonth(): number {
    return new Date(this.year, this.month, 0).getDate()
  }

  private getFirstDayOfWeek(): number {
    const day = new Date(this.year, this.month - 1, 1).getDay()
    return day === 0 ? 7 : day
  }

  private getStatus(day: number): CalendarStatusItem | undefined {
    const dateStr = `${this.year}-${String(this.month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    return this.statusList.find((item) => item.date === dateStr)
  }

  build() {
    Column() {
      Row() {
        Text('一')
        Text('二')
        Text('三')
        Text('四')
        Text('五')
        Text('六')
        Text('日')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 8, bottom: 8 })

      Grid() {
        // Empty cells for padding
        ForEach(Array.from({ length: this.getFirstDayOfWeek() - 1 }, (_, i) => i), (item: number) => {
          GridItem() {
            Text('')
              .width(40)
              .height(40)
          }
        })

        ForEach(Array.from({ length: this.getDaysInMonth() }, (_, i) => i + 1), (day: number) => {
          GridItem() {
            Column() {
              Text(`${day}`)
                .fontSize(14)
                .fontColor('#333333')
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)

              Row() {
                const status = this.getStatus(day)
                if (status?.hasTaken) {
                  Circle()
                    .width(6)
                    .height(6)
                    .fill('#4CAF50')
                }
                if (status?.hasMissed) {
                  Circle()
                    .width(6)
                    .height(6)
                    .fill('#FF5722')
                    .margin({ left: 2 })
                }
              }
              .height(8)
              .justifyContent(FlexAlign.Center)
            }
            .width(44)
            .height(48)
            .justifyContent(FlexAlign.Center)
          }
          .onClick(() => {
            const dateStr = `${this.year}-${String(this.month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
            if (this.onDateSelect) {
              this.onDateSelect(dateStr)
            }
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(4)
      .rowsGap(4)
      .width('100%')
    }
    .width('100%')
    .padding(8)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
