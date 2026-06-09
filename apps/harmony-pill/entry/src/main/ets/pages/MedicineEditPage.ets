import { Medicine, createEmptyMedicine } from '../models/MedicineModel'
import { pillDatabase } from '../services/PillDatabase'

@Entry
@Component
struct MedicineEditPage {
  @State medicine: Medicine = createEmptyMedicine()
  @State isNew: boolean = true

  onPageShow() {
    const params = this.getUIContext().getRouter().getParams() as Record<string, Medicine>
    if (params && params.medicine) {
      this.medicine = { ...params.medicine }
      this.isNew = this.medicine.id === 0
    }
  }

  async saveMedicine() {
    if (!this.medicine.name || this.medicine.name.trim().length === 0) {
      return
    }
    await pillDatabase.saveMedicine(this.medicine)
    this.getUIContext().getRouter().back()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Text(this.isNew ? '添加药品' : '编辑药品')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)

          Button('保存', { type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.TEXTUAL })
            .fontSize(14)
            .fontColor('#2196F3')
            .onClick(() => this.saveMedicine())
        }
        .width('100%')
        .padding(16)

        // Form
        List() {
          ListItem() {
            Column() {
              this.FormRow('名称 *', () => {
                TextInput({ text: this.medicine.name })
                  .placeholder('请输入药品名称')
                  .onChange((value) => this.medicine.name = value)
              })

              this.FormRow('规格', () => {
                TextInput({ text: this.medicine.spec })
                  .placeholder('如：500mg')
                  .onChange((value) => this.medicine.spec = value)
              })

              this.FormRow('库存', () => {
                TextInput({ text: `${this.medicine.stock}` })
                  .placeholder('0')
                  .type(InputType.Number)
                  .onChange((value) => this.medicine.stock = parseInt(value) || 0)
              })

              this.FormRow('单位', () => {
                TextInput({ text: this.medicine.unit })
                  .placeholder('如：片、粒、ml')
                  .onChange((value) => this.medicine.unit = value)
              })

              this.FormRow('备注', () => {
                TextArea({ text: this.medicine.notes })
                  .placeholder('可选')
                  .height(80)
                  .onChange((value) => this.medicine.notes = value)
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
          .padding({ left: 16, right: 16, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // Action buttons
        Row() {
          Button('取消', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .onClick(() => {
              this.getUIContext().getRouter().back()
            })

          Blank().width(16)

          Button('保存', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#2196F3')
            .layoutWeight(1)
            .onClick(() => this.saveMedicine())
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }

  @Builder
  FormRow(label: string, content: () => void) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 4 })

      content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }
}
