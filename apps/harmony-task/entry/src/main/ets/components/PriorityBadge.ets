import { TaskPriority } from '../database/TaskModel';

@Component
export struct PriorityBadge {
  @Prop priority: number = TaskPriority.MEDIUM;

  private getColor(): string {
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

  private getLabel(): string {
    switch (this.priority) {
      case TaskPriority.HIGH:
        return '高';
      case TaskPriority.MEDIUM:
        return '中';
      case TaskPriority.LOW:
        return '低';
      default:
        return '';
    }
  }

  build() {
    Text(this.getLabel())
      .fontSize(11)
      .fontColor(Color.White)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .backgroundColor(this.getColor())
      .borderRadius(10)
  }
}
