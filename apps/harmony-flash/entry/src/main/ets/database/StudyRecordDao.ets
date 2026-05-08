import relationalStore from '@ohos.data.relationalStore';
import { StudyRecord } from '../model/StudyRecord';

export class StudyRecordDao {
  private store: relationalStore.RdbStore;

  constructor(store: relationalStore.RdbStore) {
    this.store = store;
  }

  async insert(record: StudyRecord): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      card_id: record.cardId,
      deck_id: record.deckId,
      quality: record.quality,
      review_date: record.reviewDate
    };
    return await this.store.insert('study_records', values);
  }

  /**
   * 获取最近 N 天每天的学习量
   * 返回：[{date: 'YYYY-MM-DD', count: number}]
   */
  async getDailyCount(days: number): Promise<Array<{ date: string; count: number }>> {
    const result: Array<{ date: string; count: number }> = [];
    const now = Date.now();
    for (let i = days - 1; i >= 0; i--) {
      const dayStart = new Date(now - i * 24 * 60 * 60 * 1000);
      dayStart.setHours(0, 0, 0, 0);
      const dayEnd = new Date(dayStart.getTime());
      dayEnd.setHours(23, 59, 59, 999);

      const predicates = new relationalStore.RdbPredicates('study_records');
      predicates
        .greaterThanOrEqualTo('review_date', dayStart.getTime())
        .and()
        .lessThanOrEqualTo('review_date', dayEnd.getTime());
      const cursor = await this.store.query(predicates, ['id']);
      let count = 0;
      while (cursor.goToNextRow()) {
        count++;
      }
      cursor.close();

      const dateStr = `${dayStart.getMonth() + 1}/${dayStart.getDate()}`;
      result.push({ date: dateStr, count });
    }
    return result;
  }

  async getTodayCount(): Promise<number> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    const predicates = new relationalStore.RdbPredicates('study_records');
    predicates
      .greaterThanOrEqualTo('review_date', today.getTime())
      .and()
      .lessThanOrEqualTo('review_date', todayEnd.getTime());
    const cursor = await this.store.query(predicates, ['id']);
    let count = 0;
    while (cursor.goToNextRow()) {
      count++;
    }
    cursor.close();
    return count;
  }

  async getStreakDays(): Promise<number> {
    let streak = 0;
    const now = Date.now();
    for (let i = 0; i < 365; i++) {
      const dayStart = new Date(now - i * 24 * 60 * 60 * 1000);
      dayStart.setHours(0, 0, 0, 0);
      const dayEnd = new Date(dayStart.getTime());
      dayEnd.setHours(23, 59, 59, 999);

      const predicates = new relationalStore.RdbPredicates('study_records');
      predicates
        .greaterThanOrEqualTo('review_date', dayStart.getTime())
        .and()
        .lessThanOrEqualTo('review_date', dayEnd.getTime());
      const cursor = await this.store.query(predicates, ['id']);
      let hasRecord = cursor.goToNextRow();
      cursor.close();

      if (hasRecord) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }
}
