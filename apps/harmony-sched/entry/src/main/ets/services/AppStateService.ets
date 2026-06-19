class AppStateService {
  init(): void {
    if (AppStorage.get('currentScheduleId') === undefined) {
      AppStorage.setOrCreate('currentScheduleId', 0);
    }
    if (AppStorage.get('currentWeek') === undefined) {
      AppStorage.setOrCreate('currentWeek', 1);
    }
    if (AppStorage.get('editingCourseId') === undefined) {
      AppStorage.setOrCreate('editingCourseId', 0);
    }
  }

  getCurrentScheduleId(): number {
    return AppStorage.get('currentScheduleId') as number ?? 0;
  }

  setCurrentScheduleId(scheduleId: number): void {
    AppStorage.set('currentScheduleId', scheduleId);
  }

  getCurrentWeek(): number {
    return AppStorage.get('currentWeek') as number ?? 1;
  }

  setCurrentWeek(week: number): void {
    AppStorage.set('currentWeek', week);
  }

  getEditingCourseId(): number {
    return AppStorage.get('editingCourseId') as number ?? 0;
  }

  setEditingCourseId(courseId: number): void {
    AppStorage.set('editingCourseId', courseId);
  }
}

export const appStateService: AppStateService = new AppStateService();
