import { MODE_LABELS, AppDefaults, SessionMode, TimerStatus, WhiteNoiseType } from '../common/Constants'
import { TimerRing } from '../components/TimerRing'
import { Task } from '../model/Task'
import { AppSettings } from '../model/AppSettings'
import { TaskListPage } from './TaskList'
import { StatisticsPage } from './Statistics'
import { SettingsPage } from './Settings'
import { databaseService } from '../services/DatabaseService'
import { timerService } from '../services/TimerService'
import { audioService } from '../services/AudioService'

@Entry
@Component
struct Index {
  private tabsController: TabsController = new TabsController()

  @State settings: AppSettings = new AppSettings()
  @State tasks: Task[] = []
  @State showTaskChooser: boolean = false
  @StorageLink(AppDefaults.STORAGE_TIMER_STATUS) timerStatus: TimerStatus = TimerStatus.IDLE
  @StorageLink(AppDefaults.STORAGE_REMAINING_SECONDS) remainingSeconds: number = 1500
  @StorageLink(AppDefaults.STORAGE_TOTAL_SECONDS) totalSeconds: number = 1500
  @StorageLink(AppDefaults.STORAGE_CURRENT_MODE) currentMode: SessionMode = SessionMode.FOCUS
  @StorageLink(AppDefaults.STORAGE_CURRENT_TASK_ID) currentTaskId: number = 0
  @StorageLink(AppDefaults.STORAGE_CURRENT_TASK_NAME) currentTaskName: string = '未关联任务'
  @StorageLink(AppDefaults.STORAGE_TODAY_POMODOROS) todayPomodoros: number = 0

  async aboutToAppear(): Promise<void> {
    await this.loadSettings()
    await this.loadTasks()
  }

  private async loadSettings(): Promise<void> {
    this.settings = await databaseService.getSettings()
    AppStorage.SetOrCreate(AppDefaults.STORAGE_NOTIFICATION_ENABLED, this.settings.notificationEnabled)
    await timerService.hydrateFromSettings(this.settings)
  }

  private async loadTasks(): Promise<void> {
    this.tasks = await databaseService.getTasks()
  }

  private async handlePrimaryAction(): Promise<void> {
    if (this.timerStatus === TimerStatus.RUNNING) {
      timerService.pause()
      await audioService.stop()
      return
    }
    if (this.timerStatus === TimerStatus.PAUSED) {
      timerService.resume(this.settings)
    } else {
      timerService.start(this.currentMode, this.settings)
    }
    if (this.settings.whiteNoiseType !== WhiteNoiseType.NONE) {
      await audioService.play(this.settings.whiteNoiseType)
    }
  }

  private async stopTimer(): Promise<void> {
    timerService.stop(this.settings)
    await audioService.stop()
  }

  private async skipTimer(): Promise<void> {
    await timerService.skip(this.settings)
    await audioService.stop()
  }

  private getPrimaryButtonText(): string {
    if (this.timerStatus === TimerStatus.RUNNING) {
      return '暂停'
    }
    if (this.timerStatus === TimerStatus.PAUSED) {
      return '继续'
    }
    return '开始'
  }

  private openSettingsTab(): void {
    this.tabsController.changeIndex(3)
  }

  private selectTask(task: Task): void {
    timerService.setCurrentTask(task.id, task.title)
    this.showTaskChooser = false
  }

  @Builder
  private buildTaskChooser() {
    if (this.showTaskChooser) {
      Column({ space: 12 }) {
        Text('选择当前任务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        if (this.tasks.length === 0) {
          Text('暂无任务，请先到任务页创建。')
            .fontSize(14)
            .fontColor('#868E96')
        } else {
          ForEach(this.tasks.filter((task: Task) => !task.isCompleted), (task: Task) => {
            Button(task.title)
              .width('100%')
              .backgroundColor(this.currentTaskId === task.id ? '#FCC2D7' : '#F1F3F5')
              .fontColor('#212529')
              .onClick(() => this.selectTask(task))
          }, (task: Task) => `${task.id}`)
        }
        Button('关闭')
          .width('100%')
          .backgroundColor('#212529')
          .onClick(() => this.showTaskChooser = false)
      }
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .width('88%')
    }
  }

  @Builder
  private buildTimerTab() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 20 }) {
          Row() {
            Column({ space: 6 }) {
              Text(MODE_LABELS[this.currentMode])
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#212529')
              Text(`今日已完成 ${this.todayPomodoros} 个番茄`)
                .fontSize(14)
                .fontColor('#868E96')
            }
            .layoutWeight(1)
            Button('设置')
              .height(36)
              .backgroundColor('#FFFFFF')
              .fontColor('#212529')
              .onClick(() => this.openSettingsTab())
          }
          .width('100%')

          TimerRing({
            remainingSeconds: this.remainingSeconds,
            totalSeconds: this.totalSeconds,
            mode: this.currentMode,
            size: 280
          })

          Column({ space: 8 }) {
            Text('当前关联任务')
              .fontSize(12)
              .fontColor('#868E96')
            Button(this.currentTaskName)
              .width('100%')
              .height(44)
              .backgroundColor('#FFFFFF')
              .fontColor('#212529')
              .onClick(async () => {
                await this.loadTasks()
                this.showTaskChooser = true
              })
          }
          .width('100%')

          Row({ space: 12 }) {
            Button(this.getPrimaryButtonText())
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#FF6B6B')
              .onClick(() => this.handlePrimaryAction())
            Button('停止')
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#E9ECEF')
              .fontColor('#212529')
              .onClick(() => this.stopTimer())
            Button('跳过')
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#E6FCF5')
              .fontColor('#2B8A3E')
              .onClick(() => this.skipTimer())
          }
          .width('100%')
        }
        .padding(20)
        .width('100%')
      }
      .width('100%')
      .height('100%')

      this.buildTaskChooser()
    }
    .backgroundColor('#F8F9FA')
    .width('100%')
    .height('100%')
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        this.buildTimerTab()
      }
      .tabBar('计时器')

      TabContent() {
        TaskListPage({ onTasksChanged: () => this.loadTasks() })
      }
      .tabBar('任务')

      TabContent() {
        StatisticsPage()
      }
      .tabBar('统计')

      TabContent() {
        SettingsPage({ onSettingsSaved: () => this.loadSettings() })
      }
      .tabBar('设置')
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .backgroundColor('#F8F9FA')
  }
}
