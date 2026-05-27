import { Project } from '../model/Project'
import { DatabaseHelper } from '../database/DatabaseHelper'
import router from '@ohos.router'

@Entry
@Component
struct AddEntryPage {
  @State projects: Project[] = []
  @State selectedProjectId: number = -1
  @State startDate: Date = new Date()
  @State endDate: Date = new Date()
  @State note: string = ''
  @State showStartDatePicker: boolean = false
  @State showStartTimePicker: boolean = false
  @State showEndDatePicker: boolean = false
  @State showEndTimePicker: boolean = false

  aboutToAppear(): void {
    this.loadProjects()
    // Default: end = now, start = 1 hour ago
    const now = new Date()
    this.endDate = now
    this.startDate = new Date(now.getTime() - 3600000)
  }

  private async loadProjects(): Promise<void> {
    const db = DatabaseHelper.getInstance()
    this.projects = await db.getAllProjects()
    if (this.projects.length > 0) {
      this.selectedProjectId = this.projects[0].id
    }
  }

  private formatDate(date: Date): string {
    const y = date.getFullYear()
    const m = this.pad(date.getMonth() + 1)
    const d = this.pad(date.getDate())
    return `${y}-${m}-${d}`
  }

  private formatTime(date: Date): string {
    return `${this.pad(date.getHours())}:${this.pad(date.getMinutes())}`
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }

  private async save(): Promise<void> {
    if (this.selectedProjectId === -1) {
      return
    }
    const startTime = this.startDate.getTime()
    const endTime = this.endDate.getTime()
    if (endTime <= startTime) {
      return
    }
    const duration = Math.floor((endTime - startTime) / 1000)

    const db = DatabaseHelper.getInstance()
    await db.createManualTimeEntry(this.selectedProjectId, startTime, endTime, duration, this.note)
    await db.addProjectTime(this.selectedProjectId, duration)

    router.back()
  }

  build() {
    Column() {
      // Top bar
      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .fontColor('#999999')
          .onClick(() => {
            router.back()
          })

        Text('手动添加')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .fontColor('#4FC3F7')
          .onClick(() => {
            this.save()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // Project selector
          Column() {
            Text('选择项目')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            Select(this.projects.map(p => {
              let selectOption: SelectOption = { value: p.name }
              return selectOption
            }))
              .selected(this.projects.findIndex(p => p.id === this.selectedProjectId))
              .value(this.projects.find(p => p.id === this.selectedProjectId)?.name ?? '请选择')
              .width('100%')
              .height(44)
              .onSelect((index: number) => {
                if (index >= 0 && index < this.projects.length) {
                  this.selectedProjectId = this.projects[index].id
                }
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16 })

          // Start time
          Column() {
            Text('开始时间')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            Row() {
              Text(this.formatDate(this.startDate))
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)

              Text(this.formatTime(this.startDate))
                .fontSize(16)
                .fontColor('#4FC3F7')
            }
            .width('100%')
            .height(44)

            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2030-12-31'),
              selected: this.startDate
            })
              .onChange((value: DatePickerResult) => {
                const d = this.startDate
                d.setFullYear(value.year)
                d.setMonth(value.month)
                d.setDate(value.day)
                this.startDate = new Date(d.getTime())
              })

            TimePicker({ selected: this.startDate })
              .useMilitaryTime(true)
              .onChange((value: TimePickerResult) => {
                const d = this.startDate
                d.setHours(value.hour)
                d.setMinutes(value.minute)
                this.startDate = new Date(d.getTime())
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 12 })

          // End time
          Column() {
            Text('结束时间')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            Row() {
              Text(this.formatDate(this.endDate))
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)

              Text(this.formatTime(this.endDate))
                .fontSize(16)
                .fontColor('#4FC3F7')
            }
            .width('100%')
            .height(44)

            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2030-12-31'),
              selected: this.endDate
            })
              .onChange((value: DatePickerResult) => {
                const d = this.endDate
                d.setFullYear(value.year)
                d.setMonth(value.month)
                d.setDate(value.day)
                this.endDate = new Date(d.getTime())
              })

            TimePicker({ selected: this.endDate })
              .useMilitaryTime(true)
              .onChange((value: TimePickerResult) => {
                const d = this.endDate
                d.setHours(value.hour)
                d.setMinutes(value.minute)
                this.endDate = new Date(d.getTime())
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 12 })

          // Note
          Column() {
            Text('备注')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            TextInput({ placeholder: '输入备注（可选）', text: this.note })
              .width('100%')
              .height(44)
              .onChange((value: string) => {
                this.note = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 12 })
        }
        .padding({ left: 16, right: 16, bottom: 32 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
