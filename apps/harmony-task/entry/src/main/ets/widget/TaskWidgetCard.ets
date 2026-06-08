@Entry
@Component
struct TaskWidgetCard {
  @LocalStorageProp('pendingCount') pendingCount: number = 0;
  @LocalStorageProp('todayCount') todayCount: number = 0;
  @LocalStorageProp('tasks') tasks: string = '[]';
  @LocalStorageProp('formId') formId: string = '';

  private parseTasks(): Array<{ title: string; priority: number; status: number }> {
    try {
      return JSON.parse(this.tasks) as Array<{ title: string; priority: number; status: number }>;
    } catch {
      return [];
    }
  }

  private getPriorityColor(priority: number): string {
    switch (priority) {
      case 2: return '#FF4757';
      case 1: return '#FFA502';
      default: return '#2ED573';
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('🗒️')
          .fontSize(16)
        Text('鸿蒙待办')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 4 })
        Blank()
        Text(`${this.pendingCount}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4ECDC4')
        Text('待办')
          .fontSize(11)
          .fontColor('#999999')
          .margin({ left: 2 })
      }
      .width('100%')

      Divider()
        .color('#F0F0F0')
        .margin({ top: 8, bottom: 8 })

      // 今日概览
      Row() {
        Text(`📅 今日 ${this.todayCount} 项`)
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')

      // 任务列表（最多显示3项）
      Column() {
        ForEach(this.parseTasks().slice(0, 3), (task: { title: string; priority: number; status: number }, index: number) => {
          Row() {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getPriorityColor(task.priority))
            Text(task.title)
              .fontSize(12)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 6 })
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 6 })
        }, (task: { title: string; priority: number; status: number }, index: number) => index.toString())
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .onClick(() => {
      postCardAction(this, {
        'action': 'router',
        'abilityName': 'EntryAbility',
        'params': {}
      });
    })
  }
}
