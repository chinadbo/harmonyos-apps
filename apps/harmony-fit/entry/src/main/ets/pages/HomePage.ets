import promptAction from '@ohos.promptAction'
import { DatabaseService } from '../service/DatabaseService'
import { PreferencesService } from '../service/PreferencesService'
import { SensorService } from '../service/SensorService'
import { HomeViewModel } from '../viewmodel/HomeViewModel'
import { RingProgressChart } from '../components/RingProgressChart'
import { AddWorkoutDialog } from '../components/AddWorkoutDialog'
import { WorkoutRecord } from '../model/WorkoutRecord'

@Component
export struct HomePage {
  private viewModel: HomeViewModel = new HomeViewModel()
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: AddWorkoutDialog({
      confirm: (record: WorkoutRecord) => {
        this.handleAddRecord(record)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  @State private todayText: string = ''
  @State private greeting: string = ''
  @State private steps: number = 0
  @State private calories: number = 0
  @State private duration: number = 0
  @State private stepGoal: number = 8000
  @State private calorieGoal: number = 500
  @State private isListening: boolean = false

  async aboutToAppear(): Promise<void> {
    await this.loadPageData()
    SensorService.getInstance().setStepCallback((steps: number) => {
      this.steps = steps
      this.isListening = SensorService.getInstance().getListeningState()
    })
  }

  async onPageShow(): Promise<void> {
    await this.loadPageData()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 6 }) {
            Text(this.todayText)
              .fontSize(14)
              .fontColor('#A9B4C8')
            Text(this.greeting)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 16 }) {
            RingProgressChart({
              progress: this.stepGoal > 0 ? this.steps / this.stepGoal : 0,
              currentValue: this.steps,
              targetValue: this.stepGoal,
              unit: '步',
              primaryColor: '#69F0AE'
            })

            Row({ space: 14 }) {
              this.buildMetricCard('消耗热量', `${this.calories}`, `目标 ${this.calorieGoal} 千卡`, '#FF8A65')
              this.buildMetricCard('运动时长', `${this.duration}`, '分钟', '#4FC3F7')
            }
            .width('100%')

            Row({ space: 8 }) {
              Circle()
                .width(10)
                .height(10)
                .fill(this.isListening ? '#4ADE80' : '#F59E0B')
              Text(this.isListening ? '计步中' : '计步未启动')
                .fontSize(14)
                .fontColor('#D6DEEB')
            }
            .width('100%')
          }
          .padding(20)
          .width('100%')
          .backgroundColor('#162033')
          .borderRadius(28)
        }
        .padding({ left: 16, right: 16, top: 18, bottom: 96 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0F172A')

      Button('+')
        .width(56)
        .height(56)
        .borderRadius(28)
        .fontSize(28)
        .fontColor('#FFFFFF')
        .backgroundColor('#4F46E5')
        .margin({ right: 20, bottom: 24 })
        .onClick(() => {
          this.dialogController.open()
        })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildMetricCard(title: string, value: string, subtitle: string, color: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#9FB0CB')
      Text(value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Text(subtitle)
        .fontSize(12)
        .fontColor(color)
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding(16)
    .height(118)
    .backgroundColor('#1E293B')
    .borderRadius(20)
  }

  private async loadPageData(): Promise<void> {
    try {
      const now = new Date()
      this.todayText = `${now.getFullYear()}-${`${now.getMonth() + 1}`.padStart(2, '0')}-${`${now.getDate()}`.padStart(2, '0')}`
      this.greeting = this.resolveGreeting(now.getHours())
      this.stepGoal = await PreferencesService.getInstance().getStepGoal()
      this.calorieGoal = await PreferencesService.getInstance().getCalorieGoal()
      await this.viewModel.loadTodayData()
      this.steps = this.viewModel.getTodaySteps()
      this.calories = this.viewModel.getTodayCalories()
      this.duration = this.viewModel.getTodayDuration()
      this.isListening = SensorService.getInstance().getListeningState()
    } catch (error) {
      promptAction.showToast({ message: '加载失败' })
      console.error(`loadPageData failed: ${JSON.stringify(error)}`)
    }
  }

  private async handleAddRecord(record: WorkoutRecord): Promise<void> {
    try {
      const id = await DatabaseService.getInstance().insertRecord(record)
      record.id = id
      await this.loadPageData()
      promptAction.showToast({ message: '保存成功' })
    } catch (error) {
      promptAction.showToast({ message: '保存失败' })
      console.error(`handleAddRecord failed: ${JSON.stringify(error)}`)
    }
  }

  private resolveGreeting(hour: number): string {
    if (hour < 12) {
      return '早上好，开始今天的运动吧'
    }
    if (hour < 18) {
      return '下午好，继续保持节奏'
    }
    return '晚上好，看看今天的成果'
  }
}
