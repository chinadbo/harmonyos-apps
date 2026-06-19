import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { timetableDatabase } from '../data/TimetableDatabase';
import { DEFAULT_SCHEDULE, ScheduleDraft, ScheduleProfile } from '../data/ScheduleModel';
import { appStateService } from './AppStateService';

class ScheduleService {
  private context?: common.UIAbilityContext;

  init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    appStateService.init();
    return timetableDatabase.init(context)
      .then(() => this.ensureDefaultSchedule())
      .then(() => undefined);
  }

  getContext(): common.UIAbilityContext {
    if (!this.context) {
      throw new Error('ScheduleService is not initialized');
    }
    return this.context;
  }

  private getStore(): Promise<relationalStore.RdbStore> {
    return timetableDatabase.getStore(this.getContext());
  }

  private ensureDefaultSchedule(): Promise<void> {
    return this.listSchedules().then((items: ScheduleProfile[]) => {
      if (items.length > 0) {
        const active = items.find((item: ScheduleProfile) => item.isActive) ?? items[0];
        appStateService.setCurrentScheduleId(active.id);
        return Promise.resolve();
      }
      return this.createSchedule(DEFAULT_SCHEDULE).then(() => undefined);
    });
  }

  listSchedules(): Promise<ScheduleProfile[]> {
    return this.getStore()
      .then((store: relationalStore.RdbStore) => store.querySql('SELECT * FROM schedules ORDER BY isActive DESC, updatedAt DESC'))
      .then((resultSet: relationalStore.ResultSet) => timetableDatabase.resultSetToSchedules(resultSet));
  }

  getCurrentSchedule(): Promise<ScheduleProfile | undefined> {
    const currentId = appStateService.getCurrentScheduleId();
    return this.listSchedules().then((items: ScheduleProfile[]) => {
      return items.find((item: ScheduleProfile) => item.id === currentId) ?? items[0];
    });
  }

  createSchedule(draft: ScheduleDraft): Promise<ScheduleProfile> {
    return this.getStore().then((store: relationalStore.RdbStore) => {
      const now = Date.now();
      const bucket: relationalStore.ValuesBucket = {
        'name': draft.name,
        'termName': draft.termName,
        'startDate': draft.startDate,
        'weeks': draft.weeks,
        'isActive': draft.isActive ? 1 : 0,
        'createdAt': now,
        'updatedAt': now
      };
      return store.insert('schedules', bucket).then((id: number) => {
        if (draft.isActive) {
          appStateService.setCurrentScheduleId(id);
        }
        return {
          id,
          name: draft.name,
          termName: draft.termName,
          startDate: draft.startDate,
          weeks: draft.weeks,
          isActive: draft.isActive,
          createdAt: now,
          updatedAt: now
        };
      });
    });
  }

  updateSchedule(draft: ScheduleDraft): Promise<void> {
    if (!draft.id) {
      return Promise.reject(new Error('Schedule id is required'));
    }
    return this.getStore().then((store: relationalStore.RdbStore) => {
      const bucket: relationalStore.ValuesBucket = {
        'name': draft.name,
        'termName': draft.termName,
        'startDate': draft.startDate,
        'weeks': draft.weeks,
        'isActive': draft.isActive ? 1 : 0,
        'updatedAt': Date.now()
      };
      const predicates = new relationalStore.RdbPredicates('schedules');
      predicates.equalTo('id', draft.id);
      return store.update(bucket, predicates).then(() => {
        if (draft.isActive) {
          appStateService.setCurrentScheduleId(draft.id as number);
        }
      });
    });
  }

  switchSchedule(scheduleId: number): Promise<void> {
    return this.listSchedules().then((items: ScheduleProfile[]) => {
      let chain = Promise.resolve();
      items.forEach((item: ScheduleProfile) => {
        chain = chain.then(() => this.updateSchedule({
          id: item.id,
          name: item.name,
          termName: item.termName,
          startDate: item.startDate,
          weeks: item.weeks,
          isActive: item.id === scheduleId
        }));
      });
      return chain.then(() => {
        appStateService.setCurrentScheduleId(scheduleId);
      });
    });
  }
}

export const scheduleService: ScheduleService = new ScheduleService();
