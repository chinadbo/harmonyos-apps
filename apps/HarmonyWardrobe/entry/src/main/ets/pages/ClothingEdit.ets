import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { Clothing, ColorOption, WardrobeCategory, WardrobeSeason, categoryValues, seasonValues,
  WARDROBE_COLORS, toFileUri } from '../model/WardrobeModels'
import { ImageHelper } from '../common/ImageHelper'
import { WardrobeDb } from '../data/WardrobeDb'
import { showToast } from '../common/UiUtils'

@Entry
@Component
struct ClothingEdit {
  @State editingId: number = -1
  @State name: string = ''
  @State category: string = WardrobeCategory.TOP
  @State colorIndex: number = 0
  @State season: string = WardrobeSeason.ALL
  @State imagePath: string = ''
  private categories: string[] = categoryValues()
  private seasons: string[] = seasonValues()
  private colors: ColorOption[] = WARDROBE_COLORS

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params !== undefined && params !== null && params.id !== undefined) {
      this.editingId = Number(params.id)
      this.loadExisting()
    }
  }

  async loadExisting(): Promise<void> {
    const c = await WardrobeDb.getInstance().getClothingById(this.editingId)
    if (c !== null) {
      this.name = c.name
      this.category = c.category
      this.season = c.season
      this.imagePath = c.imagePath
      for (let i = 0; i < this.colors.length; i++) {
        if (this.colors[i].name === c.colorName) {
          this.colorIndex = i
          break
        }
      }
    }
  }

  async pickImage(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext
    const path = await ImageHelper.pickAndCopyToSandbox(context)
    if (path !== '') {
      this.imagePath = path
    }
  }

  async save(): Promise<void> {
    if (this.name === '') {
      showToast('请填写衣物名称')
      return
    }
    const db = WardrobeDb.getInstance()
    const clothing = new Clothing(this.editingId, this.name, this.category,
      this.colors[this.colorIndex].name, this.season, this.imagePath, false, Date.now())
    if (this.editingId >= 0) {
      await db.updateClothing(clothing)
    } else {
      await db.insertClothing(clothing)
    }
    showToast('已保存')
    router.back()
  }

  async remove(): Promise<void> {
    if (this.editingId < 0) {
      return
    }
    await WardrobeDb.getInstance().deleteClothing(this.editingId)
    showToast('已删除')
    router.back()
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor('#2B3A4A')
      .margin({ top: 18, bottom: 8 })
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#2B3A4A')
          .padding({ left: 12, right: 8 })
          .onClick(() => {
            router.back()
          })
        Text(this.editingId >= 0 ? '编辑衣物' : '添加衣物')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B3A4A')
          .layoutWeight(1)
        if (this.editingId >= 0) {
          Text('删除')
            .fontSize(14)
            .fontColor('#C62828')
            .padding({ left: 12, right: 16 })
            .onClick(() => {
              this.remove()
            })
        } else {
          Blank()
            .width(16)
        }
      }
      .width('100%')
      .height(52)
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          Row({ space: 12 }) {
            if (this.imagePath !== '') {
              Image(toFileUri(this.imagePath))
                .width(96)
                .height(96)
                .borderRadius(12)
                .objectFit(ImageFit.Cover)
                .onClick(() => {
                  this.pickImage()
                })
            } else {
              Column() {
                Text('📷')
                  .fontSize(30)
                Text('点击选择图片')
                  .fontSize(12)
                  .fontColor('#8A97A5')
                  .margin({ top: 4 })
              }
              .width(96)
              .height(96)
              .borderRadius(12)
              .backgroundColor('#EEF1F5')
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.pickImage()
              })
            }
            Column() {
              Text('从系统图库选择照片')
                .fontSize(13)
                .fontColor('#2B3A4A')
              Text('通过系统 Picker 选择，无需任何权限，图片复制到应用沙箱保存')
                .fontSize(12)
                .fontColor('#8A97A5')
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          TextInput({ text: this.name, placeholder: '衣物名称（如：白色卫衣）' })
            .fontSize(14)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .height(44)
            .margin({ top: 12 })
            .onChange((value: string) => {
              this.name = value
            })

          this.SectionTitle('分类')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.categories, (cat: string) => {
              Text(cat)
                .fontSize(13)
                .fontColor(this.category === cat ? Color.White : '#6B7684')
                .backgroundColor(this.category === cat ? '#3E5C76' : '#F0F2F5')
                .borderRadius(14)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin(4)
                .onClick(() => {
                  this.category = cat
                })
            }, (cat: string) => cat)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          this.SectionTitle('颜色')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.colors, (opt: ColorOption, index: number) => {
              Row({ space: 6 }) {
                Circle()
                  .width(16)
                  .height(16)
                  .fill(opt.hex)
                  .border({ width: 1, color: '#D5DBE1' })
                Text(opt.name)
                  .fontSize(13)
                  .fontColor('#6B7684')
              }
              .borderRadius(14)
              .backgroundColor(this.colorIndex === index ? '#DCE6F0' : '#F0F2F5')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin(4)
              .onClick(() => {
                this.colorIndex = index
              })
            }, (opt: ColorOption, index: number) => `${opt.name}_${index}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          this.SectionTitle('季节')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.seasons, (season: string) => {
              Text(season)
                .fontSize(13)
                .fontColor(this.season === season ? Color.White : '#6B7684')
                .backgroundColor(this.season === season ? '#3E5C76' : '#F0F2F5')
                .borderRadius(14)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin(4)
                .onClick(() => {
                  this.season = season
                })
            }, (season: string) => season)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          Row({ space: 12 }) {
            Button(this.editingId >= 0 ? '保存修改' : '添加到衣柜')
              .fontSize(16)
              .backgroundColor('#3E5C76')
              .borderRadius(22)
              .layoutWeight(1)
              .margin({ top: 24 })
              .onClick(() => {
                this.save()
              })
          }
          .width('100%')
          .padding(16)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }
}
