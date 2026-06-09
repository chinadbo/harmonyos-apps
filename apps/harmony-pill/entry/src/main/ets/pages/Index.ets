import { Medicine } from '../models/MedicineModel'
import { TodayScheduleItem, pillDatabase } from '../services/PillDatabase'
import { RecordItem, createRecordItem } from '../models/RecordModel'
import { reminderService } from '../services/ReminderService'
import { ProgressRing } from '../components/ProgressRing'
import { ScheduleItem } from '../components/ScheduleItem'

@Entry
@Component
struct Index {
  @State todayItems: TodayScheduleItem[] = []
  @State progress: number = 0
  @State currentDate: string = ''

  private getTodayDate(): string {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }

  private getWeekDay(): number {
    const d = new Date()
    const day = d.getDay()
    return day === 0 ? 7 : day
  }

  async aboutToAppear() {
    this.currentDate = this.getTodayDate()
    await this.loadTodayItems()
  }

  async loadTodayItems() {
    this.todayItems = await pillDatabase.getTodayScheduleItems(this.currentDate, this.getWeekDay())
    this.calculateProgress()
  }

  calculateProgress() {
    if (this.todayItems.length === 0) {
      this.progress = 0
      return
    }
    const taken = this.todayItems.filter((item) => item.record && item.record.status === 1).length
    this.progress = Math.round(taken * 100 / this.todayItems.length)
  }

  async handleCheckIn(item: TodayScheduleItem) {
    const now = new Date()
    const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`
    const record: RecordItem = {
      ...createRecordItem(),
      medicineId: item.medicine.id,
      scheduleId: item.schedule.id,
      date: this.currentDate,
      time: timeStr,
      dose: item.schedule.dose,
      status: 1
    }
    await pillDatabase.saveRecord(record)

    // Update stock
    if (item.medicine.stock > 0) {
      const doseNum = parseFloat(item.schedule.dose) || 1
      item.medicine.stock = Math.max(0, item.medicine.stock - doseNum)
      await pillDatabase.saveMedicine(item.medicine)
    }

    await this.loadTodayItems()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Column() {
            Text('今日服药')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text(this.currentDate)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          ProgressRing({ progress: this.progress, size: 70, strokeWidth: 6 })
        }
        .width('100%')
        .padding(16)

        // Schedule list
        List() {
          if (this.todayItems.length === 0) {
            ListItem() {
              Column() {
                Text('暂无服药计划')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 40 })

                Text('点击下方"药品"添加药品和计划')
                  .fontSize(12)
                  .fontColor('#CCCCCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .padding(32)
            }
          } else {
            ForEach(this.todayItems, (item: TodayScheduleItem) => {
              ListItem() {
                ScheduleItem({
                  medicine: item.medicine,
                  schedule: item.schedule,
                  record: item.record,
                  onCheckIn: () => this.handleCheckIn(item)
                })
              }
              .padding({ left: 16, right: 16, bottom: 8 })
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // Bottom Tab Bar
        Row() {
          this.TabItem('今日', true)
          this.TabItem('药品', false, () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/MedicineListPage' })
          })
          this.TabItem('日历', false, () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/CalendarPage' })
          })
          this.TabItem('统计', false, () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/StatsPage' })
          })
        }
        .width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: -2 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }

  @Builder
  TabItem(label: string, active: boolean, onClick?: () => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(active ? '#2196F3' : '#999999')
        .fontWeight(active ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (onClick) {
        onClick()
      }
    })
  }
}
