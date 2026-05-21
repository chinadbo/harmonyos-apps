import image from '@ohos.multimedia.image'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import fileIo from '@ohos.file.fs'
import { FilterParams } from '../model/FilterParams'
import { FilterService } from '../service/FilterService'
import { PhotoService } from '../service/PhotoService'
import { FilterPanel } from '../components/FilterPanel'


@Component
export struct EditView {
  @State private selectedUri: string = ''
  @State private filterParams: FilterParams = new FilterParams()
  @State private previewPixelMap: image.PixelMap | null = null
  @State private isProcessing: boolean = false
  @State private savedTip: boolean = false
  private originalPixelMap: image.PixelMap | null = null
  private presets: Array<{ name: string; params: FilterParams }> = FilterService.getPresets()

  private async pickPhoto(): Promise<void> {
    try {
      let photos = await PhotoService.selectPhotos()
      if (photos.length === 0) return
      this.selectedUri = photos[0].uri
      this.originalPixelMap = await PhotoService.getPixelMap(this.selectedUri)
      this.filterParams = new FilterParams()
      await this.refreshPreview()
    } catch (err) {
      console.error(`pickPhoto error: ${JSON.stringify(err)}`)
    }
  }

  private async refreshPreview(): Promise<void> {
    if (!this.originalPixelMap) return
    this.isProcessing = true
    this.previewPixelMap = await FilterService.applyFilters(this.originalPixelMap, this.filterParams)
    this.isProcessing = false
  }

  private async applyPreset(params: FilterParams): Promise<void> {
    let next = new FilterParams()
    next.brightness = params.brightness
    next.contrast = params.contrast
    next.saturate = params.saturate
    next.blur = params.blur
    next.presetName = params.presetName
    this.filterParams = next
    await this.refreshPreview()
  }

  private async saveToAlbum(): Promise<void> {
    if (!this.previewPixelMap) return
    try {
      let context = getContext(this) as Context
      let helper = photoAccessHelper.getPhotoAccessHelper(context)
      // API 12: createAsset(photoType, extension, options?) 返回 uri string
      let assetUri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
      let file = await fileIo.open(assetUri, fileIo.OpenMode.READ_WRITE)
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 95 }
      let imagePacker = image.createImagePacker()
      let packed = await imagePacker.packing(this.previewPixelMap, packOpts)
      await fileIo.write(file.fd, packed)
      await fileIo.close(file)
      this.savedTip = true
      // 使用 @ohos.timer 兼容的延时关闭 tip
      let timerId = setInterval(() => {
        this.savedTip = false
        clearInterval(timerId)
      }, 2000)
    } catch (err) {
      console.error(`saveToAlbum error: ${JSON.stringify(err)}`)
    }
  }

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        Text('编辑')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Button('保存')
          .height(36)
          .backgroundColor('#2196F3')
          .fontColor(Color.White)
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.saveToAlbum()
          })
          .enabled(this.previewPixelMap !== null && !this.isProcessing)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 图片预览区
      Stack({ alignContent: Alignment.Center }) {
        if (this.previewPixelMap) {
          Image(this.previewPixelMap)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
            .borderRadius(12)
        } else {
          Column() {
            Text('📷')
              .fontSize(48)
            Text('点击选择照片')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
            Button('选择照片')
              .margin({ top: 16 })
              .onClick(() => {
                this.pickPhoto()
              })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }

        if (this.isProcessing) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#2196F3')
        }

        if (this.savedTip) {
          Text('已保存到相册')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#CC000000')
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 4, bottom: 4 })
      .backgroundColor('#000000')
      .borderRadius(12)
      .margin({ left: 12, right: 12 })
      .onClick(() => {
        if (!this.selectedUri) {
          this.pickPhoto()
        }
      })

      // 编辑面板（仅选图后显示）
      if (this.selectedUri.length > 0) {
        Column() {
          // 滤镜预设
          FilterPanel({
            presets: this.presets,
            currentPresetName: this.filterParams.presetName,
            onPresetChange: (params: FilterParams) => {
              this.applyPreset(params)
            }
          })

          // 精细调节 Sliders
          this.sliderRow('亮度', this.filterParams.brightness, -1, 1, (v: number) => {
            let next = new FilterParams()
            next.brightness = v
            next.contrast = this.filterParams.contrast
            next.saturate = this.filterParams.saturate
            next.blur = this.filterParams.blur
            next.presetName = '自定义'
            this.filterParams = next
            this.refreshPreview()
          })

          this.sliderRow('对比度', this.filterParams.contrast, -1, 1, (v: number) => {
            let next = new FilterParams()
            next.brightness = this.filterParams.brightness
            next.contrast = v
            next.saturate = this.filterParams.saturate
            next.blur = this.filterParams.blur
            next.presetName = '自定义'
            this.filterParams = next
            this.refreshPreview()
          })

          this.sliderRow('饱和度', this.filterParams.saturate, -1, 1, (v: number) => {
            let next = new FilterParams()
            next.brightness = this.filterParams.brightness
            next.contrast = this.filterParams.contrast
            next.saturate = v
            next.blur = this.filterParams.blur
            next.presetName = '自定义'
            this.filterParams = next
            this.refreshPreview()
          })

          this.sliderRow('模糊', this.filterParams.blur, 0, 20, (v: number) => {
            let next = new FilterParams()
            next.brightness = this.filterParams.brightness
            next.contrast = this.filterParams.contrast
            next.saturate = this.filterParams.saturate
            next.blur = v
            next.presetName = '自定义'
            this.filterParams = next
            this.refreshPreview()
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  sliderRow(label: string, value: number, min: number, max: number, onChange: (v: number) => void) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666666')
        .width(50)

      Slider({
        value: value,
        min: min,
        max: max,
        step: 0.01
      })
        .layoutWeight(1)
        .blockColor('#2196F3')
        .trackColor('#E0E0E0')
        .selectedColor('#2196F3')
        .onChange((val: number) => {
          onChange(val)
        })

      Text(value.toFixed(1))
        .fontSize(11)
        .fontColor('#999999')
        .width(32)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .margin({ bottom: 4 })
  }
}
