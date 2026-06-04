import promptAction from '@ohos.promptAction';
import { Vehicle, createEmptyVehicle } from '../models/Vehicle';
import { carService } from '../services/CarService';
import { notEmptyText, parseInteger } from '../utils/Formatters';
import { VehicleFormView } from '../views/VehicleFormView';

@Component
export struct CarEditPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @Prop params: Object = {};

  @State vehicleId: number = 0;
  @State plateNumber: string = '';
  @State brand: string = '';
  @State model: string = '';
  @State purchaseDate: string = '';
  @State mileageText: string = '0';
  @State vin: string = '';
  @State insuranceExpiry: string = '';
  @State inspectionExpiry: string = '';
  @State color: string = '白色';
  @State isDefault: boolean = false;
  @State createdAt: string = '';

  aboutToAppear(): void {
    const payload: Record<string, number> = this.params as Record<string, number>;
    this.vehicleId = payload['vehicleId'] ?? 0;
    this.loadVehicle();
  }

  private async loadVehicle(): Promise<void> {
    const vehicle: Vehicle = this.vehicleId > 0 ? await carService.getById(this.vehicleId) : createEmptyVehicle();
    this.plateNumber = vehicle.plateNumber;
    this.brand = vehicle.brand;
    this.model = vehicle.model;
    this.purchaseDate = vehicle.purchaseDate;
    this.mileageText = `${vehicle.mileage}`;
    this.vin = vehicle.vin;
    this.insuranceExpiry = vehicle.insuranceExpiry;
    this.inspectionExpiry = vehicle.inspectionExpiry;
    this.color = vehicle.color;
    this.isDefault = vehicle.isDefault;
    this.createdAt = vehicle.createdAt;
  }

  private async save(): Promise<void> {
    const payload: Vehicle = {
      id: this.vehicleId,
      plateNumber: notEmptyText(this.plateNumber, '未命名车牌'),
      brand: notEmptyText(this.brand, '未知品牌'),
      model: notEmptyText(this.model, '未知车型'),
      purchaseDate: this.purchaseDate,
      mileage: parseInteger(this.mileageText),
      vin: this.vin,
      insuranceExpiry: this.insuranceExpiry,
      inspectionExpiry: this.inspectionExpiry,
      color: this.color,
      isDefault: this.isDefault,
      createdAt: this.createdAt
    };
    await carService.save(payload);
    promptAction.showToast({ message: '车辆已保存' });
    this.stack.pop();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        VehicleFormView({
          plateNumber: $plateNumber,
          brand: $brand,
          model: $model,
          purchaseDate: $purchaseDate,
          mileageText: $mileageText,
          vin: $vin,
          insuranceExpiry: $insuranceExpiry,
          inspectionExpiry: $inspectionExpiry,
          color: $color,
          isDefault: $isDefault
        })
        Button('保存车辆')
          .width('100%')
          .height(44)
          .backgroundColor('#4E7BF2')
          .onClick(() => {
            this.save();
          })
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F3F6FB')
  }
}
