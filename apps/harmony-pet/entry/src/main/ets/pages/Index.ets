import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { PetDao } from '../database/PetDao'
import type { Pet } from '../model/Pet'
import { PetCard } from '../components/PetCard'

@Entry
@Component
export struct Index {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State pets: Pet[] = []

  aboutToAppear(): void {
    this.loadPets()
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadPets(): Promise<void> {
    const dao: PetDao = new PetDao(this.getAbilityContext())
    this.pets = await dao.queryAll()
  }

  private async goToEditPet(): Promise<void> {
    this.syncNavPath('EditPet', {})
    router.pushUrl({ url: 'pages/EditPet', params: {} })
  }

  private async goToDetail(petId: number): Promise<void> {
    AppStorage.setOrCreate('activePetId', petId)
    this.syncNavPath('PetDetail', { petId })
    router.pushUrl({ url: 'pages/PetDetail', params: { petId } })
  }

  private syncNavPath(name: string, params: Object): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pushPathByName === 'function') {
      stack.pushPathByName(name, params)
    } else if (stack && typeof stack.pushPath === 'function') {
      stack.pushPath({ name, param: params })
    }
  }

  build() {
    Navigation() {
      Column({ space: 16 }) {
        Row() {
          Text('我的宠物')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Button('+')
            .width(40)
            .height(40)
            .borderRadius(20)
            .fontSize(22)
            .onClick(() => this.goToEditPet())
        }

        if (this.pets.length === 0) {
          Column({ space: 14 }) {
            Text('爪')
              .fontSize(44)
              .fontColor('#FF8A00')
            Text('还没有宠物档案')
              .fontSize(18)
              .fontColor('#555555')
            Button('添加第一只宠物')
              .type(ButtonType.Capsule)
              .onClick(() => this.goToEditPet())
          }
          .width('100%')
          .padding(32)
          .margin({ top: 80 })
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
        } else {
          List({ space: 12 }) {
            ForEach(this.pets, (pet: Pet) => {
              ListItem() {
                PetCard({
                  pet,
                  onClick: (petId: number) => this.goToDetail(petId)
                })
              }
            }, (pet: Pet) => `${pet.id}`)
          }
          .layoutWeight(1)
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#F6F7FB')
    }
    .hideTitleBar(true)
    .onAppear(() => this.loadPets())
  }
}
