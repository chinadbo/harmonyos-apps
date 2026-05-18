import { PackageStatus, type PackageRecord } from '../model/PackageModel';
import { StatusBadge } from './StatusBadge';

const EMPTY_PACKAGE: PackageRecord = {
  trackingNo: '',
  courierCode: '',
  courierName: '',
  remark: '',
  status: PackageStatus.PENDING,
  lastUpdate: '',
  latestDesc: '',
  isArchived: false,
  createdAt: ''
};

@Component
export struct PackageCard {
  @Prop record: PackageRecord = EMPTY_PACKAGE;

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.record.courierName || '未识别快递')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(this.record.trackingNo)
            .fontSize(13)
            .fontColor('#475467')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        StatusBadge({ status: this.record.status })
      }
      .width('100%')

      Text(this.record.latestDesc)
        .fontSize(14)
        .fontColor('#344054')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row() {
        Text(this.record.remark || '无备注')
          .fontSize(12)
          .fontColor('#667085')
        Blank()
        Text(this.record.lastUpdate)
          .fontSize(12)
          .fontColor('#98A2B3')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
