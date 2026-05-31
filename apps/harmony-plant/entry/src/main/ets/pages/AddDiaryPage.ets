import picker from '@ohos.file.picker'
import { PlantDiary } from '../model/PlantDiary'
import { Plant } from '../model/Plant'
import { PlantService } from '../service/PlantService'

@Component
export struct AddDiaryPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @Prop plantId: number = 0
  @State plants: Plant[] = []
  @State selectedPlantId: number = 0
  @State title: string = ''
  @State content: string = ''
  @State photoUri: string = ''

  async aboutToAppear(): Promise<void> {
    this.plants = await PlantService.getInstance().listPlants()
    this.selectedPlantId = this.plantId > 0 ? this.plantId : (this.plants.length > 0 ? this.plants[0].id : 0)
  }

  private async pickPhoto(): Promise<void> {
    const photoPicker = new picker.PhotoViewPicker()
    const result = await photoPicker.select({ MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE, maxSelectNumber: 1 })
    if (result.photoUris && result.photoUris.length > 0) {
      this.photoUri = result.photoUris[0]
    }
  }

  private async save(): Promise<void> {
    if (this.selectedPlantId <= 0 || this.title.trim().length === 0 || this.content.trim().length === 0) {
      return
    }
    await PlantService.getInstance().createDiary(new PlantDiary({
      plantId: this.selectedPlantId,
      title: this.title.trim(),
      content: this.content.trim(),
      photoUri: this.photoUri,
      createdAt: new Date().toISOString()
    }))
    this.stack.pop()
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('写植物日志')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        if (this.plants.length > 0) {
          Select([{ value: '请选择植物' }, ...this.plants.map((plant: Plant) => ({ value: plant.name }))])
            .selected(this.plants.findIndex((plant: Plant) => plant.id === this.selectedPlantId) + 1)
            .onSelect((index: number) => {
              if (index > 0) {
                this.selectedPlantId = this.plants[index - 1].id
              }
            })
        }

        TextInput({ placeholder: '日志标题', text: this.title })
          .onChange((value: string) => { this.title = value })
        TextArea({ placeholder: '记录今天的养护、状态或新变化', text: this.content })
          .height(180)
          .onChange((value: string) => { this.content = value })

        if (this.photoUri.length > 0) {
          Image(this.photoUri)
            .width('100%')
            .height(180)
            .borderRadius(16)
            .objectFit(ImageFit.Cover)
        }

        Button(this.photoUri.length > 0 ? '重新选择图片' : '添加图片')
          .onClick(async () => {
            await this.pickPhoto()
          })

        Button('保存日志')
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .onClick(async () => {
            await this.save()
          })
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
