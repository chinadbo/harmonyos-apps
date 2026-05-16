import promptAction from '@ohos.promptAction'
import { PreferencesService } from '../service/PreferencesService'

@Component
export struct SettingsPage {
  @State private stepGoalText: string = '8000'
  @State private calorieGoalText: string = '500'

  async aboutToAppear(): Promise<void> {
    await this.loadSettings()
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('设置')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')

        Column({ space: 12 }) {
          Text('每日步数目标')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Row({ space: 12 }) {
            TextInput({ text: this.stepGoalText, placeholder: '8000' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.stepGoalText = value
              })
              .layoutWeight(1)
              .height(46)
              .backgroundColor('#F3F4F6')
              .borderRadius(14)
            Button('保存')
              .height(46)
              .backgroundColor('#4F46E5')
              .fontColor('#FFFFFF')
              .onClick(async () => {
                await this.saveStepGoal()
              })
          }
          .width('100%')
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('每日卡路里目标')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Row({ space: 12 }) {
            TextInput({ text: this.calorieGoalText, placeholder: '500' })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.calorieGoalText = value
              })
              .layoutWeight(1)
              .height(46)
              .backgroundColor('#F3F4F6')
              .borderRadius(14)
            Button('保存')
              .height(46)
              .backgroundColor('#4F46E5')
              .fontColor('#FFFFFF')
              .onClick(async () => {
                await this.saveCalorieGoal()
              })
          }
          .width('100%')
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 8 }) {
          Text('关于')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Text('版本 1.0.0')
            .fontSize(14)
            .fontColor('#4B5563')
            .width('100%')
          Text('开发者 chinadbo')
            .fontSize(14)
            .fontColor('#4B5563')
            .width('100%')
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      }
      .padding(16)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F6FA')
  }

  private async loadSettings(): Promise<void> {
    try {
      this.stepGoalText = `${await PreferencesService.getInstance().getStepGoal()}`
      this.calorieGoalText = `${await PreferencesService.getInstance().getCalorieGoal()}`
    } catch (error) {
      promptAction.showToast({ message: '加载失败' })
      console.error(`loadSettings failed: ${JSON.stringify(error)}`)
    }
  }

  private async saveStepGoal(): Promise<void> {
    try {
      const goal = Number(this.stepGoalText)
      await PreferencesService.getInstance().setStepGoal(Number.isNaN(goal) ? 8000 : goal)
      promptAction.showToast({ message: '保存成功' })
    } catch (error) {
      promptAction.showToast({ message: '保存失败' })
      console.error(`saveStepGoal failed: ${JSON.stringify(error)}`)
    }
  }

  private async saveCalorieGoal(): Promise<void> {
    try {
      const goal = Number(this.calorieGoalText)
      await PreferencesService.getInstance().setCalorieGoal(Number.isNaN(goal) ? 500 : goal)
      promptAction.showToast({ message: '保存成功' })
    } catch (error) {
      promptAction.showToast({ message: '保存失败' })
      console.error(`saveCalorieGoal failed: ${JSON.stringify(error)}`)
    }
  }
}
