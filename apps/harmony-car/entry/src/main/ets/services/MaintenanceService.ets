import { MaintenanceRecord, createEmptyRecord } from '../models/MaintenanceRecord';
import { databaseService } from './DatabaseService';
import { normalizeMaintenanceType } from '../utils/Constants';
import { todayString } from '../utils/Formatters';

class MaintenanceService {
  async list(vehicleId?: number): Promise<MaintenanceRecord[]> {
    return await databaseService.queryRecords(vehicleId);
  }

  async getById(id: number): Promise<MaintenanceRecord> {
    const records: MaintenanceRecord[] = await this.list();
    return records.find((item: MaintenanceRecord) => item.id === id) ?? createEmptyRecord();
  }

  async save(record: MaintenanceRecord): Promise<MaintenanceRecord> {
    const payload: MaintenanceRecord = {
      ...record,
      type: normalizeMaintenanceType(record.type),
      createdAt: record.createdAt && record.createdAt.length > 0 ? record.createdAt : todayString()
    };
    if (payload.id > 0) {
      await databaseService.updateRecord(payload);
      return payload;
    }
    const id: number = await databaseService.insertRecord(payload);
    return {
      ...payload,
      id
    };
  }

  async totalCostByType(): Promise<Map<string, number>> {
    const records: MaintenanceRecord[] = await this.list();
    const totals: Map<string, number> = new Map<string, number>();
    records.forEach((item: MaintenanceRecord) => {
      const total: number = totals.get(item.type) ?? 0;
      totals.set(item.type, total + item.cost);
    });
    return totals;
  }

  async monthlyCostTrend(): Promise<Map<string, number>> {
    const records: MaintenanceRecord[] = await this.list();
    const totals: Map<string, number> = new Map<string, number>();
    records.forEach((item: MaintenanceRecord) => {
      const key: string = item.date.slice(0, 7);
      const total: number = totals.get(key) ?? 0;
      totals.set(key, total + item.cost);
    });
    return totals;
  }
}

export const maintenanceService: MaintenanceService = new MaintenanceService();
