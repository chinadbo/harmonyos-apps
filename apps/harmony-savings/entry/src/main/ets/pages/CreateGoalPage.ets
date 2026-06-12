import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { GoalInput } from '../model/Goal'
import { GoalViewModel } from '../viewmodel/GoalViewModel'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
export struct CreateGoalPage {
  @State private goalId: number = 0
  @State private name: string = ''
  @State private targetAmountText: string = ''
  @State private deadline: string = DateUtils.today()
  @State private note: string = ''
  @State private color: string = '#4F7DFF'
  @State private pageTitle: string = '创建目标'
  private goalViewModel: GoalViewModel = new GoalViewModel()
  private readonly colors: string[] = ['#4F7DFF', '#20A162', '#FF7D45', '#8A5CFF', '#E64545']

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    const goalIdParam: Object = params?.goalId
    if (goalIdParam !== undefined) {
      this.goalId = Number(goalIdParam)
      this.loadGoal(this.goalId)
      this.pageTitle = '编辑目标'
    }
  }

  private async loadGoal(goalId: number): Promise<void> {
    const goal = await this.goalViewModel.getGoal(goalId)
    if (goal === null) {
      return
    }
    this.name = goal.name
    this.targetAmountText = `${goal.targetAmount}`
    this.deadline = goal.deadline
    this.note = goal.note
    this.color = goal.color
  }

  private async saveGoal(): Promise<void> {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入目标名称' })
      return
    }
    const targetAmount: number = Number(this.targetAmountText)
    if (!Number.isFinite(targetAmount) || targetAmount <= 0) {
      promptAction.showToast({ message: '请输入正确的目标金额（分）' })
      return
    }

    const input: GoalInput = {
      id: this.goalId > 0 ? this.goalId : undefined,
      name: this.name.trim(),
      targetAmount: Math.floor(targetAmount),
      deadline: this.deadline,
      note: this.note.trim(),
      color: this.color
    }
    await this.goalViewModel.saveGoal(input)
    promptAction.showToast({ message: '保存成功' })
    router.back()
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text(this.pageTitle)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F1F1F')
          Blank()
          Button('保存')
            .type(ButtonType.Capsule)
            .onClick(() => {
              this.saveGoal()
            })
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('目标名称')
            .fontSize(14)
            .fontColor('#555555')
          TextInput({ text: this.name, placeholder: '例如：旅游基金' })
            .onChange((value: string) => {
              this.name = value
            })
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 10 }) {
          Text('目标金额（分）')
            .fontSize(14)
            .fontColor('#555555')
          TextInput({ text: this.targetAmountText, placeholder: '请输入整数金额' })
            .type(InputType.Number)
            .onChange((value: string) => {
              this.targetAmountText = value
            })
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 10 }) {
          Text('截止日期')
            .fontSize(14)
            .fontColor('#555555')
          TextInput({ text: this.deadline, placeholder: 'YYYY-MM-DD' })
            .onChange((value: string) => {
              this.deadline = value
            })
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 10 }) {
          Text('备注')
            .fontSize(14)
            .fontColor('#555555')
          TextInput({ text: this.note, placeholder: '写下你的储蓄计划' })
            .onChange((value: string) => {
              this.note = value
            })
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Text('主题色')
            .fontSize(14)
            .fontColor('#555555')
          Row({ space: 12 }) {
            ForEach(this.colors, (item: string) => {
              Stack() {
                Circle()
                  .width(32)
                  .height(32)
                  .fill(item)
                if (this.color === item) {
                  Text('✓')
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                }
              }
              .onClick(() => {
                this.color = item
              })
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
