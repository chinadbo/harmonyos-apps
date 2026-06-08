import router from '@ohos.router';
import { TaskItem, TaskStatus } from '../database/TaskModel';
import { CategoryItem } from '../database/CategoryModel';
import { TaskService } from '../services/TaskService';
import { TaskCard } from '../components/TaskCard';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct TodayPage {
  @State tasks: TaskItem[] = [];
  @State categories: CategoryItem[] = [];
  private taskService: TaskService = new TaskService();

  async aboutToAppear(): Promise<void> {
    await this.loadData();
  }

  async loadData(): Promise<void> {
    this.tasks = await this.taskService.getTodayTasks();
    this.categories = await this.taskService.getAllCategories();
  }

  private getCategoryInfo(categoryId: number): CategoryItem | undefined {
    return this.categories.find(c => c.id === categoryId);
  }

  private getCompletedCount(): number {
    return this.tasks.filter(t => t.status === TaskStatus.COMPLETED).length;
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text('今日任务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })

        Blank()

        Text(`${this.getCompletedCount()}/${this.tasks.length}`)
          .fontSize(14)
          .fontColor('#4ECDC4')
      }
      .width('100%')
      .padding(16)

      // 进度条
      Row() {
        Progress({
          value: this.tasks.length > 0 ? this.getCompletedCount() * 100 / this.tasks.length : 0,
          total: 100,
          type: ProgressType.Linear
        })
          .width('100%')
          .color('#4ECDC4')
          .backgroundColor('#F0F0F0')
          .style({ strokeWidth: 8 })
      }
      .padding({ left: 16, right: 16, bottom: 16 })

      // 任务列表
      if (this.tasks.length === 0) {
        EmptyState({ message: '今天没有待办任务 🎉', icon: '☀️' })
      } else {
        List({ space: 12 }) {
          ForEach(this.tasks, (task: TaskItem) => {
            ListItem() {
              Row() {
                TaskCard({
                  title: task.title,
                  description: task.description,
                  priority: task.priority,
                  status: task.status,
                  dueDate: task.dueDate,
                  categoryName: this.getCategoryInfo(task.categoryId)?.name || '',
                  categoryColor: this.getCategoryInfo(task.categoryId)?.color || '#999999',
                  onComplete: () => {
                    this.taskService.completeTask(task).then(() => {
                      this.loadData();
                    });
                  },
                  onTap: () => {
                    router.pushUrl({
                      url: 'pages/TaskEditPage',
                      params: { taskId: task.id }
                    });
                  }
                })
              }

              // 右滑延期操作
            }
            .swipeAction({
              end: this.postponeButton(task)
            })
          }, (task: TaskItem) => task.id!.toString())
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder postponeButton(task: TaskItem) {
    Row() {
      Button('延期1天')
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor('#FFA502')
        .borderRadius(8)
        .height(40)
        .onClick(() => {
          this.taskService.postponeTask(task, 1).then(() => {
            this.loadData();
          });
        })
    }
    .padding(12)
  }
}
