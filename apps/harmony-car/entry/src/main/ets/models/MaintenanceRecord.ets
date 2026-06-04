import { addDays, todayString } from '../utils/Formatters';

export interface MaintenanceRecord {
  id: number;
  vehicleId: number;
  type: string;
  date: string;
  mileage: number;
  cost: number;
  shop: string;
  note: string;
  nextDate: string;
  nextMileage: number;
  photos: string[];
  createdAt: string;
}

export function createEmptyRecord(vehicleId: number = 0): MaintenanceRecord {
  const today: string = todayString();
  return {
    id: 0,
    vehicleId,
    type: '油',
    date: today,
    mileage: 0,
    cost: 0,
    shop: '',
    note: '',
    nextDate: addDays(today, 180),
    nextMileage: 5000,
    photos: [],
    createdAt: today
  };
}

export function createDemoRecords(): MaintenanceRecord[] {
  const today: string = todayString();
  return [
    {
      id: 1,
      vehicleId: 1,
      type: '油',
      date: addDays(today, -30),
      mileage: 17000,
      cost: 49900,
      shop: 'Harmony 快修',
      note: '全合成机油 + 机滤',
      nextDate: addDays(today, 150),
      nextMileage: 22000,
      photos: [],
      createdAt: today
    },
    {
      id: 2,
      vehicleId: 1,
      type: '洗车',
      date: addDays(today, -7),
      mileage: 18100,
      cost: 5800,
      shop: '小区洗美',
      note: '精洗',
      nextDate: addDays(today, 14),
      nextMileage: 0,
      photos: [],
      createdAt: today
    },
    {
      id: 3,
      vehicleId: 2,
      type: '保险',
      date: addDays(today, -90),
      mileage: 32000,
      cost: 385000,
      shop: '平安车险',
      note: '商业险续保',
      nextDate: addDays(today, 275),
      nextMileage: 0,
      photos: [],
      createdAt: today
    }
  ];
}
