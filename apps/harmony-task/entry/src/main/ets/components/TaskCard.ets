import { TaskItem, TaskPriority, TaskStatus } from '../database/TaskModel';
import { CategoryItem } from '../database/CategoryModel';

@Component
export struct TaskCard {
  @Prop title: string = '';
  @Prop description: string = '';
  @Prop priority: number = TaskPriority.MEDIUM;
  @Prop status: number = TaskStatus.TODO;
  @Prop dueDate: number = 0;
  @Prop categoryName: string = '';
  @Prop categoryColor: string = '#999999';
  onComplete?: () => void;
  onTap?: () => void;

  private getPriorityColor(): string {
    switch (this.priority) {
      case TaskPriority.HIGH:
        return '#FF4757';
      case TaskPriority.MEDIUM:
        return '#FFA502';
      case TaskPriority.LOW:
        return '#2ED573';
      default:
        return '#999999';
    }
  }

  private formatDate(timestamp: number): string {
    if (timestamp <= 0) return '';
    const date = new Date(timestamp);
    return `${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  private isOverdue(): boolean {
    return this.dueDate > 0 && this.dueDate < Date.now() && this.status !== TaskStatus.COMPLETED;
  }

  build() {
    Row() {
      // 左侧优先级条
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(this.getPriorityColor())
        .borderRadius(2)

      // 完成按钮
      Column() {
        if (this.status === TaskStatus.COMPLETED) {
          Image($r('sys.media.ohos_ic_public_ok'))
            .width(24)
            .height(24)
            .fillColor('#2ED573')
        } else {
          Circle()
            .width(24)
            .height(24)
            .fill(Color.Transparent)
            .stroke(this.getPriorityColor())
            .strokeWidth(2)
        }
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.onComplete) {
          this.onComplete();
        }
      })

      // 内容区
      Column() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.status === TaskStatus.COMPLETED ? '#999999' : '#333333')
          .decoration({ type: this.status === TaskStatus.COMPLETED ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.description) {
          Text(this.description)
            .fontSize(13)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }

        Row() {
          if (this.categoryName) {
            Text(this.categoryName)
              .fontSize(11)
              .fontColor(this.categoryColor)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(this.categoryColor + '20')
              .borderRadius(4)
          }
          if (this.dueDate > 0) {
            Text(this.formatDate(this.dueDate))
              .fontSize(11)
              .fontColor(this.isOverdue() ? '#FF4757' : '#999999')
              .margin({ left: 8 })
          }
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}
