import { Vehicle, createEmptyVehicle } from '../models/Vehicle';
import { databaseService } from './DatabaseService';
import { todayString } from '../utils/Formatters';

class CarService {
  async list(): Promise<Vehicle[]> {
    return await databaseService.queryVehicles();
  }

  async getById(id: number): Promise<Vehicle> {
    const vehicles: Vehicle[] = await this.list();
    return vehicles.find((item: Vehicle) => item.id === id) ?? createEmptyVehicle();
  }

  async getDefaultVehicle(): Promise<Vehicle> {
    const vehicles: Vehicle[] = await this.list();
    return vehicles.find((item: Vehicle) => item.isDefault) ?? vehicles[0] ?? createEmptyVehicle();
  }

  async save(vehicle: Vehicle): Promise<Vehicle> {
    const payload: Vehicle = {
      ...vehicle,
      createdAt: vehicle.createdAt && vehicle.createdAt.length > 0 ? vehicle.createdAt : todayString()
    };
    if (payload.id > 0) {
      await databaseService.updateVehicle(payload);
      return payload;
    }
    const id: number = await databaseService.insertVehicle(payload);
    return {
      ...payload,
      id
    };
  }
}

export const carService: CarService = new CarService();
