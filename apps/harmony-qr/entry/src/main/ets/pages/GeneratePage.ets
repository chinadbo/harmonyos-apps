import common from '@ohos.app.ability.common'
import DatabaseService from '../service/DatabaseService'
import qrService from '../service/QRService'
import { DEFAULT_QR_SIZE, MAX_QR_SIZE, MIN_QR_SIZE, PRESET_COLORS, STORAGE_KEYS } from '../utils/Constants'

@Component
export default struct GeneratePage {
  @StorageLink('main_tab_index') private mainTabIndex: number = 0
  @State private content: string = 'https://example.com'
  @State private fgColor: string = PRESET_COLORS[0]
  @State private bgColor: string = '#FFFFFF'
  @State private qrSize: number = DEFAULT_QR_SIZE
  private readonly previewId: string = 'qr_preview_component'
  private context = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    await DatabaseService.init(this.context)
  }

  private async saveRecord(): Promise<void> {
    const record = qrService.createRecord('generate', this.content.trim(), this.fgColor, this.bgColor)
    await DatabaseService.insert(record)
    AppStorage.setOrCreate(STORAGE_KEYS.HISTORY_REFRESH, Date.now())
  }

  private async copyContent(): Promise<void> {
    await qrService.copyToClipboard(this.content.trim())
    qrService.showToast('内容已复制')
  }

  private async saveImage(): Promise<void> {
    if (!this.content.trim()) {
      qrService.showToast('请输入要生成的内容')
      return
    }
    await this.saveRecord()
    await qrService.saveToAlbum(this.context, this.previewId)
    qrService.showToast('二维码已保存到相册')
  }

  private async shareImage(): Promise<void> {
    if (!this.content.trim()) {
      qrService.showToast('请输入要生成的内容')
      return
    }
    await this.saveRecord()
    const uri = await qrService.saveToAlbum(this.context, this.previewId)
    await qrService.shareImage(this.context, uri)
    qrService.showToast('已生成分享资源')
  }

  @Builder
  private ColorSelector(title: string, selectedColor: string, onChange: (color: string) => void) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(14)
        .fontColor('#FF334155')
        .width('100%')
      Row({ space: 10 }) {
        ForEach(PRESET_COLORS, (color: string) => {
          Stack({ alignContent: Alignment.Center }) {
            Row()
              .width(32)
              .height(32)
              .borderRadius(16)
              .backgroundColor(color)
              .border({ width: selectedColor === color ? 3 : 1, color: selectedColor === color ? '#FF0A59F7' : '#FFD1D5DB' })
            if (selectedColor === color) {
              Text('✓')
                .fontSize(14)
                .fontColor(color === '#000000' ? Color.White : Color.Black)
            }
          }
          .onClick(() => {
            onChange(color)
          })
        })
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Column({ space: 10 }) {
          Text('二维码生成')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0F172A')
            .width('100%')
          Text('输入文本、链接、WiFi 配置或名片信息，实时生成二维码。')
            .fontSize(14)
            .fontColor('#FF64748B')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          TextArea({ text: this.content, placeholder: '请输入要编码的内容' })
            .width('100%')
            .height(140)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .padding(14)
            .fontSize(16)
            .onChange((value: string) => {
              this.content = value
            })

          Column({ space: 16 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column() {
                QRCode(this.content || ' ')
                  .width(this.qrSize)
                  .height(this.qrSize)
                  .color(this.fgColor as ResourceColor)
                  .backgroundColor(this.bgColor as ResourceColor)
              }
              .id(this.previewId)
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius(28)
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#FFEFF6FF')
            .borderRadius(28)
          }
        }

        this.ColorSelector('前景色', this.fgColor, (color: string) => {
          this.fgColor = color
        })

        this.ColorSelector('背景色', this.bgColor, (color: string) => {
          this.bgColor = color
        })

        Column({ space: 10 }) {
          Row() {
            Text('尺寸')
              .fontSize(14)
              .fontColor('#FF334155')
            Blank()
            Text(`${Math.round(this.qrSize)} px`)
              .fontSize(14)
              .fontColor('#FF0A59F7')
          }
          Slider({ value: this.qrSize, min: MIN_QR_SIZE, max: MAX_QR_SIZE, step: 10 })
            .onChange((value: number) => {
              this.qrSize = value
            })
        }

        Row({ space: 12 }) {
          Button('保存到相册')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FF0A59F7')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.saveImage()
            })
          Button('复制内容')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FFE2E8F0')
            .fontColor('#FF0F172A')
            .onClick(async () => {
              await this.copyContent()
            })
          Button('分享')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FF14B866')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.shareImage()
            })
        }

        Button('查看历史')
          .width('100%')
          .height(44)
          .type(ButtonType.Capsule)
          .backgroundColor('#FFF1F5F9')
          .fontColor('#FF334155')
          .onClick(() => {
            this.mainTabIndex = 2
          })
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8FAFC')
  }
}
