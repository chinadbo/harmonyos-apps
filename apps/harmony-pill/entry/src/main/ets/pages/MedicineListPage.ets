import { Medicine, createEmptyMedicine } from '../models/MedicineModel'
import { pillDatabase } from '../services/PillDatabase'
import { MedicineCard } from '../components/MedicineCard'

@Entry
@Component
struct MedicineListPage {
  @State medicines: Medicine[] = []

  async aboutToAppear() {
    await this.loadMedicines()
  }

  async loadMedicines() {
    this.medicines = await pillDatabase.getMedicines()
  }

  async deleteMedicine(medicine: Medicine) {
    if (medicine.id > 0) {
      await pillDatabase.deleteMedicine(medicine.id)
      await this.loadMedicines()
    }
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Text('药品管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)

          Button('+', { type: ButtonType.Circle })
            .width(40)
            .height(40)
            .fontSize(20)
            .fontColor(Color.White)
            .backgroundColor('#2196F3')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/MedicineEditPage',
                params: { medicine: createEmptyMedicine() }
              })
            })
        }
        .width('100%')
        .padding(16)

        // Medicine list
        List() {
          if (this.medicines.length === 0) {
            ListItem() {
              Column() {
                Text('暂无药品')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 40 })

                Text('点击右上角 + 添加药品')
                  .fontSize(12)
                  .fontColor('#CCCCCC')
                  .margin({ top: 8 })
              }
              .width('100%')
              .padding(32)
            }
          } else {
            ForEach(this.medicines, (medicine: Medicine) => {
              ListItem() {
                MedicineCard({
                  medicine: medicine,
                  onClick: () => {
                    this.getUIContext().getRouter().pushUrl({
                      url: 'pages/MedicineEditPage',
                      params: { medicine: medicine }
                    })
                  },
                  onLongPress: () => {
                    this.deleteMedicine(medicine)
                  }
                })
              }
              .padding({ left: 16, right: 16, bottom: 8 })
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        // Back button
        Row() {
          Button('返回首页', { type: ButtonType.Capsule })
            .fontSize(14)
            .fontColor('#2196F3')
            .backgroundColor('#E3F2FD')
            .onClick(() => {
              this.getUIContext().getRouter().back()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F7FB')
    }
    .hideTitleBar(true)
  }
}
