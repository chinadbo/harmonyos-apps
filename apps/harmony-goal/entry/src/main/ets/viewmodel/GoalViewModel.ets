import common from '@ohos.app.ability.common';
import { ChartPoint, CheckIn, Goal, GoalDetail, GoalFormData, GoalStatistics, KeyResult, KRFormData, ReminderSettings } from '../model/GoalModel';
import { DatabaseHelper } from '../model/DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';
import { NotificationHelper } from '../utils/NotificationHelper';

export class GoalViewModel {
  private static instance: GoalViewModel = new GoalViewModel();
  private database: DatabaseHelper = DatabaseHelper.getInstance();
  private initialized: boolean = false;

  static getInstance(): GoalViewModel {
    return GoalViewModel.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized) {
      return;
    }
    await this.database.init(context);
    this.ensureStorageDefaults();
    await this.refreshAll();
    let settings: ReminderSettings = NotificationHelper.loadSettings();
    NotificationHelper.saveSettings(settings);
    this.initialized = true;
  }

  private ensureStorageDefaults(): void {
    AppStorage.SetOrCreate('goals', [] as Goal[]);
    AppStorage.SetOrCreate('goalDetails', [] as GoalDetail[]);
    AppStorage.SetOrCreate('selectedGoalId', 0);
    AppStorage.SetOrCreate('selectedGoalDetail', null as GoalDetail | null);
    AppStorage.SetOrCreate('statistics', {
      totalGoals: 0,
      activeGoals: 0,
      completedGoals: 0,
      pausedGoals: 0,
      averageProgress: 0,
      averageKrCompletion: 0,
      completionRate: 0,
      totalCheckIns: 0
    } as GoalStatistics);
    AppStorage.SetOrCreate('chartPoints', [] as ChartPoint[]);
    AppStorage.SetOrCreate('reminderSettings', NotificationHelper.defaultSettings());
    AppStorage.SetOrCreate('goalColors', ['#4C7DFF', '#20C997', '#8E6CFF', '#FF9F43', '#FF6B6B']);
  }

  async refreshAll(): Promise<void> {
    let goals: Goal[] = await this.database.listGoals();
    AppStorage.SetOrCreate('goals', goals);
    let statistics: GoalStatistics = await this.database.getStatistics();
    AppStorage.SetOrCreate('statistics', statistics);
    let selectedGoalId: number = AppStorage.Get<number>('selectedGoalId') ?? 0;
    if (selectedGoalId > 0) {
      await this.loadGoalDetail(selectedGoalId);
    } else {
      AppStorage.SetOrCreate('selectedGoalDetail', null);
      AppStorage.SetOrCreate('chartPoints', [] as ChartPoint[]);
    }
  }

  async loadGoalDetail(goalId: number): Promise<GoalDetail | null> {
    AppStorage.SetOrCreate('selectedGoalId', goalId);
    let detail: GoalDetail | null = await this.database.getGoalDetail(goalId);
    AppStorage.SetOrCreate('selectedGoalDetail', detail);
    AppStorage.SetOrCreate('chartPoints', this.buildChartPoints(detail));
    return detail;
  }

  buildChartPoints(detail: GoalDetail | null): ChartPoint[] {
    if (!detail || detail.checkIns.length === 0) {
      if (detail && detail.goal) {
        return [{
          label: DateUtils.formatMonthDay(DateUtils.today()),
          value: detail.goal.progress,
          date: DateUtils.today()
        }];
      }
      return [];
    }
    let points: ChartPoint[] = detail.checkIns.map((item: CheckIn) => {
      return {
        label: DateUtils.formatMonthDay(item.date),
        value: item.progress,
        date: item.date
      };
    });
    return DateUtils.buildContinuousChart(points.reverse());
  }

  async createGoal(data: GoalFormData): Promise<number> {
    let goalId: number = await this.database.createGoal(data);
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
    return goalId;
  }

  async updateGoal(goalId: number, data: GoalFormData): Promise<void> {
    await this.database.updateGoal(goalId, data);
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
  }

  async deleteGoal(goalId: number): Promise<void> {
    await this.database.deleteGoal(goalId);
    AppStorage.SetOrCreate('selectedGoalId', 0);
    AppStorage.SetOrCreate('selectedGoalDetail', null);
    AppStorage.SetOrCreate('chartPoints', [] as ChartPoint[]);
    await this.refreshAll();
  }

  async createKeyResult(data: KRFormData): Promise<number> {
    let krId: number = await this.database.createKeyResult(data);
    await this.refreshAll();
    await this.loadGoalDetail(data.goalId);
    return krId;
  }

  async updateKeyResult(krId: number, data: KRFormData): Promise<void> {
    await this.database.updateKeyResult(krId, data);
    await this.refreshAll();
    await this.loadGoalDetail(data.goalId);
  }

  async updateKrProgress(goalId: number, krId: number, currentValue: number): Promise<void> {
    await this.database.updateKrProgress(krId, goalId, currentValue);
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
  }

  async deleteKeyResult(goalId: number, krId: number): Promise<void> {
    await this.database.deleteKeyResult(goalId, krId);
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
  }

  async addCheckIn(goalId: number, note: string): Promise<void> {
    let detail: GoalDetail | null = await this.database.getGoalDetail(goalId);
    let progress: number = detail ? detail.goal.progress : 0;
    await this.database.createCheckIn(goalId, note, progress, DateUtils.today());
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
  }

  async deleteCheckIn(goalId: number, checkInId: number): Promise<void> {
    await this.database.deleteCheckIn(goalId, checkInId);
    await this.refreshAll();
    await this.loadGoalDetail(goalId);
  }

  async saveReminderSettings(enabled: boolean, hour: number, minute: number): Promise<void> {
    let current: ReminderSettings = NotificationHelper.loadSettings();
    let next: ReminderSettings = {
      enabled: enabled,
      hour: hour,
      minute: minute,
      reminderId: current.reminderId
    };
    await NotificationHelper.applyDailyReminder(next);
    AppStorage.SetOrCreate('reminderSettings', next);
  }

  getGoalFormData(goal?: Goal | null): GoalFormData {
    return {
      title: goal?.title ?? '',
      description: goal?.description ?? '',
      period: goal?.period ?? 'month',
      color: goal?.color ?? '#4C7DFF',
      status: goal?.status ?? 'in_progress',
      deadline: goal?.deadline ?? DateUtils.nextDate(DateUtils.today(), 30)
    };
  }

  getKrFormData(goalId: number, kr?: KeyResult | null): KRFormData {
    return {
      goalId: goalId,
      title: kr?.title ?? '',
      krType: kr?.krType ?? 'number',
      targetValue: kr?.targetValue ?? 100,
      currentValue: kr?.currentValue ?? 0,
      unit: kr?.unit ?? '',
      weight: kr?.weight ?? 1
    };
  }
}

export const goalViewModel: GoalViewModel = GoalViewModel.getInstance();
