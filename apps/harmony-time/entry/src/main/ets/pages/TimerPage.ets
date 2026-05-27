import { Project } from '../model/Project'
import { ProjectItem } from '../components/ProjectItem'
import { TimerCard } from '../components/TimerCard'
import { TimerService } from '../service/TimerService'
import { NotificationService } from '../service/NotificationService'
import { DatabaseHelper } from '../database/DatabaseHelper'

@Component
export struct TimerPage {
  @State projects: Project[] = []
  @State selectedProject: Project | null = null
  @StorageProp('isTimerRunning') isRunning: boolean = false
  @StorageProp('runningProjectId') runningProjectId: number = -1

  aboutToAppear(): void {
    this.loadProjects()
  }

  private async loadProjects(): Promise<void> {
    const db = DatabaseHelper.getInstance()
    this.projects = await db.getAllProjects()

    // If timer is running, set selected project
    if (this.runningProjectId !== -1) {
      const found = this.projects.find(p => p.id === this.runningProjectId)
      if (found) {
        this.selectedProject = found
      }
    }
  }

  private async startTimer(project: Project): Promise<void> {
    const db = DatabaseHelper.getInstance()
    const entryId = await db.createTimeEntry(project.id)
    const timerService = TimerService.getInstance()
    await timerService.start(project.id, entryId)

    const notifService = NotificationService.getInstance()
    await notifService.showTimerNotification(project.name)
  }

  private pauseTimer(): void {
    const timerService = TimerService.getInstance()
    if (this.isRunning) {
      timerService.pause()
    } else {
      timerService.resume()
    }
  }

  private async stopTimer(): Promise<void> {
    const timerService = TimerService.getInstance()
    const elapsed = await timerService.stop()

    const notifService = NotificationService.getInstance()
    await notifService.cancelTimerNotification()

    // Update the time entry
    if (this.selectedProject) {
      const db = DatabaseHelper.getInstance()
      const entryId = AppStorage.Get<number>('runningEntryId') ?? -1
      if (entryId !== -1) {
        await db.finishTimeEntry(entryId, elapsed)
        await db.addProjectTime(this.selectedProject.id, elapsed)
      }
    }

    this.selectedProject = null
    this.loadProjects()
  }

  build() {
    Column() {
      if (this.runningProjectId !== -1 && this.selectedProject !== null) {
        // Show timer card
        TimerCard({
          projectName: this.selectedProject!.name,
          projectColor: this.selectedProject!.color,
          projectIcon: this.selectedProject!.icon,
          onPause: () => {
            this.pauseTimer()
          },
          onStop: () => {
            this.stopTimer()
          }
        })
        .margin({ top: 16, left: 16, right: 16 })
      } else {
        // Show project list to start timer
        Column() {
          Text('选择项目开始计时')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 24, bottom: 16 })

          if (this.projects.length === 0) {
            Column() {
              Text('📁')
                .fontSize(48)
                .margin({ bottom: 12 })
              Text('暂无项目')
                .fontSize(16)
                .fontColor('#999999')
              Text('请先在项目页面添加项目')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: 4 })
            }
            .margin({ top: 60 })
          } else {
            List({ space: 8 }) {
              ForEach(this.projects, (project: Project) => {
                ListItem() {
                  ProjectItem({
                    project: project,
                    onTap: (p: Project) => {
                      this.selectedProject = p
                      this.startTimer(p)
                    }
                  })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
