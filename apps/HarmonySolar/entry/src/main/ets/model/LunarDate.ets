export interface LunarDate {
  year: number;
  month: number;
  day: number;
  isLeap: boolean;
  ganzhiYear: string;
  ganzhiMonth: string;
  ganzhiDay: string;
  zodiac: string;
  monthName: string;
  dayName: string;
  text: string;
}

export interface LunarMonthOption {
  month: number;
  isLeap: boolean;
  label: string;
}

export interface SolarDateResult {
  year: number;
  month: number;
  day: number;
  weekday: string;
}
