import relationalStore from '@ohos.data.relationalStore';
import { Course, CourseBlock, CourseDraft } from '../data/CourseModel';
import { timetableDatabase } from '../data/TimetableDatabase';
import { appStateService } from './AppStateService';
import { reminderService } from './ReminderService';
import { scheduleService } from './ScheduleService';

class CourseService {
  private getStore(): Promise<relationalStore.RdbStore> {
    return timetableDatabase.getStore(scheduleService.getContext());
  }

  listCourses(scheduleId?: number): Promise<Course[]> {
    const targetScheduleId = scheduleId ?? appStateService.getCurrentScheduleId();
    return this.getStore()
      .then((store: relationalStore.RdbStore) => store.querySql('SELECT * FROM courses WHERE scheduleId = ? ORDER BY dayOfWeek ASC, startSection ASC', [targetScheduleId]))
      .then((resultSet: relationalStore.ResultSet) => timetableDatabase.resultSetToCourses(resultSet));
  }

  getCourseById(courseId: number): Promise<Course | undefined> {
    return this.listCourses().then((items: Course[]) => items.find((item: Course) => item.id === courseId));
  }

  private draftToBucket(draft: CourseDraft, reminderId: number): relationalStore.ValuesBucket {
    const now = Date.now();
    const bucket: relationalStore.ValuesBucket = {
      'scheduleId': draft.scheduleId,
      'name': draft.name,
      'teacher': draft.teacher,
      'location': draft.location,
      'dayOfWeek': draft.dayOfWeek,
      'startSection': draft.startSection,
      'duration': draft.duration,
      'startWeek': draft.startWeek,
      'endWeek': draft.endWeek,
      'weekType': draft.weekType,
      'color': draft.color,
      'reminderEnabled': draft.reminderEnabled ? 1 : 0,
      'reminderMinutes': draft.reminderMinutes,
      'reminderId': reminderId,
      'note': draft.note,
      'updatedAt': now
    };
    if (!draft.id) {
      bucket['createdAt'] = now;
    }
    return bucket;
  }

  createCourse(draft: CourseDraft): Promise<Course> {
    return this.getStore().then((store: relationalStore.RdbStore) => {
      const now = Date.now();
      const staged: Course = {
        id: 0,
        scheduleId: draft.scheduleId,
        name: draft.name,
        teacher: draft.teacher,
        location: draft.location,
        dayOfWeek: draft.dayOfWeek,
        startSection: draft.startSection,
        duration: draft.duration,
        startWeek: draft.startWeek,
        endWeek: draft.endWeek,
        weekType: draft.weekType,
        color: draft.color,
        reminderEnabled: draft.reminderEnabled,
        reminderMinutes: draft.reminderMinutes,
        reminderId: 0,
        note: draft.note,
        createdAt: now,
        updatedAt: now
      };
      const triggerTime = Date.now() + draft.reminderMinutes * 60 * 1000;
      return reminderService.publishReminder(staged, triggerTime).then((reminderId: number) => {
        const bucket = this.draftToBucket(draft, reminderId);
        return store.insert('courses', bucket).then((id: number) => {
          staged.id = id;
          staged.reminderId = reminderId;
          return staged;
        });
      });
    });
  }

  updateCourse(draft: CourseDraft): Promise<void> {
    if (!draft.id) {
      return Promise.reject(new Error('Course id is required'));
    }
    return this.getCourseById(draft.id).then((current: Course | undefined) => {
      if (!current) {
        return Promise.reject(new Error('Course not found'));
      }
      const triggerTime = Date.now() + draft.reminderMinutes * 60 * 1000;
      return reminderService.cancelReminder(current.reminderId)
        .then(() => reminderService.publishReminder({
          ...current,
          ...draft,
          id: draft.id,
          reminderId: 0,
          createdAt: current.createdAt,
          updatedAt: Date.now()
        }, triggerTime))
        .then((reminderId: number) => {
          return this.getStore().then((store: relationalStore.RdbStore) => {
            const bucket = this.draftToBucket(draft, reminderId);
            const predicates = new relationalStore.RdbPredicates('courses');
            predicates.equalTo('id', draft.id as number);
            return store.update(bucket, predicates).then(() => undefined);
          });
        });
    });
  }

  deleteCourse(item: Course): Promise<void> {
    return reminderService.cancelReminder(item.reminderId).then(() => {
      return this.getStore().then((store: relationalStore.RdbStore) => {
        const predicates = new relationalStore.RdbPredicates('courses');
        predicates.equalTo('id', item.id);
        return store.delete(predicates).then(() => undefined);
      });
    });
  }

  filterCoursesForWeek(items: Course[], currentWeek: number): Course[] {
    return items.filter((item: Course) => {
      if (currentWeek < item.startWeek || currentWeek > item.endWeek) {
        return false;
      }
      if (item.weekType === 1) {
        return currentWeek % 2 === 1;
      }
      if (item.weekType === 2) {
        return currentWeek % 2 === 0;
      }
      return true;
    });
  }

  buildWeekBlocks(items: Course[]): CourseBlock[] {
    return items.map((item: Course) => ({
      id: item.id,
      title: item.name,
      subtitle: `${item.location} · ${item.teacher}`,
      dayOfWeek: item.dayOfWeek,
      topPercent: ((item.startSection - 1) / 12) * 100,
      heightPercent: (item.duration / 12) * 100,
      color: item.color
    }));
  }

  formatWeekType(weekType: number): string {
    if (weekType === 1) {
      return '单周';
    }
    if (weekType === 2) {
      return '双周';
    }
    return '每周';
  }
}

export const courseService: CourseService = new CourseService();
