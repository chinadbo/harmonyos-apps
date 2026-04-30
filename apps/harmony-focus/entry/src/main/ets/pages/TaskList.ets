import { Task } from '../model/Task'
import { databaseService } from '../services/DatabaseService'
import { TaskItem } from '../components/TaskItem'
import { timerService } from '../services/TimerService'
import { AppDefaults } from '../common/Constants'

@Component
export struct TaskListPage {
  @Prop onTasksChanged: () => void = () => {}

  @State tasks: Task[] = []
  @State newTaskTitle: string = ''
  @State newTaskNote: string = ''
  @StorageLink(AppDefaults.STORAGE_CURRENT_TASK_ID) currentTaskId: number = 0

  async aboutToAppear(): Promise<void> {
    await this.loadTasks()
  }

  private async loadTasks(): Promise<void> {
    this.tasks = await databaseService.getTasks()
    this.onTasksChanged()
  }

  private async addTask(): Promise<void> {
    const title: string = this.newTaskTitle.trim()
    if (title.length === 0) {
      return
    }
    const now: number = Date.now()
    await databaseService.addTask(new Task(0, title, this.newTaskNote.trim(), false, now, now, 1, 0))
    this.newTaskTitle = ''
    this.newTaskNote = ''
    await this.loadTasks()
  }

  private async toggleTask(task: Task): Promise<void> {
    task.isCompleted = !task.isCompleted
    task.updatedAt = Date.now()
    await databaseService.updateTask(task)
    await this.loadTasks()
  }

  private async deleteTask(task: Task): Promise<void> {
    await databaseService.deleteTask(task.id)
    if (this.currentTaskId === task.id) {
      timerService.setCurrentTask(0, '未关联任务')
      this.currentTaskId = 0
    }
    await this.loadTasks()
  }

  private selectTask(task: Task): void {
    timerService.setCurrentTask(task.id, task.title)
    this.currentTaskId = task.id
    this.onTasksChanged()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Text('任务列表')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Start)
          TextInput({ placeholder: '输入任务标题', text: this.newTaskTitle })
            .onChange((value: string) => this.newTaskTitle = value)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          TextInput({ placeholder: '输入备注（可选）', text: this.newTaskNote })
            .onChange((value: string) => this.newTaskNote = value)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          Button('添加任务')
            .width('100%')
            .height(44)
            .backgroundColor('#FF6B6B')
            .onClick(() => this.addTask())
        }
        .padding(16)
        .backgroundColor('#FFF0F3')
        .borderRadius(20)

        if (this.tasks.length === 0) {
          Text('还没有任务，先创建一个开始今天的专注吧。')
            .fontSize(14)
            .fontColor('#868E96')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(24)
        } else {
          Column({ space: 12 }) {
            ForEach(this.tasks, (task: Task) => {
              TaskItem({
                task,
                isActive: this.currentTaskId === task.id,
                onSelect: (selected: Task) => this.selectTask(selected),
                onToggle: (selected: Task) => this.toggleTask(selected),
                onDelete: (selected: Task) => this.deleteTask(selected)
              })
            }, (task: Task) => `${task.id}`)
          }
        }
      }
      .width('100%')
      .padding(16)
    }
    .backgroundColor('#F8F9FA')
    .height('100%')
    .width('100%')
  }
}
