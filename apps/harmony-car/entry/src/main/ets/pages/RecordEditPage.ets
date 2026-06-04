import promptAction from '@ohos.promptAction';
import { MaintenanceRecord, createEmptyRecord } from '../models/MaintenanceRecord';
import { maintenanceService } from '../services/MaintenanceService';
import { parseInteger, parseNumber } from '../utils/Formatters';
import { RecordFormView } from '../views/RecordFormView';

@Component
export struct RecordEditPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @Prop params: Object = {};

  @State recordId: number = 0;
  @State vehicleId: number = 0;
  @State type: string = '油';
  @State date: string = '';
  @State mileageText: string = '0';
  @State costText: string = '0';
  @State shop: string = '';
  @State note: string = '';
  @State nextDate: string = '';
  @State nextMileageText: string = '0';
  @State createdAt: string = '';

  aboutToAppear(): void {
    const payload: Record<string, number> = this.params as Record<string, number>;
    this.recordId = payload['recordId'] ?? 0;
    this.vehicleId = payload['vehicleId'] ?? 0;
    this.loadRecord();
  }

  private async loadRecord(): Promise<void> {
    const record: MaintenanceRecord = this.recordId > 0 ? await maintenanceService.getById(this.recordId) : createEmptyRecord(this.vehicleId);
    this.type = record.type;
    this.date = record.date;
    this.mileageText = `${record.mileage}`;
    this.costText = `${record.cost / 100}`;
    this.shop = record.shop;
    this.note = record.note;
    this.nextDate = record.nextDate;
    this.nextMileageText = `${record.nextMileage}`;
    this.createdAt = record.createdAt;
  }

  private async save(): Promise<void> {
    const payload: MaintenanceRecord = {
      id: this.recordId,
      vehicleId: this.vehicleId,
      type: this.type,
      date: this.date,
      mileage: parseInteger(this.mileageText),
      cost: Math.round(parseNumber(this.costText) * 100),
      shop: this.shop,
      note: this.note,
      nextDate: this.nextDate,
      nextMileage: parseInteger(this.nextMileageText),
      photos: [],
      createdAt: this.createdAt
    };
    await maintenanceService.save(payload);
    promptAction.showToast({ message: '记录已保存' });
    this.stack.pop();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        RecordFormView({
          type: $type,
          date: $date,
          mileageText: $mileageText,
          costText: $costText,
          shop: $shop,
          note: $note,
          nextDate: $nextDate,
          nextMileageText: $nextMileageText
        })
        Button('保存记录')
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
