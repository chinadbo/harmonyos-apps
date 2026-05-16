import { WorkoutRecord } from '../model/WorkoutRecord'
import { WORKOUT_TYPE_MAP, WorkoutType } from '../model/WorkoutType'

@CustomDialog
export struct AddWorkoutDialog {
  controller?: CustomDialogController
  confirm: (record: WorkoutRecord) => void = () => {}
  @State private selectedType: WorkoutType = WorkoutType.WALK
  @State private durationText: string = '30'
  @State private caloriesText: string = '120'
  @State private stepsText: string = ''
  @State private noteText: string = ''

  private workoutTypes: WorkoutType[] = [
    WorkoutType.WALK,
    WorkoutType.RUN,
    WorkoutType.CYCLING,
    WorkoutType.SWIM,
    WorkoutType.GYM,
    WorkoutType.OTHER
  ]

  build() {
    Column({ space: 16 }) {
      Text('新增运动记录')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')

      Text('选择运动类型')
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')

      Grid() {
        ForEach(this.workoutTypes, (type: WorkoutType) => {
          GridItem() {
            this.buildTypeItem(type)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .height(156)

      TextInput({ text: this.durationText, placeholder: '输入时长（分钟）' })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.durationText = value
          this.autoUpdateCalories()
        })
        .width('100%')
        .height(48)
        .backgroundColor('#F4F6F8')
        .borderRadius(14)

      TextInput({ text: this.caloriesText, placeholder: '输入卡路里' })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.caloriesText = value
        })
        .width('100%')
        .height(48)
        .backgroundColor('#F4F6F8')
        .borderRadius(14)

      TextInput({ text: this.stepsText, placeholder: '输入步数（可选）' })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.stepsText = value
        })
        .width('100%')
        .height(48)
        .backgroundColor('#F4F6F8')
        .borderRadius(14)

      TextInput({ text: this.noteText, placeholder: '输入备注（可选）' })
        .onChange((value: string) => {
          this.noteText = value
        })
        .width('100%')
        .height(48)
        .backgroundColor('#F4F6F8')
        .borderRadius(14)

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#EEF2F7')
          .fontColor('#374151')
          .onClick(() => {
            this.controller?.close()
          })

        Button('确认')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#4F46E5')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.submit()
          })
      }
      .width('100%')
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .width('92%')
  }

  @Builder
  private buildTypeItem(type: WorkoutType) {
    const info = WORKOUT_TYPE_MAP.get(type)
    const selected = this.selectedType === type
    Column({ space: 8 }) {
      Text(info?.icon ?? '🏅')
        .fontSize(24)
      Text(info?.name ?? '')
        .fontSize(13)
        .fontColor(selected ? '#FFFFFF' : '#1F2937')
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(72)
    .backgroundColor(selected ? (info?.color ?? '#4F46E5') : '#F4F6F8')
    .borderRadius(16)
    .onClick(() => {
      this.selectedType = type
      this.autoUpdateCalories()
    })
  }

  private autoUpdateCalories(): void {
    const duration = Number(this.durationText)
    if (duration <= 0 || Number.isNaN(duration)) {
      return
    }
    let rate = 4
    if (this.selectedType === WorkoutType.RUN) {
      rate = 8
    } else if (this.selectedType === WorkoutType.CYCLING) {
      rate = 7
    } else if (this.selectedType === WorkoutType.SWIM) {
      rate = 9
    } else if (this.selectedType === WorkoutType.GYM) {
      rate = 6
    }
    this.caloriesText = `${duration * rate}`
  }

  private submit(): void {
    const now = new Date()
    const duration = Number(this.durationText)
    const calories = Number(this.caloriesText)
    const steps = this.stepsText.trim().length > 0 ? Number(this.stepsText) : 0
    const record: WorkoutRecord = {
      type: this.selectedType,
      duration: Number.isNaN(duration) ? 0 : duration,
      calories: Number.isNaN(calories) ? 0 : calories,
      steps: Number.isNaN(steps) ? 0 : steps,
      date: this.formatDate(now),
      startTime: now.getTime(),
      note: this.noteText.trim()
    }
    this.confirm(record)
    this.controller?.close()
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
