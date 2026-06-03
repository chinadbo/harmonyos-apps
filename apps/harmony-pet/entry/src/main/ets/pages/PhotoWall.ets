import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { PhotoDao } from '../database/PhotoDao'
import type { PetPhoto } from '../model/PetPhoto'
import { DateUtils } from '../common/DateUtils'
import { PhotoItem } from '../components/PhotoItem'

@Entry
@Component
export struct PhotoWall {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State petId: number = 0
  @State items: PetPhoto[] = []

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>
    this.petId = Number(params?.petId ?? AppStorage.get<number>('activePetId') ?? 0)
    this.loadPhotos()
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadPhotos(): Promise<void> {
    if (this.petId <= 0) {
      return
    }
    const dao: PhotoDao = new PhotoDao(this.getAbilityContext())
    this.items = await dao.queryByPetId(this.petId)
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private async addPhoto(): Promise<void> {
    const picker = new photoAccessHelper.PhotoViewPicker()
    const bridge = picker as unknown as Record<string, Function>
    let result: Record<string, Array<Record<string, string>>> | null = null
    if (typeof bridge.select === 'function') {
      result = await bridge.select({ maxSelectNumber: 1, MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE })
    }
    const uri: string = result?.photoUris?.[0]?.uri ?? result?.photoUris?.[0] as unknown as string
    if (!uri) {
      return
    }
    const dao: PhotoDao = new PhotoDao(this.getAbilityContext())
    await dao.insert({
      petId: this.petId,
      photoUri: uri,
      shotDate: DateUtils.today(),
      note: '',
      createdAt: DateUtils.nowTimestamp()
    })
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    await this.loadPhotos()
  }

  private async deletePhoto(id: number): Promise<void> {
    const dao: PhotoDao = new PhotoDao(this.getAbilityContext())
    await dao.delete(id)
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    await this.loadPhotos()
  }

  build() {
    return Column({ space: 16 }) {
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .backgroundColor('#FFFFFF')
          .fontColor('#666666')
          .onClick(() => this.goBack())
        Blank()
        Text('照片墙')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('添加照片')
          .type(ButtonType.Capsule)
          .onClick(() => this.addPhoto())
      }

      WaterFlow({ columnsTemplate: '1fr 1fr', rowsGap: 12, columnsGap: 12 }) {
        ForEach(this.items, (item: PetPhoto) => {
          FlowItem() {
            PhotoItem({
              item,
              onDelete: (id: number) => this.deletePhoto(id)
            })
          }
        }, (item: PetPhoto) => `${item.id}`)
      }
      .layoutWeight(1)
      .width('100%')
    }
    .padding(16)
    .backgroundColor('#F6F7FB')
    .height('100%')
  }
}
