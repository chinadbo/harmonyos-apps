import { Vehicle } from '../models/Vehicle';
import { MaintenanceRecord } from '../models/MaintenanceRecord';
import { ReminderItem } from '../models/Reminder';
import { carService } from '../services/CarService';
import { maintenanceService } from '../services/MaintenanceService';
import { reminderService } from '../services/ReminderService';
import { PAGE_CAR_EDIT, PAGE_CAR_LIST, PAGE_RECORD_EDIT, PAGE_RECORD_LIST, PAGE_REMINDERS, PAGE_STATS } from '../utils/Constants';
import { formatCurrencyFromCent } from '../utils/Formatters';
import { SectionHeader } from '../views/SectionHeader';
import { SummaryCard } from '../views/SummaryCard';
import { VehicleCard } from '../views/VehicleCard';
import { RecordCard } from '../views/RecordCard';
import { ReminderCard } from '../views/ReminderCard';

@Component
export struct MainPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @State defaultVehicle: Vehicle = {
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
  @State records: MaintenanceRecord[] = [];
  @State reminders: ReminderItem[] = [];
  @State vehicleCount: number = 0;
  @State totalCost: number = 0;

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    const vehicles: Vehicle[] = await carService.list();
    const defaultVehicle: Vehicle = await carService.getDefaultVehicle();
    const records: MaintenanceRecord[] = await maintenanceService.list(defaultVehicle.id);
    const reminders: ReminderItem[] = await reminderService.list(defaultVehicle.id);
    this.defaultVehicle = defaultVehicle;
    this.records = records.slice(0, 3);
    this.reminders = reminders.slice(0, 2);
    this.vehicleCount = vehicles.length;
    this.totalCost = records.reduce((sum: number, item: MaintenanceRecord) => sum + item.cost, 0);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        SectionHeader({ title: '今日概览', actionText: '统计分析', onAction: () => {
          this.stack.pushPath({ name: PAGE_STATS, param: {} });
        }})

        Row({ space: 12 }) {
          SummaryCard({ title: '车辆数量', value: `${this.vehicleCount}`, subValue: '多车档案管理', accentColor: '#4E7BF2' })
          SummaryCard({ title: '当前总费用', value: formatCurrencyFromCent(this.totalCost), subValue: '默认车辆累计', accentColor: '#5CC8B2' })
        }
        .width('100%')

        SectionHeader({ title: '默认车辆', actionText: '车辆列表', onAction: () => {
          this.stack.pushPath({ name: PAGE_CAR_LIST, param: {} });
        }})
        VehicleCard({ vehicle: this.defaultVehicle, onEdit: (vehicleId: number) => {
          this.stack.pushPath({ name: PAGE_CAR_EDIT, param: { vehicleId } });
        }})

        Row({ space: 12 }) {
          Button('新增车辆')
            .layoutWeight(1)
            .height(42)
            .backgroundColor('#4E7BF2')
            .onClick(() => {
              this.stack.pushPath({ name: PAGE_CAR_EDIT, param: {} });
            })
          Button('新增记录')
            .layoutWeight(1)
            .height(42)
            .backgroundColor('#5CC8B2')
            .onClick(() => {
              this.stack.pushPath({ name: PAGE_RECORD_EDIT, param: { vehicleId: this.defaultVehicle.id } });
            })
        }
        .width('100%')

        SectionHeader({ title: '近期保养', actionText: '全部记录', onAction: () => {
          this.stack.pushPath({ name: PAGE_RECORD_LIST, param: { vehicleId: this.defaultVehicle.id } });
        }})
        ForEach(this.records, (item: MaintenanceRecord) => {
          RecordCard({ record: item, onEdit: (recordId: number) => {
            this.stack.pushPath({ name: PAGE_RECORD_EDIT, param: { recordId, vehicleId: item.vehicleId } });
          }})
        }, (item: MaintenanceRecord) => `${item.id}`)

        SectionHeader({ title: '提醒事项', actionText: '提醒管理', onAction: () => {
          this.stack.pushPath({ name: PAGE_REMINDERS, param: {} });
        }})
        ForEach(this.reminders, (item: ReminderItem) => {
          ReminderCard({ reminder: item, onToggle: async (reminderId: number, isActive: boolean) => {
            const reminder: ReminderItem | undefined = this.reminders.find((current: ReminderItem) => current.id === reminderId);
            if (!reminder) {
              return;
            }
            await reminderService.toggle(reminder, isActive);
            this.refresh();
          }})
        }, (item: ReminderItem) => `${item.id}`)
      }
      .padding(16)
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F3F6FB')
  }
}
