import common from '@ohos.app.ability.common'
import router from '@ohos.router'
import DatabaseService from '../service/DatabaseService'
import qrService from '../service/QRService'
import { QRRecord } from '../model/QRRecord'
import { DEFAULT_RECORD, STORAGE_KEYS } from '../utils/Constants'
import { ParsedResult, ResultParser } from '../utils/ResultParser'

@Component
export default struct ResultPage {
  @State private record: QRRecord = DEFAULT_RECORD
  @State private parsedResult: ParsedResult = ResultParser.parse('')
  private context = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    await DatabaseService.init(this.context)
    const params = router.getParams() as Record<string, string>
    const recordText = String(params?.record ?? '')
    if (recordText) {
      const rawRecord = JSON.parse(recordText) as QRRecord
      this.record = new QRRecord(rawRecord)
      this.parsedResult = ResultParser.parse(this.record.content)
    }
  }

  private async copyRawText(): Promise<void> {
    await qrService.copyToClipboard(this.record.content)
    qrService.showToast('内容已复制')
  }

  private async toggleFavorite(): Promise<void> {
    const nextFavorite = this.record.isFavorite === 1 ? 0 : 1
    await DatabaseService.toggleFavorite(this.record.id, nextFavorite === 1)
    this.record = new QRRecord({ ...this.record, isFavorite: nextFavorite })
    AppStorage.setOrCreate(STORAGE_KEYS.HISTORY_REFRESH, Date.now())
    qrService.showToast(nextFavorite === 1 ? '已加入收藏' : '已取消收藏')
  }

  @Builder
  private TypeDetailBuilder() {
    if (this.parsedResult.contentType === 'url') {
      Column({ space: 10 }) {
        Text('检测到链接')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF0F172A')
          .width('100%')
        Text(this.record.content)
          .fontSize(15)
          .fontColor('#FF0A59F7')
          .width('100%')
        Button('浏览器打开')
          .type(ButtonType.Capsule)
          .backgroundColor('#FF0A59F7')
          .fontColor(Color.White)
          .onClick(() => {
            qrService.showToast('请接入系统浏览器能力打开链接')
          })
      }
      .alignItems(HorizontalAlign.Start)
    } else if (this.parsedResult.contentType === 'wifi') {
      Column({ space: 10 }) {
        Text(`SSID：${this.parsedResult.wifiSsid ?? ''}`)
          .fontSize(16)
          .fontColor('#FF0F172A')
          .width('100%')
        Text(`密码：${this.parsedResult.wifiPassword ?? ''}`)
          .fontSize(16)
          .fontColor('#FF0F172A')
          .width('100%')
        Text(`加密：${this.parsedResult.wifiEncryption ?? ''}`)
          .fontSize(14)
          .fontColor('#FF64748B')
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
    } else if (this.parsedResult.contentType === 'vcard') {
      Column({ space: 10 }) {
        Text(`姓名：${this.parsedResult.vcardName ?? ''}`)
          .fontSize(16)
          .fontColor('#FF0F172A')
          .width('100%')
        Text(`电话：${this.parsedResult.vcardPhone ?? ''}`)
          .fontSize(16)
          .fontColor('#FF0F172A')
          .width('100%')
        Text(`邮箱：${this.parsedResult.vcardEmail ?? ''}`)
          .fontSize(14)
          .fontColor('#FF64748B')
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
    } else {
      Text(this.record.content)
        .fontSize(16)
        .fontColor('#FF0F172A')
        .width('100%')
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('返回')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFE2E8F0')
            .fontColor('#FF0F172A')
            .onClick(() => {
              router.back()
            })
          Blank()
          Button(this.record.isFavorite === 1 ? '取消收藏' : '收藏')
            .type(ButtonType.Capsule)
            .backgroundColor(this.record.isFavorite === 1 ? '#FFF59E0B' : '#FF0A59F7')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.toggleFavorite()
            })
        }

        Column({ space: 8 }) {
          Text(this.parsedResult.displayTitle)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0F172A')
            .width('100%')
          Text(this.parsedResult.displaySubtitle)
            .fontSize(14)
            .fontColor('#FF64748B')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 14 }) {
          this.TypeDetailBuilder()
        }
        .padding(20)
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(24)
        .alignItems(HorizontalAlign.Start)

        Row({ space: 12 }) {
          Button('复制内容')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FF0A59F7')
            .fontColor(Color.White)
            .onClick(async () => {
              await this.copyRawText()
            })
          Button('复制解析结果')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor('#FFE2E8F0')
            .fontColor('#FF0F172A')
            .onClick(async () => {
              await qrService.copyToClipboard(JSON.stringify(this.parsedResult))
              qrService.showToast('解析结果已复制')
            })
        }
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8FAFC')
  }
}
