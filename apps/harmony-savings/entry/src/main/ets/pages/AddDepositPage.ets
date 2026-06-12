import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { DepositInput } from '../model/Deposit'
import { DepositViewModel } from '../viewmodel/DepositViewModel'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
export struct AddDepositPage {
  @State private goalId: number = 0
  @State private amountText: string = ''
  @State private depositDate: string = DateUtils.today()
  @State private note: string = ''
  private depositViewModel: DepositViewModel = new DepositViewModel()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    this.goalId = Number(params?.goalId)
  }

  private async saveDeposit(): Promise<void> {
    const amount: number = Number(this.amountText)
    if (!Number.isFinite(amount) || amount <= 0) {
      promptAction.showToast({ message: '请输入正确的存入金额（分）' })
      return
    }
    const input: DepositInput = {
      goalId: this.goalId,
      amount: Math.floor(amount),
      depositDate: this.depositDate,
      note: this.note.trim()
    }
    await this.depositViewModel.addDeposit(input)
    promptAction.showToast({ message: '存入成功' })
    router.back()
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Text('快速存入')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1F1F')
        Blank()
        Button('保存')
          .type(ButtonType.Capsule)
          .onClick(() => {
            this.saveDeposit()
          })
      }
      .width('100%')

      Column({ space: 10 }) {
        Text('存入金额（分）')
          .fontSize(14)
          .fontColor('#555555')
        TextInput({ text: this.amountText, placeholder: '请输入整数金额' })
          .type(InputType.Number)
          .onChange((value: string) => {
            this.amountText = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        Text('存入日期')
          .fontSize(14)
          .fontColor('#555555')
        TextInput({ text: this.depositDate, placeholder: 'YYYY-MM-DD' })
          .onChange((value: string) => {
            this.depositDate = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 10 }) {
        Text('备注')
          .fontSize(14)
          .fontColor('#555555')
        TextInput({ text: this.note, placeholder: '例如：本月结余' })
          .onChange((value: string) => {
            this.note = value
          })
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F6F8FB')
  }
}
