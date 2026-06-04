import { addDays, todayString } from '../utils/Formatters';

export interface Vehicle {
  id: number;
  plateNumber: string;
  brand: string;
  model: string;
  purchaseDate: string;
  mileage: number;
  vin: string;
  insuranceExpiry: string;
  inspectionExpiry: string;
  color: string;
  isDefault: boolean;
  createdAt: string;
}

export function createEmptyVehicle(): Vehicle {
  const today: string = todayString();
  return {
    id: 0,
    plateNumber: '',
    brand: '',
    model: '',
    purchaseDate: today,
    mileage: 0,
    vin: '',
    insuranceExpiry: addDays(today, 180),
    inspectionExpiry: addDays(today, 240),
    color: '白色',
    isDefault: false,
    createdAt: today
  };
}

export function createDemoVehicles(): Vehicle[] {
  const today: string = todayString();
  return [
    {
      id: 1,
      plateNumber: '京A·H001',
      brand: 'AITO',
      model: 'M7',
      purchaseDate: '2025-03-01',
      mileage: 18300,
      vin: 'VIN00000000000001',
      insuranceExpiry: addDays(today, 120),
      inspectionExpiry: addDays(today, 210),
      color: '深灰',
      isDefault: true,
      createdAt: today
    },
    {
      id: 2,
      plateNumber: '沪B·C520',
      brand: 'BYD',
      model: '唐 DM-i',
      purchaseDate: '2024-06-15',
      mileage: 36200,
      vin: 'VIN00000000000002',
      insuranceExpiry: addDays(today, 60),
      inspectionExpiry: addDays(today, 150),
      color: '黑色',
      isDefault: false,
      createdAt: today
    }
  ];
}
