import { CalendarStatusItem, pillDatabase } from '../services/PillDatabase'
import { CalendarView } from '../components/CalendarView'
import { RecordItem } from '../models/RecordModel'

@Entry
@Component
struct CalendarPage {
  @State currentYear: number = new Date().getFullYear()
  @State currentMonth: number = new Date().getMonth() + 1
  @State statusList: CalendarStatusItem[] = []
  @State selectedDate: string = ''
  @State dayRecords: RecordItem[] = []

  async aboutToAppear() {
    await this.loadMonthData()
    this.selectedDate = this.getTodayDate()
    await this.loadDayRecords()
  }

  getTodayDate(): string {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }

  async loadMonthData() {
    const yearMonth = `${this.currentYear}-${String(this.currentMonth).padStart(2, '0')}`
    this.statusList = await pillDatabase.getCalendarStatus(yearMonth)
  }

  async loadDayRecords() {
    if (this.selectedDate) {
      this.dayRecords = await pillDatabase.getRecordsByDate(this.selectedDate)
    }
  }

  async prevMonth() {
    if (this.currentMonth === 1) {
      this.currentMonth = 12
      this.currentYear--
    } else {
      this.currentMonth--
    }
    await this.loadMonthData()
  }

  async nextMonth() {
    if (this.currentMonth === 12) {
      this.currentMonth = 1
      this.currentYear++
    } else {
      this.currentMonth++
    }
    await this.loadMonthData()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Button('<', { type: ButtonType.Circle })
            .width(32)
            .height(32)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .onClick(() => this.prevMonth())

          Text(`${this.currentYear}年${this.currentMonth}月`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('>', { type: ButtonType.Circle })
            .width(32)
            .height(32)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .onClick(() => this.nextMonth())
        }
        .width('100%')
        .padding(16)

        // Calendar
        CalendarView({
          year: this.currentYear,
          month: this.currentMonth,
          statusList: this.statusList,
          onDateSelect: async (date: string) => {
            this.selectedDate = date
            await this.loadDayRecords()
          }
        })
        .padding({ left: 16, right: 16 })

        // Selected date records
        if (this.selectedDate) {
          Column() {
            Row() {
              Text(`${this.selectedDate} 记录`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .padding({ bottom: 8 })

            if (this.dayRecords.length === 0) {
              Text('当日无记录')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(16)
            } else {
              ForEach(this.dayRecords, (record: RecordItem) => {
                Row() {
                  Column() {
                    Text(record.time)
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .layoutWeight(1)

                  Text(record.status === 1 ? '已服用' : record.status === 2 ? '已跳过' : '未知')
                    .fontSize(12)
                    .fontColor(record.status === 1 ? '#4CAF50' : '#FF5722')
                    .backgroundColor(record.status === 1 ? '#E8F5E9' : '#FFEBEE')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4)
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FAFAFA')
                .borderRadius(8)
                .margin({ bottom: 4 })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 8, left: 16, right: 16 })
        }

        // Back button
        Row() {
          Button('返回首页', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor('#2196F3')
            .backgroundColor('#E3F2FD')
            .onClick(() => {
              this.getUIContext().getRouter().back()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }
}
