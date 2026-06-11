import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import { DailyGoal } from '../model/DailyGoal'
import { WaterService } from '../service/WaterService'
import { ReminderService } from '../service/ReminderService'

@Component
export struct SettingsPage {
  @Prop onSaved: () => void = () => {}
  @State goal: DailyGoal = new DailyGoal()
  private waterService: WaterService = WaterService.getInstance()

  async aboutToAppear(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext
      await this.waterService.init(context)
      this.goal = await this.waterService.getGoal()
    } catch (error) {
      promptAction.showToast({ message: '设置加载失败' })
    }
  }

  private async saveSettings(): Promise<void> {
    try {
      await this.waterService.saveGoal(this.goal)
      await ReminderService.publishDailyReminder(this.goal)
      promptAction.showToast({ message: '设置已保存' })
      this.onSaved()
    } catch (error) {
      promptAction.showToast({ message: '保存失败' })
    }
  }

  private async clearData(): Promise<void> {
    try {
      await this.waterService.clearData()
      promptAction.showToast({ message: '数据已清空' })
    } catch (error) {
      promptAction.showToast({ message: '清空失败' })
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Column({ space: 12 }) {
          Text(`每日目标：${this.goal.amount} ml`)
            .fontSize(16)
          Slider({ value: this.goal.amount, min: 1000, max: 5000, step: 100 })
            .onChange((value: number) => {
              this.goal.amount = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Row() {
          Text('提醒开关')
            .fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.goal.reminderEnabled })
            .onChange((isOn: boolean) => {
              this.goal.reminderEnabled = isOn
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 12 }) {
          Text(`提醒时段：${this.goal.startHour}:00 - ${this.goal.endHour}:00`)
            .fontSize(16)
          Slider({ value: this.goal.startHour, min: 6, max: 12, step: 1 })
            .onChange((value: number) => {
              this.goal.startHour = Math.round(value)
            })
          Slider({ value: this.goal.endHour, min: 18, max: 23, step: 1 })
            .onChange((value: number) => {
              this.goal.endHour = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 12 }) {
          Text(`提醒间隔：${this.goal.intervalMinutes} 分钟`)
            .fontSize(16)
          Slider({ value: this.goal.intervalMinutes, min: 30, max: 240, step: 30 })
            .onChange((value: number) => {
              this.goal.intervalMinutes = Math.round(value)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Button('保存设置')
          .width('100%')
          .height(48)
          .onClick(() => this.saveSettings())

        Button('清空全部数据')
          .width('100%')
          .height(48)
          .backgroundColor('#F56C6C')
          .onClick(() => this.clearData())
      }
      .width('100%')
      .padding(16)
    }
  }
}
