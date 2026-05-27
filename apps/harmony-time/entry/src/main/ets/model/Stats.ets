export interface ProjectDurationStat {
  projectId: number;
  projectName: string;
  color: string;
  duration: number;
}

export interface DailyDurationStat {
  dayLabel: string;
  duration: number;
}

export interface OverviewStat {
  todayDuration: number;
  weekDuration: number;
  totalDuration: number;
}
