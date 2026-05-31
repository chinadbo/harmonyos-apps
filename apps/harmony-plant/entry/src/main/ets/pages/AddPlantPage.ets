import picker from '@ohos.file.picker'
import { Plant } from '../model/Plant'
import { PlantService } from '../service/PlantService'

@Component
export struct AddPlantPage {
  @Prop stack: NavPathStack = new NavPathStack()
  @Prop plantId: number = 0
  @State name: string = ''
  @State species: string = ''
  @State photoUri: string = ''
  @State waterInterval: string = '3'
  @State fertilizeInterval: string = '30'
  @State notes: string = ''

  async aboutToAppear(): Promise<void> {
    if (this.plantId > 0) {
      const plant = await PlantService.getInstance().getPlantById(this.plantId)
      if (plant) {
        this.name = plant.name
        this.species = plant.species
        this.photoUri = plant.photoUri
        this.waterInterval = `${plant.waterInterval}`
        this.fertilizeInterval = `${plant.fertilizeInterval}`
        this.notes = plant.notes
      }
    }
  }

  private async pickPhoto(): Promise<void> {
    const photoPicker = new picker.PhotoViewPicker()
    const result = await photoPicker.select({ MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE, maxSelectNumber: 1 })
    if (result.photoUris && result.photoUris.length > 0) {
      this.photoUri = result.photoUris[0]
    }
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      return
    }
    const original = this.plantId > 0 ? await PlantService.getInstance().getPlantById(this.plantId) : undefined
    const plant = new Plant({
      id: this.plantId,
      name: this.name.trim(),
      species: this.species.trim(),
      photoUri: this.photoUri,
      addedDate: original?.addedDate ?? new Date().toISOString(),
      waterInterval: Number(this.waterInterval) || 3,
      fertilizeInterval: Number(this.fertilizeInterval) || 30,
      lastWateredAt: original?.lastWateredAt ?? '',
      lastFertilizedAt: original?.lastFertilizedAt ?? '',
      reminderId: original?.reminderId ?? 0,
      notes: this.notes.trim()
    })
    await PlantService.getInstance().savePlant(plant)
    this.stack.pop()
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text(this.plantId > 0 ? '编辑植物' : '添加植物')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '植物名称', text: this.name })
          .onChange((value: string) => { this.name = value })
        TextInput({ placeholder: '品种 / 学名', text: this.species })
          .onChange((value: string) => { this.species = value })
        TextInput({ placeholder: '浇水周期（天）', text: this.waterInterval })
          .type(InputType.Number)
          .onChange((value: string) => { this.waterInterval = value })
        TextInput({ placeholder: '施肥周期（天）', text: this.fertilizeInterval })
          .type(InputType.Number)
          .onChange((value: string) => { this.fertilizeInterval = value })
        TextArea({ placeholder: '备注', text: this.notes })
          .height(120)
          .onChange((value: string) => { this.notes = value })

        if (this.photoUri.length > 0) {
          Image(this.photoUri)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)
        }

        Button(this.photoUri.length > 0 ? '重新选择照片' : '选择照片')
          .onClick(async () => {
            await this.pickPhoto()
          })

        Button('保存植物')
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
