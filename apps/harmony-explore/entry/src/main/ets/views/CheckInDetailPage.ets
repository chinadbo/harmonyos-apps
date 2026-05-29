import { CheckInDetailModel } from '../model/CheckInModel'
import { DatabaseService } from '../service/DatabaseService'
import { PhotoGrid } from '../components/PhotoGrid'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct CheckInDetailPage {
  @StorageLink('selectedCheckInId') selectedCheckInId: number = 0
  @State private detail: CheckInDetailModel | null = null
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()

  aboutToAppear(): void {
    this.loadDetail()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.detail) {
          Text(this.detail!.spotName)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(`${this.detail!.city} · ${this.detail!.address}`)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
          Row({ space: 10 }) {
            Text('打卡时间：' + DateUtils.formatDateTime(this.detail!.checkInAt))
              .fontSize(13)
              .fontColor('#333333')
            Text('心情：' + (this.detail!.mood || '未记录'))
              .fontSize(13)
              .fontColor('#333333')
            Text('天气：' + (this.detail!.weather || '未记录'))
              .fontSize(13)
              .fontColor('#333333')
          }
          .width('100%')
          Column({ space: 8 }) {
            Text($r('app.string.label_explore_record'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
            Text(this.detail!.note.length > 0 ? this.detail!.note : $r('app.string.label_empty_note_detail'))
              .fontSize(15)
              .fontColor('#333333')
              .width('100%')
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          Column({ space: 12 }) {
            Text($r('app.string.label_photo_grid'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .width('100%')
            PhotoGrid({ photoUris: this.detail!.photoUris })
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        } else {
          Column() {
            Text($r('app.string.empty_checkin_detail'))
              .fontSize(14)
              .fontColor('#8A8A8A')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private async loadDetail(): Promise<void> {
    this.detail = await this.databaseService.getCheckInDetail(this.selectedCheckInId)
  }
}
