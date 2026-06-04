import { Vehicle } from '../models/Vehicle';
import { formatDate, formatMileage } from '../utils/Formatters';

@Component
export struct VehicleCard {
  @Prop vehicle: Vehicle = {
    id: 0,
    plateNumber: '',
    brand: '',
    model: '',
    purchaseDate: '',
    mileage: 0,
    vin: '',
    insuranceExpiry: '',
    inspectionExpiry: '',
    color: '',
    isDefault: false,
    createdAt: ''
  };
  onEdit?: (vehicleId: number) => void;

  build() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.vehicle.plateNumber)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#16202A')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`${this.vehicle.brand} ${this.vehicle.model}`)
            .fontSize(15)
            .fontColor('#5B6B7C')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)

        if (this.vehicle.isDefault) {
          Text('默认车辆')
            .fontSize(12)
            .fontColor('#4E7BF2')
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#EAF0FF')
            .borderRadius(12)
        }
      }
      .width('100%')
      Row({ space: 12 }) {
        Text(`里程 ${formatMileage(this.vehicle.mileage)}`)
          .fontSize(13)
          .fontColor('#5B6B7C')
        Text(`保险 ${formatDate(this.vehicle.insuranceExpiry)}`)
          .fontSize(13)
          .fontColor('#5B6B7C')
        Text(`年检 ${formatDate(this.vehicle.inspectionExpiry)}`)
          .fontSize(13)
          .fontColor('#5B6B7C')
      }
      .width('100%')

      Button('编辑车辆')
        .width('100%')
        .height(40)
        .backgroundColor('#4E7BF2')
        .onClick(() => {
          if (this.onEdit) {
            this.onEdit(this.vehicle.id);
          }
        })
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('100%')
  }
}
