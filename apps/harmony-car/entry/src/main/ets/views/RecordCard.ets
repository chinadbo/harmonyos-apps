import { MaintenanceRecord } from '../models/MaintenanceRecord';
import { formatCurrencyFromCent, formatDate, formatMileage } from '../utils/Formatters';

@Component
export struct RecordCard {
  @Prop record: MaintenanceRecord = {
    id: 0,
    vehicleId: 0,
    type: '',
    date: '',
    mileage: 0,
    cost: 0,
    shop: '',
    note: '',
    nextDate: '',
    nextMileage: 0,
    photos: [],
    createdAt: ''
  };
  onEdit?: (recordId: number) => void;

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.record.type)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2D3D')
          .layoutWeight(1)
        Text(formatCurrencyFromCent(this.record.cost))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4E7BF2')
      }
      .width('100%')
      Text(`${formatDate(this.record.date)} · ${formatMileage(this.record.mileage)}`)
        .fontSize(13)
        .fontColor('#5B6B7C')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.record.shop)
        .fontSize(14)
        .fontColor('#1F2D3D')
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.record.note)
        .fontSize(13)
        .fontColor('#5B6B7C')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Start)
      Button('编辑记录')
        .width('100%')
        .height(38)
        .backgroundColor('#EAF0FF')
        .fontColor('#4E7BF2')
        .onClick(() => {
          if (this.onEdit) {
            this.onEdit(this.record.id);
          }
        })
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('100%')
  }
}
