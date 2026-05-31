import { Plant } from '../model/Plant'
import { CareType } from '../model/CareRecord'
import { PlantService } from '../service/PlantService'

@Component
export struct CareLogPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @Prop plantId: number = 0
  @State plant: Plant = new Plant()
  @State note: string = ''
  @State selectedType: CareType = 'water'

  async aboutToAppear(): Promise<void> {
    if (this.plantId > 0) {
      this.plant = (await PlantService.getInstance().getPlantById(this.plantId)) ?? new Plant()
    }
  }

  private async save(): Promise<void> {
    await PlantService.getInstance().logCare(this.plantId, this.selectedType, this.note.trim())
    this.stack.pop()
  }

  @Builder
  typeChip(label: string, type: CareType) {
    Button(label)
      .backgroundColor(this.selectedType === type ? '#4CAF50' : '#FFFFFF')
      .fontColor(this.selectedType === type ? '#FFFFFF' : '#333333')
      .borderRadius(18)
      .onClick(() => {
        this.selectedType = type
      })
  }

  build() {
    Column({ space: 16 }) {
      Text(`为 ${this.plant.name} 记录养护`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        this.typeChip('浇水', 'water')
        this.typeChip('施肥', 'fertilize')
        this.typeChip('修剪', 'prune')
        this.typeChip('换盆', 'repot')
      }
      .width('100%')

      TextArea({ placeholder: '备注信息', text: this.note })
        .height(160)
        .onChange((value: string) => {
          this.note = value
        })

      Button('保存记录')
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .onClick(async () => {
          await this.save()
        })
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
