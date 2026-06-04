import { MaintenanceRecord } from '../models/MaintenanceRecord';
import { maintenanceService } from '../services/MaintenanceService';
import { PAGE_RECORD_EDIT } from '../utils/Constants';
import { SectionHeader } from '../views/SectionHeader';
import { RecordCard } from '../views/RecordCard';

@Component
export struct RecordListPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @Prop params: Object = {};
  @State vehicleId: number = 0;
  @State records: MaintenanceRecord[] = [];

  aboutToAppear(): void {
    const payload: Record<string, number> = this.params as Record<string, number>;
    this.vehicleId = payload['vehicleId'] ?? 0;
    this.refresh();
  }

  private async refresh(): Promise<void> {
    this.records = await maintenanceService.list(this.vehicleId);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        SectionHeader({ title: '保养记录', actionText: '新增记录', onAction: () => {
          this.stack.pushPath({ name: PAGE_RECORD_EDIT, param: { vehicleId: this.vehicleId } });
        }})
        ForEach(this.records, (record: MaintenanceRecord) => {
          RecordCard({ record, onEdit: (recordId: number) => {
            this.stack.pushPath({ name: PAGE_RECORD_EDIT, param: { recordId, vehicleId: record.vehicleId } });
          }})
        }, (record: MaintenanceRecord) => `${record.id}`)
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F3F6FB')
  }
}
