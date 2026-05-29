import photoAccessHelper from '@ohos.file.photoAccessHelper'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'
import { createEmptySpot, SpotModel } from '../model/SpotModel'
import { DatabaseService } from '../service/DatabaseService'
import { LocationService } from '../service/LocationService'
import { AchievementService } from '../service/AchievementService'

@Component
export struct AddSpotPage {
  @Prop pathStack: NavPathStack
  @StorageLink('refreshToken') refreshToken: number = 0
  @StorageLink('abilityContext') abilityContext: common.UIAbilityContext | null = null
  @State private spot: SpotModel = createEmptySpot()
  @State private mood: string = '惊喜'
  @State private weather: string = '晴朗'
  @State private note: string = ''
  @State private photoUris: string[] = []
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()
  private readonly locationService: LocationService = LocationService.getInstance()
  private readonly achievementService: AchievementService = AchievementService.getInstance()

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text($r('app.string.title_add_spot'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        TextInput({ placeholder: $r('app.string.placeholder_spot_name'), text: this.spot.name })
          .onChange((value: string) => {
            this.spot = { ...this.spot, name: value }
          })
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        TextInput({ placeholder: $r('app.string.placeholder_address'), text: this.spot.address })
          .onChange((value: string) => {
            this.spot = { ...this.spot, address: value }
          })
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        TextInput({ placeholder: $r('app.string.placeholder_city'), text: this.spot.city })
          .onChange((value: string) => {
            this.spot = { ...this.spot, city: value }
          })
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        TextInput({ placeholder: $r('app.string.placeholder_category'), text: this.spot.category })
          .onChange((value: string) => {
            this.spot = { ...this.spot, category: value }
          })
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        Row({ space: 10 }) {
          TextInput({ placeholder: $r('app.string.placeholder_latitude'), text: `${this.spot.latitude}` })
            .onChange((value: string) => {
              this.spot = { ...this.spot, latitude: Number(value) || 0 }
            })
            .layoutWeight(1)
            .height(52)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          TextInput({ placeholder: $r('app.string.placeholder_longitude'), text: `${this.spot.longitude}` })
            .onChange((value: string) => {
              this.spot = { ...this.spot, longitude: Number(value) || 0 }
            })
            .layoutWeight(1)
            .height(52)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
        }
        Button($r('app.string.button_resolve_city'))
          .width('100%')
          .height(44)
          .backgroundColor('#EAF1FF')
          .fontColor('#0A59F7')
          .onClick(() => {
            this.resolveCity()
          })
        TextInput({ placeholder: $r('app.string.placeholder_note'), text: this.note })
          .onChange((value: string) => {
            this.note = value
          })
          .height(88)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        Row({ space: 10 }) {
          TextInput({ placeholder: $r('app.string.placeholder_mood'), text: this.mood })
            .onChange((value: string) => {
              this.mood = value
            })
            .layoutWeight(1)
            .height(52)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          TextInput({ placeholder: $r('app.string.placeholder_weather'), text: this.weather })
            .onChange((value: string) => {
              this.weather = value
            })
            .layoutWeight(1)
            .height(52)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
        }
        Button($r('app.string.button_pick_photos'))
          .width('100%')
          .height(44)
          .onClick(() => {
            this.pickPhotos()
          })
        if (this.photoUris.length > 0) {
          Text('已选择 ' + this.photoUris.length + ' 张照片')
            .fontSize(13)
            .fontColor('#666666')
            .width('100%')
        }
        Button($r('app.string.button_checkin_now'))
          .width('100%')
          .height(48)
          .onClick(() => {
            this.saveSpotAndCheckIn()
          })
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private async resolveCity(): Promise<void> {
    if (this.spot.latitude === 0 && this.spot.longitude === 0) {
      return
    }
    const result = await this.locationService.reverseGeocode(this.spot.latitude, this.spot.longitude)
    this.spot = {
      ...this.spot,
      city: result.city.length > 0 ? result.city : this.spot.city,
      address: result.address.length > 0 && this.spot.address.length === 0 ? result.address : this.spot.address
    }
  }

  private async pickPhotos(): Promise<void> {
    try {
      const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const result: photoAccessHelper.PhotoSelectResult = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9
      })
      this.photoUris = result.photoUris ?? []
      if (this.photoUris.length > 0) {
        this.spot = { ...this.spot, coverUri: this.photoUris[0] }
      }
    } catch (error) {
      promptAction.showToast({ message: $r('app.string.toast_pick_photo_fail') })
    }
  }

  private async saveSpotAndCheckIn(): Promise<void> {
    const spotToSave: SpotModel = {
      ...this.spot,
      createdAt: Date.now(),
      checkInCount: 0
    }
    await this.databaseService.addSpotAndCheckIn(spotToSave, {
      checkInAt: Date.now(),
      mood: this.mood,
      weather: this.weather,
      note: this.note
    }, this.photoUris)
    if (this.abilityContext) {
      await this.achievementService.evaluateAndNotify(this.abilityContext)
    }
    this.refreshToken = this.refreshToken + 1
    promptAction.showToast({ message: $r('app.string.toast_add_success') })
    this.pathStack.pop()
  }
}
