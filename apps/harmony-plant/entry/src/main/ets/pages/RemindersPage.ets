import { ReminderView, PlantService } from '../service/PlantService'

@Component
export struct RemindersPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @State reminders: ReminderView[] = []

  async aboutToAppear(): Promise<void> {
    await this.loadReminders()
  }

  private async loadReminders(): Promise<void> {
    this.reminders = await PlantService.getInstance().listRemindersView()
  }

  build() {
    Column({ space: 12 }) {
      Text('提醒管理')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      if (this.reminders.length === 0) {
        Column({ space: 8 }) {
          Text('暂无提醒')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('添加植物后会自动创建浇水提醒。')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(20)
      } else {
        List({ space: 12 }) {
          ForEach(this.reminders, (item: ReminderView) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.plant.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                  Blank()
                  Text(item.dueToday ? '今日待浇水' : '未到期')
                    .fontSize(13)
                    .fontColor(item.dueToday ? '#D32F2F' : '#2E7D32')
                }
                Text(`下次浇水：${item.nextWaterDate}`)
                  .fontSize(14)
                  .fontColor('#666666')
                if (item.plant.reminderId > 0) {
                  Text(`提醒 ID：${item.plant.reminderId}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(18)
              .alignItems(HorizontalAlign.Start)
            }
          }, (item: ReminderView) => `${item.plant.id}`)
        }
        .layoutWeight(1)
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
