import { Vehicle } from '../models/Vehicle';
import { MaintenanceRecord } from '../models/MaintenanceRecord';
import { ReminderItem } from '../models/Reminder';
import { carService } from '../services/CarService';
import { maintenanceService } from '../services/MaintenanceService';
import { reminderService } from '../services/ReminderService';
import { formatCurrencyFromCent } from '../utils/Formatters';

export interface WidgetOverview {
  plateNumber: string;
  modelName: string;
  mileageText: string;
  nextReminderText: string;
  totalCostText: string;
  lastRecordText: string;
  reminderCountText: string;
}

export async function buildWidgetOverview(): Promise<WidgetOverview> {
  const vehicle: Vehicle = await carService.getDefaultVehicle();
  const records: MaintenanceRecord[] = await maintenanceService.list(vehicle.id);
  const reminders: ReminderItem[] = await reminderService.list(vehicle.id);
  const totalCost: number = records.reduce((sum: number, item: MaintenanceRecord) => sum + item.cost, 0);
  const lastRecord: MaintenanceRecord | undefined = records[0];
  const nextReminder: ReminderItem | undefined = reminders[0];
  return {
    plateNumber: vehicle.plateNumber || '未设置车辆',
    modelName: `${vehicle.brand} ${vehicle.model}`.trim(),
    mileageText: `${vehicle.mileage} km`,
    nextReminderText: nextReminder ? `${nextReminder.type} ${nextReminder.triggerDate}` : '暂无提醒',
    totalCostText: formatCurrencyFromCent(totalCost),
    lastRecordText: lastRecord ? `${lastRecord.type} ${lastRecord.date}` : '暂无记录',
    reminderCountText: `${reminders.filter((item: ReminderItem) => item.isActive).length} 个启用提醒`
  };
}
