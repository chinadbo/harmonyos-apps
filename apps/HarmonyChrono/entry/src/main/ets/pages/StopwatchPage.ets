import router from '@ohos.router'
import { CircularProgress } from '../components/CircularProgress'
import { LapItem } from '../components/LapItem'
import { TimerDisplay } from '../components/TimerDisplay'
import { AppConstants, CUSTOM_WORKOUT_PLAN_ID, DEFAULT_CUSTOM_WORKOUT_PLAN, DEFAULT_WORKOUT_PLANS, LapRecord, TimerStatus, WorkoutPlan } from '../common/constants'
import { AppStyles } from '../common/styles'
import { getLapStats, parseWorkoutPlan } from '../common/utils'
import { timerService } from '../services/TimerService'

@Entry
@Component
struct StopwatchPage {
  @StorageLink(AppConstants.STORAGE_TIMER_STATUS) timerStatus: TimerStatus = TimerStatus.IDLE
  @StorageLink(AppConstants.STORAGE_ELAPSED_MS) elapsedMilliseconds: number = 0
  @StorageLink(AppConstants.STORAGE_LAPS) laps: LapRecord[] = []
  @StorageLink(AppConstants.STORAGE_SELECTED_WORKOUT_PLAN) selectedWorkoutPlanId: string = DEFAULT_WORKOUT_PLANS[0].id
  @StorageLink(AppConstants.STORAGE_CUSTOM_WORKOUT_PLAN) customWorkoutPlanJson: string = JSON.stringify(DEFAULT_CUSTOM_WORKOUT_PLAN)
  @StorageLink(AppConstants.STORAGE_ACTIVE_INTERVAL_INDEX) activeIntervalIndex: number = 0
  @StorageLink(AppConstants.STORAGE_ACTIVE_INTERVAL_PROGRESS) activeIntervalProgress: number = 0

  private async handlePrimaryAction(): Promise<void> {
    if (this.timerStatus === TimerStatus.RUNNING) {
      await timerService.pause()
      return
    }
    await timerService.startOrResume()
  }

  private async handleLap(): Promise<void> {
    await timerService.recordLap()
  }

  private async handleReset(): Promise<void> {
    await timerService.reset()
  }

  private getPrimaryLabel(): string {
    if (this.timerStatus === TimerStatus.RUNNING) {
      return 'Pause'
    }
    if (this.timerStatus === TimerStatus.PAUSED) {
      return 'Resume'
    }
    return 'Start'
  }

  private getSelectedPlan(): WorkoutPlan {
    if (this.selectedWorkoutPlanId === CUSTOM_WORKOUT_PLAN_ID) {
      return parseWorkoutPlan(this.customWorkoutPlanJson)
    }
    for (let index = 0; index < DEFAULT_WORKOUT_PLANS.length; index++) {
      if (DEFAULT_WORKOUT_PLANS[index].id === this.selectedWorkoutPlanId) {
        return DEFAULT_WORKOUT_PLANS[index]
      }
    }
    return DEFAULT_WORKOUT_PLANS[0]
  }

  build() {
    const lapStats = getLapStats(this.laps)
    const selectedPlan = this.getSelectedPlan()
    Column({ space: AppStyles.LARGE_GAP }) {
      Column({ space: 6 }) {
        Text('HarmonyChrono')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppConstants.TEXT_PRIMARY)
          .width('100%')
          .textAlign(TextAlign.Start)
        Text(selectedPlan.name)
          .fontSize(14)
          .fontColor(AppConstants.TEXT_SECONDARY)
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Stack({ alignContent: Alignment.Center }) {
        CircularProgress({
          size: AppStyles.PROGRESS_SIZE,
          progress: this.activeIntervalProgress,
          color: this.timerStatus === TimerStatus.RUNNING ? AppConstants.RUNNING_COLOR : AppConstants.BRAND_COLOR
        })
        Column({ space: 8 }) {
          TimerDisplay({
            elapsedMilliseconds: this.elapsedMilliseconds,
            running: this.timerStatus === TimerStatus.RUNNING
          })
          Text(this.timerStatus === TimerStatus.RUNNING ? 'Running' : this.timerStatus === TimerStatus.PAUSED ? 'Paused' : 'Ready')
            .fontSize(14)
            .fontColor(AppConstants.TEXT_SECONDARY)
          Text(`Interval ${this.activeIntervalIndex + 1}/${selectedPlan.intervals.length}`)
            .fontSize(13)
            .fontColor(AppConstants.TEXT_SECONDARY)
        }
      }
      .width('100%')

      Row({ space: AppStyles.MEDIUM_GAP }) {
        Button(this.getPrimaryLabel())
          .layoutWeight(1)
          .height(AppStyles.CONTROL_BUTTON_HEIGHT)
          .backgroundColor(this.timerStatus === TimerStatus.RUNNING ? AppConstants.PAUSED_COLOR : AppConstants.RUNNING_COLOR)
          .fontColor(Color.White)
          .onClick(() => {
            this.handlePrimaryAction()
          })
        Button('Lap')
          .layoutWeight(1)
          .height(AppStyles.CONTROL_BUTTON_HEIGHT)
          .backgroundColor(AppConstants.BRAND_COLOR)
          .fontColor(Color.White)
          .enabled(this.timerStatus === TimerStatus.RUNNING)
          .opacity(this.timerStatus === TimerStatus.RUNNING ? 1 : 0.45)
          .onClick(() => {
            this.handleLap()
          })
        Button('Reset')
          .layoutWeight(1)
          .height(AppStyles.CONTROL_BUTTON_HEIGHT)
          .backgroundColor(AppConstants.SURFACE_ALT_COLOR)
          .fontColor(AppConstants.TEXT_PRIMARY)
          .onClick(() => {
            this.handleReset()
          })
      }
      .width('100%')

      Row({ space: AppStyles.MEDIUM_GAP }) {
        Button('History')
          .layoutWeight(1)
          .height(AppStyles.NAV_BUTTON_HEIGHT)
          .backgroundColor(AppConstants.SURFACE_COLOR)
          .fontColor(AppConstants.TEXT_PRIMARY)
          .onClick(() => router.pushUrl({ url: 'pages/HistoryPage' }))
        Button('Workout')
          .layoutWeight(1)
          .height(AppStyles.NAV_BUTTON_HEIGHT)
          .backgroundColor(AppConstants.SURFACE_COLOR)
          .fontColor(AppConstants.TEXT_PRIMARY)
          .onClick(() => router.pushUrl({ url: 'pages/WorkoutModePage' }))
        Button('Settings')
          .layoutWeight(1)
          .height(AppStyles.NAV_BUTTON_HEIGHT)
          .backgroundColor(AppConstants.SURFACE_COLOR)
          .fontColor(AppConstants.TEXT_PRIMARY)
          .onClick(() => router.pushUrl({ url: 'pages/SettingsPage' }))
      }
      .width('100%')

      Column({ space: AppStyles.MEDIUM_GAP }) {
        Row() {
          Text('Laps')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppConstants.TEXT_PRIMARY)
          Blank()
          Text(`${this.laps.length}`)
            .fontSize(14)
            .fontColor(AppConstants.TEXT_SECONDARY)
        }
        .width('100%')

        if (this.laps.length === 0) {
          Text('Tap Lap while the stopwatch is running to capture split times.')
            .fontSize(14)
            .fontColor(AppConstants.TEXT_SECONDARY)
            .width('100%')
            .textAlign(TextAlign.Start)
            .padding(16)
            .backgroundColor(AppConstants.SURFACE_COLOR)
            .borderRadius(20)
        } else {
          Scroll() {
            Column({ space: AppStyles.SMALL_GAP }) {
              ForEach([...this.laps].reverse(), (lap: LapRecord) => {
                LapItem({
                  lap,
                  isFastest: this.laps.length > 1 && lap.lapNumber === lapStats.fastestLapNumber,
                  isSlowest: this.laps.length > 1 && lap.lapNumber === lapStats.slowestLapNumber
                })
              }, (lap: LapRecord) => `${lap.id}`)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: AppStyles.PAGE_VERTICAL_PADDING,
      bottom: AppStyles.PAGE_VERTICAL_PADDING,
      left: AppStyles.PAGE_HORIZONTAL_PADDING,
      right: AppStyles.PAGE_HORIZONTAL_PADDING
    })
    .backgroundColor(AppStyles.BACKGROUND_COLOR)
  }
}
