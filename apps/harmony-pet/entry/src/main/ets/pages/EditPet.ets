import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import { PetDao } from '../database/PetDao'
import type { Pet } from '../model/Pet'
import { DateUtils } from '../common/DateUtils'

@Entry
@Component
export struct EditPet {
  @State petId: number = 0
  @State name: string = ''
  @State species: string = '猫'
  @State breed: string = ''
  @State birthDate: string = DateUtils.today()
  @State gender: string = '未知'
  @State avatarUri: string = ''
  private speciesList: string[] = ['猫', '狗', '鸟', '兔', '其他']
  private genderList: string[] = ['公', '母', '未知']

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>
    this.petId = Number(params?.petId ?? 0)
    if (this.petId > 0) {
      this.loadPet()
    }
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadPet(): Promise<void> {
    const dao: PetDao = new PetDao(this.getAbilityContext())
    const pet: Pet | null = await dao.queryById(this.petId)
    if (!pet) {
      return
    }
    this.name = pet.name
    this.species = pet.species
    this.breed = pet.breed
    this.birthDate = pet.birthDate
    this.gender = pet.gender
    this.avatarUri = pet.avatarUri
  }

  private async chooseAvatar(): Promise<void> {
    const picker = new photoAccessHelper.PhotoViewPicker()
    const bridge = picker as unknown as Record<string, Function>
    let result: Record<string, Object> | null = null
    if (typeof bridge.select === 'function') {
      result = await bridge.select({ maxSelectNumber: 1, MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE }) as Record<string, Object>
    }
    const photoUris = result?.photoUris as Array<Record<string, string> | string> | undefined
    const firstItem = photoUris?.[0]
    const uri: string = typeof firstItem === 'string' ? firstItem : (firstItem?.uri ?? '')
    if (uri) {
      this.avatarUri = uri
    }
  }

  private async savePet(): Promise<void> {
    if (!this.name.trim()) {
      return
    }
    const dao: PetDao = new PetDao(this.getAbilityContext())
    if (this.petId > 0) {
      await dao.update({
        id: this.petId,
        name: this.name,
        species: this.species,
        breed: this.breed,
        birthDate: this.birthDate,
        gender: this.gender,
        avatarUri: this.avatarUri,
        createdAt: DateUtils.nowTimestamp()
      })
      AppStorage.setOrCreate('activePetId', this.petId)
      AppStorage.setOrCreate('activePetName', this.name)
    } else {
      const id: number = await dao.insert({
        name: this.name,
        species: this.species,
        breed: this.breed,
        birthDate: this.birthDate,
        gender: this.gender,
        avatarUri: this.avatarUri,
        createdAt: DateUtils.nowTimestamp()
      })
      AppStorage.setOrCreate('activePetId', id)
      AppStorage.setOrCreate('activePetName', this.name)
    }
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    this.goBack()
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  @Builder buildOptionGroup(title: string, options: string[], selected: string, onSelect: (value: string) => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(14)
        .fontColor('#666666')
      Row({ space: 8 }) {
        ForEach(options, (item: string) => {
          Button(item)
            .type(ButtonType.Capsule)
            .backgroundColor(item === selected ? '#FF8A00' : '#FFFFFF')
            .fontColor(item === selected ? '#FFFFFF' : '#555555')
            .onClick(() => onSelect(item))
        }, (item: string) => item)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('取消')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFFFFF')
            .fontColor('#666666')
            .onClick(() => this.goBack())
          Blank()
          Text(this.petId > 0 ? '编辑宠物' : '新增宠物')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          Blank()
          Button('保存')
            .type(ButtonType.Capsule)
            .onClick(() => this.savePet())
        }

        Column({ space: 12 }) {
          if (this.avatarUri) {
            Image(this.avatarUri)
              .width(96)
              .height(96)
              .borderRadius(48)
              .objectFit(ImageFit.Cover)
          } else {
            Stack() {
              Text('头像')
                .fontSize(16)
                .fontColor('#999999')
            }
            .width(96)
            .height(96)
            .borderRadius(48)
            .backgroundColor('#FFF6E9')
          }
          Button('选择头像')
            .type(ButtonType.Capsule)
            .onClick(() => this.chooseAvatar())
        }
        .width('100%')

        Column({ space: 12 }) {
          TextInput({ placeholder: '名字', text: this.name })
            .onChange((value: string) => this.name = value)
            .height(52)
            .backgroundColor('#FFFFFF')
          TextInput({ placeholder: '品种', text: this.breed })
            .onChange((value: string) => this.breed = value)
            .height(52)
            .backgroundColor('#FFFFFF')
          this.buildOptionGroup('物种', this.speciesList, this.species, (value: string) => this.species = value)
          this.buildOptionGroup('性别', this.genderList, this.gender, (value: string) => this.gender = value)
          Column({ space: 8 }) {
            Text('出生日期')
              .fontSize(14)
              .fontColor('#666666')
            DatePicker({
              start: new Date('2010-01-01'),
              end: new Date(),
              selected: new Date(`${this.birthDate}T00:00:00`)
            })
              .onChange((value: Date) => {
                this.birthDate = DateUtils.toDateOnly(value)
              })
              .backgroundColor('#FFFFFF')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding(16)
        .borderRadius(20)
        .backgroundColor('#FDFDFD')
      }
      .padding(16)
      .width('100%')
      .backgroundColor('#F6F7FB')
    }
  }
}
