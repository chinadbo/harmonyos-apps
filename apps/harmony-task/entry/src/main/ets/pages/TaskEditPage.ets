import router from '@ohos.router';
import { TaskItem, TaskPriority, TaskStatus, getDefaultTask } from '../database/TaskModel';
import { CategoryItem } from '../database/CategoryModel';
import { TaskDatabase } from '../database/TaskDatabase';
import { TaskService } from '../services/TaskService';
import { PriorityBadge } from '../components/PriorityBadge';

interface RouteParams {
  taskId?: number;
}

@Entry
@Component
struct TaskEditPage {
  @State task: TaskItem = getDefaultTask();
  @State categories: CategoryItem[] = [];
  @State isEdit: boolean = false;
  @State selectedDate: Date = new Date();
  @State showDatePicker: boolean = false;
  private taskService: TaskService = new TaskService();

  async aboutToAppear(): Promise<void> {
    this.categories = await this.taskService.getAllCategories();
    const params = router.getParams() as RouteParams;
    if (params && params.taskId) {
      this.isEdit = true;
      await this.loadTask(params.taskId);
    }
  }

  async loadTask(taskId: number): Promise<void> {
    const db = TaskDatabase.getInstance();
    const tasks = await db.queryAllTasks();
    const found = tasks.find(t => t.id === taskId);
    if (found) {
      this.task = found;
      if (found.dueDate > 0) {
        this.selectedDate = new Date(found.dueDate);
      }
    }
  }

  async saveTask(): Promise<void> {
    if (!this.task.title.trim()) {
      return;
    }
    if (this.isEdit) {
      await this.taskService.updateTask(this.task);
    } else {
      await this.taskService.createTask(this.task);
    }
    router.back();
  }

  async deleteTask(): Promise<void> {
    if (this.isEdit && this.task.id) {
      await this.taskService.deleteTask(this.task);
      router.back();
    }
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

        Text(this.isEdit ? '编辑任务' : '新建任务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })

        Blank()

        if (this.isEdit) {
          Image($r('sys.media.ohos_ic_public_delete'))
            .width(24)
            .height(24)
            .fillColor('#FF4757')
            .onClick(() => {
              this.deleteTask();
            })
        }
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          // 标题
          Text('标题')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入任务标题', text: this.task.title })
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .onChange((value: string) => {
              this.task.title = value;
            })

          // 描述
          Text('描述')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8 })

          TextArea({ placeholder: '请输入任务描述（选填）', text: this.task.description })
            .height(100)
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .onChange((value: string) => {
              this.task.description = value;
            })

          // 分类选择
          Text('分类')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.categories, (cat: CategoryItem) => {
              Text(cat.name)
                .fontSize(13)
                .fontColor(this.task.categoryId === cat.id ? Color.White : cat.color)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.task.categoryId === cat.id ? cat.color : cat.color + '20')
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.task.categoryId = cat.id!;
                })
            }, (cat: CategoryItem) => cat.id!.toString())
          }

          // 优先级选择
          Text('优先级')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8 })

          Row() {
            ForEach([
              { label: '低', value: TaskPriority.LOW, color: '#2ED573' },
              { label: '中', value: TaskPriority.MEDIUM, color: '#FFA502' },
              { label: '高', value: TaskPriority.HIGH, color: '#FF4757' }
            ], (item: { label: string; value: number; color: string }) => {
              Text(item.label)
                .fontSize(14)
                .fontColor(this.task.priority === item.value ? Color.White : item.color)
                .padding({ left: 24, right: 24, top: 10, bottom: 10 })
                .backgroundColor(this.task.priority === item.value ? item.color : item.color + '20')
                .borderRadius(20)
                .margin({ right: 12 })
                .onClick(() => {
                  this.task.priority = item.value;
                })
            }, (item: { label: string; value: number; color: string }) => item.value.toString())
          }

          // 截止日期
          Text('截止日期')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8 })

          Row() {
            Text(this.task.dueDate > 0 ? this.formatDateTime(this.task.dueDate) : '选择日期和时间')
              .fontSize(14)
              .fontColor(this.task.dueDate > 0 ? '#333333' : '#999999')
              .layoutWeight(1)

            Image($r('sys.media.ohos_ic_public_calendar'))
              .width(20)
              .height(20)
              .fillColor('#666666')
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .onClick(() => {
            this.showDatePicker = true;
          })

          // 提醒时间
          Text('提前提醒')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 20, bottom: 8 })

          Row() {
            ForEach([
              { label: '不提醒', value: 0 },
              { label: '5分钟', value: 5 },
              { label: '15分钟', value: 15 },
              { label: '30分钟', value: 30 },
              { label: '1小时', value: 60 }
            ], (item: { label: string; value: number }) => {
              Text(item.label)
                .fontSize(12)
                .fontColor(this.task.reminderTime === item.value ? Color.White : '#666666')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.task.reminderTime === item.value ? '#4ECDC4' : '#F0F0F0')
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.task.reminderTime = item.value;
                })
            }, (item: { label: string; value: number }) => item.value.toString())
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(16)
      }
      .layoutWeight(1)

      // 保存按钮
      Button(this.isEdit ? '保存修改' : '创建任务')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#4ECDC4')
        .borderRadius(24)
        .margin({ bottom: 24 })
        .onClick(() => {
          this.saveTask();
        })

      // DatePicker Dialog
      if (this.showDatePicker) {
        Column() {
          DatePicker({
            start: new Date('2024-01-01'),
            end: new Date('2030-12-31'),
            selected: this.selectedDate
          })
            .onChange((value: DatePickerResult) => {
              this.selectedDate = new Date(
                value.year,
                value.month,
                value.day,
                this.selectedDate.getHours(),
                this.selectedDate.getMinutes()
              );
            })

          TimePicker({ selected: this.selectedDate })
            .onChange((value: TimePickerResult) => {
              this.selectedDate = new Date(
                this.selectedDate.getFullYear(),
                this.selectedDate.getMonth(),
                this.selectedDate.getDate(),
                value.hour,
                value.minute
              );
            })

          Row() {
            Button('取消')
              .fontColor('#666666')
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.showDatePicker = false;
              })

            Button('确定')
              .fontColor(Color.White)
              .backgroundColor('#4ECDC4')
              .margin({ left: 16 })
              .onClick(() => {
                this.task.dueDate = this.selectedDate.getTime();
                this.showDatePicker = false;
              })
          }
          .margin({ top: 16 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .shadow({ radius: 8, color: '#33000000', offsetX: 0, offsetY: -4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  private formatDateTime(timestamp: number): string {
    const d = new Date(timestamp);
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
  }
}
