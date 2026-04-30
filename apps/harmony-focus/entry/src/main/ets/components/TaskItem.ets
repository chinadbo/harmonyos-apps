import { Task } from '../model/Task'

@Component
export struct TaskItem {
  @Prop task: Task = new Task()
  @Prop isActive: boolean = false
  @Prop onSelect: (task: Task) => void = () => {}
  @Prop onToggle: (task: Task) => void = () => {}
  @Prop onDelete: (task: Task) => void = () => {}

  build() {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Row() {
          Text(this.task.title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.task.isCompleted ? '#ADB5BD' : '#212529')
            .decoration({ type: this.task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
          if (this.isActive) {
            Text('当前')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF6B6B')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .margin({ left: 8 })
          }
        }
        if (this.task.note.length > 0) {
          Text(this.task.note)
            .fontSize(12)
            .fontColor('#868E96')
            .maxLines(2)
        }
        Text(`${this.task.completedPomodoros}/${this.task.estimatedPomodoros} 番茄`)
          .fontSize(12)
          .fontColor('#495057')
      }
      .layoutWeight(1)
      Column({ space: 8 }) {
        Button(this.isActive ? '已选中' : '设为当前')
          .fontSize(12)
          .height(32)
          .backgroundColor(this.isActive ? '#FCC2D7' : '#FF6B6B')
          .enabled(!this.isActive)
          .onClick(() => this.onSelect(this.task))
        Button(this.task.isCompleted ? '恢复' : '完成')
          .fontSize(12)
          .height(32)
          .backgroundColor('#E9ECEF')
          .fontColor('#212529')
          .onClick(() => this.onToggle(this.task))
        Button('删除')
          .fontSize(12)
          .height(32)
          .backgroundColor('#FFF5F5')
          .fontColor('#E03131')
          .onClick(() => this.onDelete(this.task))
      }
      .width(88)
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
    .width('100%')
  }
}
