export interface City {
  name: string;
  lat: number;
  lon: number;
}

export interface MoonInfo {
  julianDay: number;
  phase: number;
  phaseName: string;
  phaseEmoji: string;
  ageDays: number;
  illumination: number;
  distanceKm: number;
  angularDiameterDeg: number;
  nextNewMoonDays: number;
  nextFullMoonDays: number;
}

export interface RiseSetInfo {
  time: string;
  azimuthDeg: number;
}

export interface SunTimes {
  sunrise: string;
  sunset: string;
  dayLength: string;
  solarNoon: string;
  civilDawn: string;
  civilDusk: string;
  polarNote: string;
}

export interface MoonTimes {
  moonRise: string;
  moonSet: string;
  polarNote: string;
}

export interface StarTarget {
  id: string;
  name: string;
  constellation: string;
  mag: number;
  difficulty: number;
  bestSeason: string;
  ra: number;
  dec: number;
  desc: string;
}

export interface LearnCard {
  id: string;
  title: string;
  subtitle: string;
  body: string;
  facts: string[];
}

export const settingsPrefKeys = {
  city: 'cityName',
  lat: 'latitude',
  lon: 'longitude',
  themeDark: 'themeDark'
} as Record<string, string>;

export const defaultCityName: string = '北京';

export const cities: City[] = [
  { name: '北京', lat: 39.9042, lon: 116.4074 },
  { name: '上海', lat: 31.2304, lon: 121.4737 },
  { name: '广州', lat: 23.1291, lon: 113.2644 },
  { name: '深圳', lat: 22.5431, lon: 114.0579 },
  { name: '成都', lat: 30.5728, lon: 104.0668 },
  { name: '重庆', lat: 29.5630, lon: 106.5516 },
  { name: '西安', lat: 34.3416, lon: 108.9398 },
  { name: '杭州', lat: 30.2741, lon: 120.1551 },
  { name: '武汉', lat: 30.5928, lon: 114.3055 },
  { name: '哈尔滨', lat: 45.8038, lon: 126.5349 },
  { name: '拉萨', lat: 29.6520, lon: 91.1721 },
  { name: '乌鲁木齐', lat: 43.8256, lon: 87.6168 }
];
