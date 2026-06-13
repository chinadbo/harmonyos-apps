import { DatabaseHelper } from '../database/DatabaseHelper'
import { UserProfile } from '../model/UserProfile'
import { NotificationService } from '../service/NotificationService'

@Entry
@Component
struct Settings {
  private notificationService: NotificationService = new NotificationService()
  @State profile: UserProfile = DatabaseHelper.getInstance().getUserProfile()
  @State remindersEnabled: boolean = true

  aboutToAppear(): void {
    this.remindersEnabled = this.profile.reminderEnabled
    this.notificationService.setEnabled(this.remindersEnabled)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('Settings')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 14 }) {
          Text('Profile')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`Name: ${this.profile.name}`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Text(`BMI: ${this.profile.bodyMassIndex()}`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Text(`Calorie goal: ${this.profile.dailyCalorieGoal} kcal`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Text(`Protein goal: ${this.profile.dailyProteinGoal} g`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)

        Column({ space: 14 }) {
          Row() {
            Column({ space: 4 }) {
              Text('Daily Reminder')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
              Text(this.notificationService.getReminderText())
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Toggle({ type: ToggleType.Switch, isOn: this.remindersEnabled })
              .onChange((value: boolean) => {
                this.remindersEnabled = value
                this.notificationService.setEnabled(value)
              })
          }
          .width('100%')

          Text(this.notificationService.buildDailyMessage(this.profile.dailyCalorieGoal - 1240))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(20)
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
