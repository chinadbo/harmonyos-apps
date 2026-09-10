import router from '@ohos.router'
import { AppConstants, CUSTOM_WORKOUT_PLAN_ID, DEFAULT_CUSTOM_WORKOUT_PLAN, DEFAULT_WORKOUT_PLANS, WorkoutPlan } from '../common/constants'
import { AppStyles } from '../common/styles'
import { serializeWorkoutPlan } from '../common/utils'
import { timerService } from '../services/TimerService'

@Component
export struct WorkoutModePage {
  @StorageLink(AppConstants.STORAGE_SELECTED_WORKOUT_PLAN) selectedWorkoutPlanId: string = DEFAULT_WORKOUT_PLANS[0].id
  @StorageLink(AppConstants.STORAGE_CUSTOM_WORKOUT_PLAN) customWorkoutPlanJson: string = JSON.stringify(DEFAULT_CUSTOM_WORKOUT_PLAN)
  @State private customName: string = DEFAULT_CUSTOM_WORKOUT_PLAN.name
  @State private customDescription: string = DEFAULT_CUSTOM_WORKOUT_PLAN.description
  @State private intervalText: string = '30000,30000,60000'

  aboutToAppear(): void {
    try {
      const customPlan = JSON.parse(this.customWorkoutPlanJson) as WorkoutPlan
      this.customName = customPlan.name || DEFAULT_CUSTOM_WORKOUT_PLAN.name
      this.customDescription = customPlan.description || DEFAULT_CUSTOM_WORKOUT_PLAN.description
      this.intervalText = customPlan.intervals ? customPlan.intervals.join(',') : DEFAULT_CUSTOM_WORKOUT_PLAN.intervals.join(',')
    } catch (error) {
      this.customName = DEFAULT_CUSTOM_WORKOUT_PLAN.name
      this.customDescription = DEFAULT_CUSTOM_WORKOUT_PLAN.description
      this.intervalText = DEFAULT_CUSTOM_WORKOUT_PLAN.intervals.join(',')
    }
  }

  private async selectPlan(planId: string): Promise<void> {
    this.selectedWorkoutPlanId = planId
    await timerService.updateSetting(AppConstants.SETTING_SELECTED_WORKOUT_PLAN, planId)
  }

  private async saveCustomPlan(): Promise<void> {
    const intervals = this.intervalText
      .split(',')
      .map((item: string) => Number(item.trim()))
      .filter((item: number) => item > 0)
    const plan: WorkoutPlan = {
      id: CUSTOM_WORKOUT_PLAN_ID,
      name: this.customName.length > 0 ? this.customName : DEFAULT_CUSTOM_WORKOUT_PLAN.name,
      description: this.customDescription.length > 0 ? this.customDescription : DEFAULT_CUSTOM_WORKOUT_PLAN.description,
      intervals: intervals.length > 0 ? intervals : DEFAULT_CUSTOM_WORKOUT_PLAN.intervals
    }
    this.customWorkoutPlanJson = serializeWorkoutPlan(plan)
    await timerService.updateSetting(AppConstants.SETTING_CUSTOM_WORKOUT_PLAN, this.customWorkoutPlanJson)
    await this.selectPlan(CUSTOM_WORKOUT_PLAN_ID)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('Back')
            .backgroundColor('#FFFFFF')
            .fontColor('#1F2937')
            .onClick(() => router.back())
          Blank()
          Text('Workout mode')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
        }
        .width('100%')

        ForEach(DEFAULT_WORKOUT_PLANS, (plan: WorkoutPlan) => {
          Column({ space: 8 }) {
            Text(plan.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .width('100%')
              .textAlign(TextAlign.Start)
            Text(plan.description)
              .fontSize(14)
              .fontColor('#6B7280')
              .width('100%')
              .textAlign(TextAlign.Start)
            Text(plan.intervals.join(' / '))
              .fontSize(13)
              .fontColor('#6B7280')
              .width('100%')
              .textAlign(TextAlign.Start)
            Button(this.selectedWorkoutPlanId === plan.id ? 'Selected' : 'Use plan')
              .width('100%')
              .backgroundColor(this.selectedWorkoutPlanId === plan.id ? '#22C55E' : '#4F7AF7')
              .fontColor(Color.White)
              .onClick(() => this.selectPlan(plan.id))
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .alignItems(HorizontalAlign.Start)
        }, (plan: WorkoutPlan) => plan.id)

        Column({ space: 10 }) {
          Text('Custom plan')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .width('100%')
            .textAlign(TextAlign.Start)
          TextInput({ text: this.customName, placeholder: 'Plan name' })
            .backgroundColor('#F3F5F7')
            .borderRadius(16)
            .onChange((value: string) => this.customName = value)
          TextInput({ text: this.customDescription, placeholder: 'Short description' })
            .backgroundColor('#F3F5F7')
            .borderRadius(16)
            .onChange((value: string) => this.customDescription = value)
          TextInput({ text: this.intervalText, placeholder: 'Intervals in ms, comma separated' })
            .backgroundColor('#F3F5F7')
            .borderRadius(16)
            .onChange((value: string) => this.intervalText = value)
          Button(this.selectedWorkoutPlanId === CUSTOM_WORKOUT_PLAN_ID ? 'Saved custom plan selected' : 'Save custom plan')
            .width('100%')
            .backgroundColor('#111827')
            .fontColor(Color.White)
            .onClick(() => this.saveCustomPlan())
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(AppStyles.PAGE_HORIZONTAL_PADDING)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.BACKGROUND_COLOR)
  }
}
