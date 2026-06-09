import { Medicine } from '../models/MedicineModel'
import { Schedule, createEmptySchedule, ScheduleFrequency } from '../models/ScheduleModel'
import { pillDatabase } from '../services/PillDatabase'
import { reminderService } from '../services/ReminderService'

@Entry
@Component
struct SchedulePage {
  @State medicines: Medicine[] = []
  @State selectedMedicineId: number = 0
  @State schedule: Schedule = createEmptySchedule()
  @State selectedWeekDays: number[] = []

  async aboutToAppear() {
    this.medicines = await pillDatabase.getMedicines()
    if (this.medicines.length > 0) {
      this.selectedMedicineId = this.medicines[0].id
      this.schedule.medicineId = this.medicines[0].id
    }
  }

  toggleWeekDay(day: number) {
    const index = this.selectedWeekDays.indexOf(day)
    if (index >= 0) {
      this.selectedWeekDays.splice(index, 1)
    } else {
      this.selectedWeekDays.push(day)
    }
    this.selectedWeekDays = [...this.selectedWeekDays]
    this.schedule.weekDays = this.selectedWeekDays.sort((a, b) => a - b).join(',')
  }

  async saveSchedule() {
    if (this.selectedMedicineId <= 0) {
      return
    }
    this.schedule.medicineId = this.selectedMedicineId

    const medicine = this.medicines.find((m) => m.id === this.selectedMedicineId)
    if (!medicine) {
      return
    }

    // Save schedule first to get ID
    const scheduleId = await pillDatabase.saveSchedule(this.schedule)
    this.schedule.id = scheduleId

    // Create reminder
    try {
      const reminderId = await reminderService.createReminder(this.schedule, medicine)
      await pillDatabase.updateScheduleReminder(scheduleId, reminderId)
    } catch (err) {
      console.error('Failed to create reminder:', JSON.stringify(err))
    }

    this.getUIContext().getRouter().back()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Text('添加服用计划')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .padding(16)

        List() {
          ListItem() {
            Column() {
              // Medicine selector
              this.FormRow('选择药品', () => {
                if (this.medicines.length === 0) {
                  Text('请先添加药品')
                    .fontSize(14)
                    .fontColor('#FF5722')
                } else {
                  Select(this.medicines.map((m) => ({ value: m.name })))
                    .selected(this.medicines.findIndex((m) => m.id === this.selectedMedicineId))
                    .onSelect((index: number) => {
                      this.selectedMedicineId = this.medicines[index].id
                    })
                }
              })

              // Time picker
              this.FormRow('服用时间', () => {
                TimePicker({ selected: new Date(0, 0, 0, this.schedule.hour, this.schedule.minute) })
                  .useMilitaryTime(true)
                  .onChange((value: TimePickerResult) => {
                    this.schedule.hour = value.hour
                    this.schedule.minute = value.minute
                  })
              })

              // Dose
              this.FormRow('剂量', () => {
                TextInput({ text: this.schedule.dose })
                  .placeholder('如：1、0.5')
                  .onChange((value) => this.schedule.dose = value)
              })

              // Frequency
              this.FormRow('频率', () => {
                Row() {
                  this.FreqButton('每日', 'DAILY')
                  this.FreqButton('隔日', 'EVERY_OTHER_DAY')
                  this.FreqButton('每周', 'WEEKLY')
                }
                .width('100%')
              })

              // Week days selector
              if (this.schedule.frequency === 'WEEKLY') {
                this.FormRow('选择星期', () => {
                  Row() {
                    ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
                      Button(['一', '二', '三', '四', '五', '六', '日'][day - 1], { type: ButtonType.Circle })
                        .width(36)
                        .height(36)
                        .fontSize(12)
                        .fontColor(this.selectedWeekDays.includes(day) ? Color.White : '#666666')
                        .backgroundColor(this.selectedWeekDays.includes(day) ? '#2196F3' : '#F5F5F5')
                        .onClick(() => this.toggleWeekDay(day))
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
          .padding({ left: 16, right: 16, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // Action buttons
        Row() {
          Button('取消', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .onClick(() => {
              this.getUIContext().getRouter().back()
            })

          Blank().width(16)

          Button('保存', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#2196F3')
            .layoutWeight(1)
            .onClick(() => this.saveSchedule())
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }

  @Builder
  FormRow(label: string, content: () => void) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 4 })

      content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder
  FreqButton(label: string, value: ScheduleFrequency) {
    Button(label, { type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.TEXTUAL })
      .fontSize(12)
      .fontColor(this.schedule.frequency === value ? Color.White : '#666666')
      .backgroundColor(this.schedule.frequency === value ? '#2196F3' : '#F5F5F5')
      .padding({ left: 12, right: 12 })
      .margin({ right: 8 })
      .onClick(() => {
        this.schedule.frequency = value
      })
  }
}
