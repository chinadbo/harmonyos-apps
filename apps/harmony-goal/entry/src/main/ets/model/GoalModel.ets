export type GoalPeriod = 'week' | 'month' | 'quarter' | 'year';
export type GoalStatus = 'not_started' | 'in_progress' | 'completed' | 'paused';
export type KRType = 'number' | 'boolean';

export interface Goal {
  id: number;
  title: string;
  description: string;
  period: GoalPeriod;
  color: string;
  status: GoalStatus;
  deadline: string;
  createdAt: number;
  updatedAt: number;
  progress: number;
  keyResultCount: number;
  checkInCount: number;
}

export interface KeyResult {
  id: number;
  goalId: number;
  title: string;
  krType: KRType;
  targetValue: number;
  currentValue: number;
  unit: string;
  weight: number;
  createdAt: number;
}

export interface CheckIn {
  id: number;
  goalId: number;
  note: string;
  progress: number;
  date: string;
  createdAt: number;
}

export interface GoalDetail {
  goal: Goal;
  keyResults: KeyResult[];
  checkIns: CheckIn[];
}

export interface GoalStatistics {
  totalGoals: number;
  activeGoals: number;
  completedGoals: number;
  pausedGoals: number;
  averageProgress: number;
  averageKrCompletion: number;
  completionRate: number;
  totalCheckIns: number;
}

export interface ChartPoint {
  label: string;
  value: number;
  date: string;
}

export interface GoalFormData {
  title: string;
  description: string;
  period: GoalPeriod;
  color: string;
  status: GoalStatus;
  deadline: string;
}

export interface KRFormData {
  goalId: number;
  title: string;
  krType: KRType;
  targetValue: number;
  currentValue: number;
  unit: string;
  weight: number;
}

export interface ReminderSettings {
  enabled: boolean;
  hour: number;
  minute: number;
  reminderId: number;
}

export interface DashboardCard {
  title: string;
  value: string;
  color: string;
}
