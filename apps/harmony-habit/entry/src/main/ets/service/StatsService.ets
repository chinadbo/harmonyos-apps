import { HabitModel } from '../model/HabitModel';
import { CheckInModel } from '../model/CheckInModel';
import { DateUtils } from '../common/DateUtils';

export interface HabitSummaryItem {
  habit: HabitModel;
  completedToday: boolean;
  currentStreak: number;
  totalCheckins: number;
}

export interface DashboardStats {
  totalHabits: number;
  activeHabits: number;
  todayTotal: number;
  todayDone: number;
  completionRate: number;
  longestStreak: number;
  recent7Days: number[];
}

export class StatsService {
  static buildHabitSummary(habit: HabitModel, checkins: CheckInModel[]): HabitSummaryItem {
    const today = DateUtils.today();
    const sorted = checkins.slice().sort((a, b) => DateUtils.compareDate(a.checkDate, b.checkDate));
    return {
      habit,
      completedToday: sorted.some((item) => item.checkDate === today),
      currentStreak: this.calculateStreak(sorted),
      totalCheckins: sorted.length
    };
  }

  static calculateStreak(checkins: CheckInModel[]): number {
    if (checkins.length === 0) {
      return 0;
    }
    const dates = checkins.map((item) => item.checkDate).sort();
    let streak = 0;
    let cursor = dates[dates.length - 1];
    for (let index = dates.length - 1; index >= 0; index--) {
      if (dates[index] === cursor) {
        streak++;
        cursor = DateUtils.shiftDate(cursor, -1);
      } else if (dates[index] < cursor) {
        break;
      }
    }
    if (dates[dates.length - 1] !== DateUtils.today() && dates[dates.length - 1] !== DateUtils.shiftDate(DateUtils.today(), -1)) {
      return 0;
    }
    return streak;
  }

  static buildDashboard(habits: HabitModel[], checkins: CheckInModel[]): DashboardStats {
    const today = DateUtils.today();
    const activeHabits = habits.filter((item) => item.isActive === 1);
    const todayHabits = activeHabits.filter((item) => DateUtils.isHabitScheduled(item.targetDays, today));
    const todayDoneIds = new Set<number>(checkins.filter((item) => item.checkDate === today).map((item) => item.habitId));
    const streaks = activeHabits.map((habit) => this.calculateStreak(checkins.filter((item) => item.habitId === habit.id)));
    const recentDates = DateUtils.recentDates(7);
    const recent7Days = recentDates.map((dateString) => {
      return checkins.filter((item) => item.checkDate === dateString).length;
    });
    const todayDone = todayHabits.filter((item) => todayDoneIds.has(item.id)).length;
    const todayTotal = todayHabits.length;
    return {
      totalHabits: habits.length,
      activeHabits: activeHabits.length,
      todayTotal,
      todayDone,
      completionRate: todayTotal === 0 ? 0 : Math.round(todayDone * 100 / todayTotal),
      longestStreak: streaks.length === 0 ? 0 : Math.max(...streaks),
      recent7Days
    };
  }
}
