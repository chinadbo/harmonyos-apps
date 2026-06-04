import { Vehicle } from '../models/Vehicle';
import { carService } from '../services/CarService';
import { PAGE_CAR_EDIT } from '../utils/Constants';
import { SectionHeader } from '../views/SectionHeader';
import { VehicleCard } from '../views/VehicleCard';

@Component
export struct CarListPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @State vehicles: Vehicle[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    this.vehicles = await carService.list();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        SectionHeader({ title: '车辆档案', actionText: '新增车辆', onAction: () => {
          this.stack.pushPath({ name: PAGE_CAR_EDIT, param: {} });
        }})
        ForEach(this.vehicles, (vehicle: Vehicle) => {
          VehicleCard({ vehicle, onEdit: (vehicleId: number) => {
            this.stack.pushPath({ name: PAGE_CAR_EDIT, param: { vehicleId } });
          }})
        }, (vehicle: Vehicle) => `${vehicle.id}`)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F3F6FB')
  }
}
